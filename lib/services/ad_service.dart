/// 리워드 광고 서비스 (google_mobile_ads 연동 준비)
///
/// 출시 전 google_mobile_ads 패키지 추가 후 실제 광고 로드/표시 로직으로 교체.
/// 현재는 테스트용으로 항상 광고 준비 완료 상태를 반환.
class AdService {
  static final AdService instance = AdService._();
  AdService._();

  bool _initialized = false;
  bool _rewardedAdReady = false;

  /// 초기화 (main에서 호출)
  Future<void> init() async {
    // TODO: MobileAds.instance.initialize()
    _initialized = true;
    _rewardedAdReady = true; // 테스트 모드: 항상 준비됨
  }

  /// 리워드 광고 준비 여부
  bool get isRewardedAdReady => _initialized && _rewardedAdReady;

  /// 리워드 광고 로드
  void loadRewardedAd() {
    // TODO: RewardedAd.load(...)
    _rewardedAdReady = true;
  }

  /// 리워드 광고 표시 + 보상 콜백
  void showRewardedAd({required void Function(RewardType type, int amount) onReward}) {
    if (!isRewardedAdReady) return;

    // TODO: 실제 광고 표시 로직
    // 테스트 모드: 즉시 보상 지급
    _rewardedAdReady = false;
    onReward(RewardType.coins, 200);

    // 다음 광고 미리 로드
    loadRewardedAd();
  }
}

enum RewardType {
  coins,        // 엽전 보상
  soulStones,   // 귀혼석 보상
  revive,       // 부활 보상
  doubleReward, // 보상 2배
}
