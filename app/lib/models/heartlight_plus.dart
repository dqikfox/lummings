/// Heartlight Plus — soft subscription. Core bond is NEVER paywalled.
class HeartlightPlusTier {
  final String id;
  final String title;
  final String priceLabel;
  final String blurb;
  final List<String> perks;

  const HeartlightPlusTier({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.blurb,
    required this.perks,
  });

  static const free = HeartlightPlusTier(
    id: 'free',
    title: 'Nest Free',
    priceLabel: '\$0',
    blurb: 'Full Heartlight bond, Care, Talk, Adventures, and Charms. Forever.',
    perks: [
      'All five Lummings & Heartlight essence',
      'Daily Care ritual + soft miss hooks',
      'Growing Together adventures',
      'Charm collection (earn with shards)',
      'Parent PIN + soft screen-time',
    ],
  );

  static const plus = HeartlightPlusTier(
    id: 'plus',
    title: 'Heartlight Plus',
    priceLabel: '\$4.99/mo',
    blurb: 'Cosmetic glows & early stories. Never required for bond growth.',
    perks: [
      'Radiant trail particles on Care',
      'Extra daily Festival spark',
      'Plus commemorative charms',
      'Early access story packs',
      'Custom nest theme tints',
    ],
  );

  static const family = HeartlightPlusTier(
    id: 'family',
    title: 'Nest Family',
    priceLabel: '\$7.99/mo',
    blurb: 'Up to 4 child profiles sharing one parent dashboard.',
    perks: [
      'Everything in Heartlight Plus',
      'Up to 4 kid profiles',
      'Shared Parent Dashboard',
      'Family Festival weekends',
    ],
  );

  static const catalog = [free, plus, family];
}
