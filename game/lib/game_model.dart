/// Pure Dart economy / state machine for RENT DUE! — One Month, Run It Back.
///
/// No Flutter imports. No randomness anywhere: the month is deterministic —
/// same paychecks, same shocks, same order, every run (Run It Back design).
library;

/// Ending classification for a finished run.
enum Ending { nothingOwed, onTheCard, rentShort }

/// How the Week 2 bike shock ($180) was resolved.
enum BikeChoice { buffer, weekCash, card, bus }

/// How the Week 4 phone shock ($90) was resolved.
enum PhoneChoice { weekCash, card, cracked }

/// Night-out dilemma (Week 1).
enum NightOutChoice { go, cheaper, skip }

/// One step of the Shortfall Cascade, in the fixed order Jar → Week Cash.
/// The card is never a cascade step: rent is paid by bank transfer, so
/// the card can't cover rent. (Oct 23 mechanics change, approved.)
class CascadeStep {
  CascadeStep(this.source, this.amount);
  final String source; // 'Buffer Jar' | 'Week Cash'
  final int amount;
}

/// What happened financially when a week started (before the split).
class PaycheckInfo {
  PaycheckInfo(this.gross, this.interestAdded, this.minPayment);
  final int gross;
  final int interestAdded;
  final int minPayment;
  int get net => gross - minPayment;
}

/// Immutable snapshot of a finished run, used by Reveal / Comparison.
class RunSummary {
  RunSummary({
    required this.ending,
    required this.rentPaid,
    required this.cardBalance,
    required this.bufferLeft,
    required this.rentPaidAmount,
    required this.shockChargedToCard,
    required this.shockPaidFromJar,
    required this.interestCharged,
    required this.phoneKeptCracked,
    required this.timeline,
  });
  final Ending ending;
  final bool rentPaid;
  final int cardBalance;
  final int bufferLeft;
  final int rentPaidAmount;
  final int shockChargedToCard;
  final int shockPaidFromJar;
  final int interestCharged;
  final bool phoneKeptCracked;
  final List<String> timeline;
}

class GameModel {
  // ---- Fixed balancing (realistic economy, approved Oct 23) ----
  // Take-home pay for a barista on variable shifts; Week 3 is the
  // short-shift week (−90 vs Week 2). Total for the month: $1,765.
  static const int rentDue = 900;
  static const List<int> paychecks = [455, 470, 380, 460];
  // $160/wk, itemized in the UI: groceries $75, utilities ≈$42,
  // phone ≈$13, bus pass ≈$12, laundry/toiletries ≈$18.
  static const int weeklyEssentials = 160;
  static const int bikeCost = 180;
  static const int phoneCost = 90;
  static const int busPassCost = 30;
  static const int busLateFee = 45;
  static const int gigNetGain = 50; // +80 pay − 30 costs
  static const int minPaymentAmount = 25;
  static const int cardLimit = 500;

  /// Interest: $12 per full $100 owed, applied at the start of Weeks 3 and 4
  /// if a balance exists. Simplified for play.
  static int interestFor(int balance) => (balance ~/ 100) * 12;

  // ---- State ----
  int week = 0; // 1..4 once started
  int rentTin = 0;
  int bufferJar = 0;
  int weekCash = 0;
  int cardBalance = 0;

  int _pendingNetPaycheck = 0;
  bool _splitPending = false;

  bool busLateFeePending = false;
  bool bikeBroken = false;
  bool phoneKeptCracked = false;
  bool rentPaid = false;

  // Tracking for The Reveal / timeline (numbers only, no judgements).
  int totalInterestCharged = 0;
  int shockChargedToCard = 0;
  int shockPaidFromJar = 0;
  final List<String> timeline = [];

  // Cascade plan (prepared at rent day, applied step by step by the player).
  List<CascadeStep> _cascadePlan = [];
  int _cascadeIndex = 0;
  bool _cascadePrepared = false;

  int get pendingNetPaycheck => _pendingNetPaycheck;
  bool get splitPending => _splitPending;
  bool get cascadePrepared => _cascadePrepared;
  List<CascadeStep> get cascadePlan => List.unmodifiable(_cascadePlan);
  int get cascadeIndex => _cascadeIndex;
  bool get cascadeDone => _cascadePrepared && _cascadeIndex >= _cascadePlan.length;

  /// Card colour band by balance: 0 = cool, 1 = warm, 2 = hot.
  int get cardBand => cardBalance == 0 ? 0 : (cardBalance <= 200 ? 1 : 2);

  /// Buffer Jar fill level, 0..5 (display only).
  int get jarLevel {
    final lvl = (bufferJar / 120).ceil();
    return lvl > 5 ? 5 : lvl;
  }

  /// Starts [w] (1-based). Applies, in order, Week 3/4 interest and then the
  /// card minimum payment taken out of the paycheck before the split.
  PaycheckInfo startWeek(int w) {
    week = w;
    final gross = paychecks[w - 1];
    var interest = 0;
    var minPayment = 0;
    if ((w == 3 || w == 4) && cardBalance > 0) {
      interest = interestFor(cardBalance);
      if (interest > 0) {
        cardBalance += interest;
        totalInterestCharged += interest;
        timeline.add('Week $w: card interest +\$$interest → card \$$cardBalance');
      }
      minPayment = cardBalance < minPaymentAmount ? cardBalance : minPaymentAmount;
      cardBalance -= minPayment;
      timeline.add('Week $w: card minimum payment \$$minPayment taken from paycheck');
    }
    _pendingNetPaycheck = gross - minPayment;
    _splitPending = true;
    return PaycheckInfo(gross, interest, minPayment);
  }

  /// Allocates the pending net paycheck. Must allocate every dollar exactly.
  bool applySplit({required int toTin, required int toJar, required int toWeek}) {
    if (!_splitPending) return false;
    if (toTin < 0 || toJar < 0 || toWeek < 0) return false;
    if (toTin + toJar + toWeek != _pendingNetPaycheck) return false;
    rentTin += toTin;
    bufferJar += toJar;
    weekCash += toWeek;
    _splitPending = false;
    timeline.add('Week $week: split +\$$toTin tin, +\$$toJar jar, +\$$toWeek cash');
    return true;
  }

  /// Weekly essentials ($160) leave Week Cash right after the split.
  /// Returns the amount that had to go on the Card (0 if cash covered it).
  int applyEssentials() {
    if (weekCash >= weeklyEssentials) {
      weekCash -= weeklyEssentials;
      timeline.add('Week $week: essentials \$$weeklyEssentials from Week Cash');
      return 0;
    }
    final short = weeklyEssentials - weekCash;
    weekCash = 0;
    cardBalance += short;
    timeline.add('Week $week: essentials short by \$$short → put on card');
    return short;
  }

  /// Charges [amount] to the card, capped by the card limit.
  /// Returns the amount actually charged.
  int chargeToCard(int amount) {
    final room = cardLimit - cardBalance;
    final charged = amount > room ? room : amount;
    if (charged > 0) cardBalance += charged;
    return charged;
  }

  // ---- Week 1 dilemma ----
  /// Pays [cost] from Week Cash; any remainder goes on the Card.
  /// Returns the amount put on the Card.
  int _payFromWeekCashOrCard(int cost) {
    if (weekCash >= cost) {
      weekCash -= cost;
      return 0;
    }
    final rest = cost - weekCash;
    weekCash = 0;
    chargeToCard(rest);
    return rest;
  }

  void applyNightOut(NightOutChoice choice) {
    final cost = switch (choice) {
      NightOutChoice.go => 60,
      NightOutChoice.cheaper => 25,
      NightOutChoice.skip => 0,
    };
    if (cost > 0) _payFromWeekCashOrCard(cost);
    timeline.add('Week 1: night out — ${choice.name} (\$$cost)');
  }

  // ---- Week 2 shock: bike ----
  /// Applies the bike resolution. For [BikeChoice.buffer] / [.weekCash],
  /// returns false (no change) if that source cannot cover the full $180.
  bool applyBike(BikeChoice choice) {
    switch (choice) {
      case BikeChoice.buffer:
        if (bufferJar < bikeCost) return false;
        bufferJar -= bikeCost;
        shockPaidFromJar += bikeCost;
        timeline.add('Week 2: bike \$$bikeCost paid from Buffer Jar');
        return true;
      case BikeChoice.weekCash:
        if (weekCash < bikeCost) return false;
        weekCash -= bikeCost;
        timeline.add('Week 2: bike \$$bikeCost paid from Week Cash');
        return true;
      case BikeChoice.card:
        chargeToCard(bikeCost);
        shockChargedToCard += bikeCost;
        timeline.add('Week 2: bike \$$bikeCost put on the card');
        return true;
      case BikeChoice.bus:
        bikeBroken = true;
        busLateFeePending = true;
        final onCard = _payFromWeekCashOrCard(busPassCost);
        timeline.add('Week 2: bus pass \$$busPassCost'
            '${onCard > 0 ? ' (\$$onCard on card)' : ''}; bike left broken');
        return true;
    }
  }

  /// The $45 late-shift fee from the bus choice lands in Week 4.
  /// Returns the amount that went on the Card.
  int applyBusLateFee() {
    if (!busLateFeePending) return 0;
    busLateFeePending = false;
    final onCard = _payFromWeekCashOrCard(busLateFee);
    timeline.add('Week 4: late-shift fee \$$busLateFee'
        '${onCard > 0 ? ' (\$$onCard on card)' : ''}');
    return onCard;
  }

  // ---- Week 3 choice: side gig ----
  void applyGig(bool takeIt) {
    if (takeIt) {
      weekCash += gigNetGain;
      timeline.add('Week 3: side gig +\$$gigNetGain net to Week Cash');
    } else {
      timeline.add('Week 3: side gig — rested');
    }
  }

  // ---- Week 4 shock: phone ----
  void applyPhone(PhoneChoice choice) {
    switch (choice) {
      case PhoneChoice.weekCash:
        final onCard = _payFromWeekCashOrCard(phoneCost);
        timeline.add('Week 4: phone screen \$$phoneCost fixed'
            '${onCard > 0 ? ' (\$$onCard on card)' : ''}');
      case PhoneChoice.card:
        chargeToCard(phoneCost);
        shockChargedToCard += phoneCost;
        timeline.add('Week 4: phone screen \$$phoneCost put on the card');
      case PhoneChoice.cracked:
        phoneKeptCracked = true;
        timeline.add('Week 4: phone screen — living with the crack (\$0)');
    }
  }

  // ---- Rent day: Shortfall Cascade ----
  int get rentShortfall => rentDue - rentTin > 0 ? rentDue - rentTin : 0;

  /// Builds the cascade plan in the fixed order Jar → Week Cash.
  /// The card never pays rent (rent goes out by bank transfer), so if
  /// jar + cash can't cover the shortfall, the run ends Rent Short.
  /// Call once when rent day arrives with a shortfall.
  List<CascadeStep> prepareCascade() {
    _cascadePlan = [];
    _cascadeIndex = 0;
    var remaining = rentShortfall;
    if (remaining > 0 && bufferJar > 0) {
      final amt = bufferJar < remaining ? bufferJar : remaining;
      _cascadePlan.add(CascadeStep('Buffer Jar', amt));
      remaining -= amt;
    }
    if (remaining > 0 && weekCash > 0) {
      final amt = weekCash < remaining ? weekCash : remaining;
      _cascadePlan.add(CascadeStep('Week Cash', amt));
      remaining -= amt;
    }
    _cascadePrepared = true;
    return _cascadePlan;
  }

  /// Applies the next planned cascade step. Returns it, or null when done.
  CascadeStep? applyNextCascadeStep() {
    if (!_cascadePrepared || _cascadeIndex >= _cascadePlan.length) return null;
    final step = _cascadePlan[_cascadeIndex++];
    switch (step.source) {
      case 'Buffer Jar':
        bufferJar -= step.amount;
        rentTin += step.amount;
      case 'Week Cash':
        weekCash -= step.amount;
        rentTin += step.amount;
    }
    timeline.add('Rent day: cascade — ${step.source} → \$${step.amount} to rent');
    return step;
  }

  /// Settles rent once the tin is full or the cascade is exhausted.
  bool settleRent() {
    rentPaid = rentTin >= rentDue;
    return rentPaid;
  }

  /// Ending classification:
  /// not paid → rentShort; paid with a card balance → onTheCard;
  /// paid owing nothing → nothingOwed. The Buffer Jar amount does not
  /// gate the ending — an empty jar that absorbed the shocks did its
  /// job; the amount left is still reported in the summary.
  Ending classifyEnding() {
    if (!rentPaid) return Ending.rentShort;
    if (cardBalance > 0) return Ending.onTheCard;
    return Ending.nothingOwed;
  }

  RunSummary summary() {
    return RunSummary(
      ending: classifyEnding(),
      rentPaid: rentPaid,
      cardBalance: cardBalance,
      bufferLeft: bufferJar,
      rentPaidAmount: rentTin > rentDue ? rentDue : rentTin,
      shockChargedToCard: shockChargedToCard,
      shockPaidFromJar: shockPaidFromJar,
      interestCharged: totalInterestCharged,
      phoneKeptCracked: phoneKeptCracked,
      timeline: List.unmodifiable(timeline),
    );
  }
}
