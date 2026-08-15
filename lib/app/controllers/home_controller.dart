import 'package:get/get.dart';

import '../core/network/api_exception.dart';
import '../core/utils/money.dart';
import '../data/models/activity.dart';
import '../data/models/scheme.dart';
import '../data/repositories/profile_repository.dart';

class HomeController extends GetxController {
  HomeController({required ProfileRepository repository}) : _repository = repository;

  final ProfileRepository _repository;

  final isLoading = false.obs;
  final loadError = RxnString();
  final goldRatePaisePerGram = RxnInt();
  final goldRateLabel = RxnString();
  final schemesInProgress = <SchemeEnrollment>[].obs;
  final schemesRedeemable = <SchemeEnrollment>[].obs;
  final schemesPastPreview = <SchemeEnrollment>[].obs;
  final recentActivity = <CustomerActivity>[].obs;
  final historySummary = Rxn<HistorySummary>();

  Future<void> load() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final home = await _repository.fetchHome();
      var applied = false;
      if (home != null) {
        applied = _applyGoldRate(home['currentGoldRate']);
        schemesInProgress.assignAll(_enrollments(home['schemesInProgress']));
        schemesRedeemable.assignAll(_enrollments(home['schemesRedeemable']));
        schemesPastPreview.assignAll(_enrollments(home['schemesPastPreview']));
        recentActivity.assignAll(_activity(home['recentActivity']));
        if (home['historySummary'] is Map) {
          historySummary.value = HistorySummary.fromJson(
            Map<String, dynamic>.from(home['historySummary'] as Map),
          );
        }
      }
      if (!applied) {
        final fallback = await _repository.fetchLatestGoldRate();
        _applyGoldRate(fallback);
      }
    } on ApiException catch (e) {
      loadError.value = e.message;
    } catch (e) {
      loadError.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void reset() {
    goldRatePaisePerGram.value = null;
    goldRateLabel.value = null;
    loadError.value = null;
    schemesInProgress.clear();
    schemesRedeemable.clear();
    schemesPastPreview.clear();
    recentActivity.clear();
    historySummary.value = null;
  }

  List<SchemeEnrollment> _enrollments(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => SchemeEnrollment.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.enrollmentId.isNotEmpty)
        .toList();
  }

  List<CustomerActivity> _activity(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => CustomerActivity.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  bool _applyGoldRate(dynamic rate) {
    if (rate is Map) {
      final paise = (rate['ratePerGramPaise'] as num?)?.toInt() ??
          (rate['ratePaisePerGram'] as num?)?.toInt() ??
          (rate['paisePerGram'] as num?)?.toInt() ??
          (rate['ratePaise'] as num?)?.toInt();
      if (paise != null && paise > 0) {
        goldRatePaisePerGram.value = paise;
        final purity = rate['purityLabel']?.toString() ??
            rate['purity']?.toString() ??
            '22K';
        goldRateLabel.value = "Today's $purity · ${Money.fromPaise(paise)}/g";
        return true;
      }
    } else if (rate is num && rate > 0) {
      goldRatePaisePerGram.value = rate.toInt();
      goldRateLabel.value = "Today's gold · ${Money.fromPaise(rate.toInt())}/g";
      return true;
    }
    return false;
  }
}
