#!/usr/bin/env node
/**
 * WAV SFX + BGM 생성기 — 퇴마록: 백귀야행
 * 프로그래매틱 사운드 합성 (외부 라이브러리 불필요)
 */

const fs = require('fs');
const path = require('path');

const SAMPLE_RATE = 22050;

// WAV 파일 생성
function createWav(samples, sampleRate = SAMPLE_RATE) {
  const numSamples = samples.length;
  const byteRate = sampleRate * 2; // 16-bit mono
  const dataSize = numSamples * 2;
  const buffer = Buffer.alloc(44 + dataSize);

  // RIFF header
  buffer.write('RIFF', 0);
  buffer.writeUInt32LE(36 + dataSize, 4);
  buffer.write('WAVE', 8);
  // fmt chunk
  buffer.write('fmt ', 12);
  buffer.writeUInt32LE(16, 16);
  buffer.writeUInt16LE(1, 20); // PCM
  buffer.writeUInt16LE(1, 22); // mono
  buffer.writeUInt32LE(sampleRate, 24);
  buffer.writeUInt32LE(byteRate, 28);
  buffer.writeUInt16LE(2, 32); // block align
  buffer.writeUInt16LE(16, 34); // bits per sample
  // data chunk
  buffer.write('data', 36);
  buffer.writeUInt32LE(dataSize, 40);

  for (let i = 0; i < numSamples; i++) {
    const val = Math.max(-1, Math.min(1, samples[i]));
    buffer.writeInt16LE(Math.round(val * 32767), 44 + i * 2);
  }
  return buffer;
}

// 기본 합성 함수
function sine(freq, t) { return Math.sin(2 * Math.PI * freq * t); }
function saw(freq, t) { return 2 * (freq * t % 1) - 1; }
function noise() { return Math.random() * 2 - 1; }
function envelope(t, attack, decay, sustain, release, duration) {
  if (t < attack) return t / attack;
  if (t < attack + decay) return 1 - (1 - sustain) * ((t - attack) / decay);
  if (t < duration - release) return sustain;
  if (t < duration) return sustain * (1 - (t - (duration - release)) / release);
  return 0;
}

function generate(duration, fn) {
  const n = Math.floor(SAMPLE_RATE * duration);
  const samples = new Float64Array(n);
  for (let i = 0; i < n; i++) {
    samples[i] = fn(i / SAMPLE_RATE);
  }
  return samples;
}

// ═══════════════════════════════════════════
//  SFX 정의
// ═══════════════════════════════════════════

const sfx = {
  // 무기 발사 — 부적 투척 소리 (짧은 슈웅)
  weapon_toema_bujeok: () => generate(0.15, t => {
    const e = envelope(t, 0.005, 0.05, 0.3, 0.05, 0.15);
    return e * (sine(800 - t * 3000, t) * 0.6 + noise() * 0.15);
  }),

  // 비녀검 — 금속 슬래시
  weapon_binyeo_geom: () => generate(0.2, t => {
    const e = envelope(t, 0.002, 0.08, 0.2, 0.05, 0.2);
    return e * (sine(1200 - t * 2000, t) * 0.4 + noise() * 0.4);
  }),

  // 도깨비불 — 불 느낌
  weapon_dokkaebi_bul: () => generate(0.3, t => {
    const e = envelope(t, 0.01, 0.1, 0.4, 0.1, 0.3);
    return e * (sine(400 + Math.sin(t * 30) * 100, t) * 0.5 + noise() * 0.2);
  }),

  // 천둥 — 충격파
  weapon_cheondung: () => generate(0.4, t => {
    const e = envelope(t, 0.001, 0.15, 0.3, 0.15, 0.4);
    return e * (sine(120 - t * 100, t) * 0.6 + noise() * 0.5);
  }),

  // 풍경 — 바람 소리
  weapon_punggyeong: () => generate(0.35, t => {
    const e = envelope(t, 0.02, 0.1, 0.5, 0.15, 0.35);
    return e * (noise() * 0.3 + sine(600 + Math.sin(t * 8) * 200, t) * 0.3);
  }),

  // 청룡도 — 무거운 참격
  weapon_cheongryongdo: () => generate(0.25, t => {
    const e = envelope(t, 0.003, 0.1, 0.3, 0.08, 0.25);
    return e * (sine(300 - t * 800, t) * 0.5 + noise() * 0.35);
  }),

  // 금강저 — 금속 타격 + 반향
  weapon_geumgangeo: () => generate(0.3, t => {
    const e = envelope(t, 0.001, 0.05, 0.4, 0.15, 0.3);
    return e * (sine(700 + Math.sin(t * 50) * 200, t) * 0.4 + sine(1400, t) * 0.2 + noise() * 0.1);
  }),

  // 신성 방울 — 맑은 종소리
  weapon_sinseong_bangul: () => generate(0.4, t => {
    const e = envelope(t, 0.002, 0.05, 0.5, 0.2, 0.4);
    return e * (sine(1800, t) * 0.3 + sine(2700, t) * 0.15 + sine(3600, t) * 0.08);
  }),

  // 풍물북 — 둥둥 드럼
  weapon_pungmul_buk: () => generate(0.25, t => {
    const e = envelope(t, 0.002, 0.08, 0.2, 0.1, 0.25);
    return e * (sine(100 - t * 200, t) * 0.6 + noise() * 0.25);
  }),

  // 요기 발톱 — 빠른 할퀴기
  weapon_yogi_baltop: () => generate(0.12, t => {
    const e = envelope(t, 0.001, 0.03, 0.3, 0.04, 0.12);
    return e * (noise() * 0.5 + sine(1500 - t * 5000, t) * 0.3);
  }),

  // 팔괘진 — 회전하는 에너지
  weapon_palgwaejin: () => generate(0.3, t => {
    const e = envelope(t, 0.01, 0.08, 0.4, 0.12, 0.3);
    return e * (sine(500 + Math.sin(t * 20) * 300, t) * 0.4 + sine(1000, t) * 0.15);
  }),

  // 화살 — 날카로운 슈우웅
  weapon_hwasal: () => generate(0.15, t => {
    const e = envelope(t, 0.002, 0.04, 0.3, 0.05, 0.15);
    return e * (sine(1000 - t * 4000, t) * 0.4 + noise() * 0.2);
  }),

  // 독깡패 — 도깨비 방망이 타격
  weapon_dokangae: () => generate(0.2, t => {
    const e = envelope(t, 0.003, 0.06, 0.3, 0.08, 0.2);
    return e * (sine(250 - t * 500, t) * 0.5 + sine(500, t) * 0.2 + noise() * 0.2);
  }),

  // 돌팔매 — 돌 날아가는 소리
  weapon_dolpalmae: () => generate(0.18, t => {
    const e = envelope(t, 0.005, 0.05, 0.3, 0.06, 0.18);
    return e * (sine(600 - t * 2000, t) * 0.35 + noise() * 0.25);
  }),

  // 범용 무기 발사
  weapon_generic: () => generate(0.12, t => {
    const e = envelope(t, 0.003, 0.04, 0.3, 0.04, 0.12);
    return e * sine(900 - t * 4000, t) * 0.5;
  }),

  // 적 피격
  enemy_hit: () => generate(0.1, t => {
    const e = envelope(t, 0.001, 0.03, 0.3, 0.03, 0.1);
    return e * (sine(300, t) * 0.4 + noise() * 0.3);
  }),

  // 적 사망 — 터지는 느낌
  enemy_death: () => generate(0.25, t => {
    const e = envelope(t, 0.002, 0.08, 0.2, 0.1, 0.25);
    return e * (sine(200 - t * 600, t) * 0.4 + noise() * 0.4);
  }),

  // 레벨업 — 상승 멜로디
  level_up: () => generate(0.6, t => {
    const e = envelope(t, 0.01, 0.1, 0.6, 0.2, 0.6);
    const freq = t < 0.2 ? 523 : t < 0.4 ? 659 : 784; // C5 E5 G5
    return e * sine(freq, t) * 0.5;
  }),

  // 상자 오픈 — 잠금 해제 소리
  chest_open: () => generate(0.5, t => {
    const e = envelope(t, 0.005, 0.1, 0.5, 0.2, 0.5);
    const freq = 440 + t * 600;
    return e * (sine(freq, t) * 0.4 + sine(freq * 1.5, t) * 0.2);
  }),

  // 보스 등장 — 저음 경고
  boss_appear: () => generate(1.0, t => {
    const e = envelope(t, 0.05, 0.3, 0.5, 0.3, 1.0);
    return e * (sine(80 + Math.sin(t * 3) * 20, t) * 0.6 + sine(160, t) * 0.2 + noise() * 0.1);
  }),

  // 경험치 수집 — 짧은 핑
  exp_collect: () => generate(0.08, t => {
    const e = envelope(t, 0.002, 0.02, 0.3, 0.02, 0.08);
    return e * sine(1400 + t * 2000, t) * 0.35;
  }),

  // 진화 — 웅장한 상승음
  evolution: () => generate(1.2, t => {
    const e = envelope(t, 0.02, 0.2, 0.6, 0.4, 1.2);
    const sweep = 300 + t * 500;
    return e * (sine(sweep, t) * 0.35 + sine(sweep * 1.5, t) * 0.2 + sine(sweep * 2, t) * 0.1);
  }),

  // 플레이어 피격
  player_hit: () => generate(0.15, t => {
    const e = envelope(t, 0.001, 0.05, 0.3, 0.05, 0.15);
    return e * (sine(250 - t * 800, t) * 0.5 + noise() * 0.3);
  }),

  // 버튼 클릭
  ui_click: () => generate(0.06, t => {
    const e = envelope(t, 0.001, 0.02, 0.3, 0.02, 0.06);
    return e * sine(1000, t) * 0.3;
  }),
};

// ═══════════════════════════════════════════
//  BGM — 짧은 루프 (placeholder)
// ═══════════════════════════════════════════

function generateBgmLoop(duration, baseTone, mood) {
  // 간단한 반복 멜로디 WAV (mp3 변환은 나중에)
  return generate(duration, t => {
    const beat = t % 0.5;
    const measure = t % 2.0;
    let val = 0;

    // 드론 베이스
    val += sine(baseTone, t) * 0.15;
    val += sine(baseTone * 1.5, t) * 0.08;

    // 리듬
    if (beat < 0.05) val += noise() * 0.15;

    // 멜로디 (펜타토닉)
    const penta = [1, 1.125, 1.25, 1.5, 1.667]; // 궁상각치우 비율
    const noteIdx = Math.floor((measure / 2.0) * 4) % penta.length;
    const noteFreq = baseTone * 2 * penta[noteIdx];
    const noteEnv = envelope(beat, 0.01, 0.1, 0.3, 0.1, 0.4);
    val += sine(noteFreq, t) * noteEnv * 0.2;

    // 전체 볼륨
    return val * 0.7;
  });
}

const bgm = {
  stage_1: () => generateBgmLoop(8, 110, 'dark'),     // 8초 루프
  stage_boss: () => generateBgmLoop(8, 82, 'intense'), // 보스전
  title: () => generateBgmLoop(8, 146, 'mystical'),    // 타이틀
};

// ═══════════════════════════════════════════
//  파일 생성
// ═══════════════════════════════════════════

const sfxDir = path.join(__dirname, '..', 'assets', 'audio', 'sfx');
const bgmDir = path.join(__dirname, '..', 'assets', 'audio', 'bgm');

// SFX
for (const [name, fn] of Object.entries(sfx)) {
  const samples = fn();
  const wav = createWav(samples);
  const filePath = path.join(sfxDir, `${name}.wav`);
  fs.writeFileSync(filePath, wav);
  console.log(`SFX: ${name}.wav (${(wav.length / 1024).toFixed(1)}KB)`);
}

// BGM (WAV로 저장 — flame_audio가 wav도 재생 가능)
for (const [name, fn] of Object.entries(bgm)) {
  const samples = fn();
  const wav = createWav(samples);
  // mp3 대신 wav로 저장하고, audio_service에서 확장자 수정 필요
  const filePath = path.join(bgmDir, `${name}.wav`);
  fs.writeFileSync(filePath, wav);
  console.log(`BGM: ${name}.wav (${(wav.length / 1024).toFixed(1)}KB)`);
}

console.log('\nDone! All audio assets generated.');
