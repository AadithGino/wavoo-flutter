import 'package:get/get.dart';

import '../core/network/api_exception.dart';
import '../core/utils/money.dart';
import '../data/repositories/profile_repository.dart';

class HomeController extends GetxController {
  HomeController({required ProfileRepository repository}) : _repository = repository;

  final ProfileRepository _repository;

  final isLoading = false.obs;
  final loadError = RxnString();
  final goldRatePaisePerGram = RxnInt();
  final goldRateLabel = RxnString();

  Future<void> load() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final home = await _repository.fetchHome();
      var applied = false;
      if (home != null) {
        applied = _applyGoldRate(home['currentGoldRate']);
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
