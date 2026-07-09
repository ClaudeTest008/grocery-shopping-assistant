import 'offer.dart';

abstract interface class OfferRepository {
  Future<List<Offer>> activeOffers({String? storeId});
}
