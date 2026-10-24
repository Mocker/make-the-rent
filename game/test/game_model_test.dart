import 'package:flutter_test/flutter_test.dart';
import 'package:rent_due/game_model.dart';

/// Runs one week's split + essentials on [m] (week must already be started).
void splitWeek(GameModel m, int tin, int jar, int week) {
  expect(m.applySplit(toTin: tin, toJar: jar, toWeek: week), isTrue);
  m.applyEssentials();
}

/// A careful month under the realistic economy: steady tin splits, jar
/// built to $180 before the Week 2 bike shock, cheap night out, gig
/// taken, phone lived with. Hand-computed expectations throughout.
GameModel playCarefulMonth() {
  final m = GameModel();
  // W1: $455 → 200 tin / 90 jar / 165 cash; essentials −160 leaves $5;
  // night out cheaper ($25) pays $5 cash + $20 on the card.
  m.startWeek(1);
  splitWeek(m, 200, 90, 165);
  m.applyNightOut(NightOutChoice.cheaper);
  expect(m.cardBalance, 20);
  // W2: $470 → 210/90/170; jar reaches exactly $180; bike from the jar.
  m.startWeek(2);
  splitWeek(m, 210, 90, 170);
  expect(m.bufferJar, 180);
  expect(m.applyBike(BikeChoice.buffer), isTrue);
  // W3: $380 short paycheck; the $20 card balance is cleared by the
  // minimum payment (net $360). Split 230/5/125; essentials are $25
  // short and go on the card; gig adds $50 to Week Cash.
  final info3 = m.startWeek(3);
  expect(info3.minPayment, 20);
  expect(info3.net, 360);
  splitWeek(m, 230, 5, 125);
  expect(m.cardBalance, 25);
  m.applyGig(true);
  // W4: $460; minimum payment clears the $25 (net $435).
  // Split 260/15/160 fills the tin to exactly $900; phone left cracked.
  final info4 = m.startWeek(4);
  expect(info4.minPayment, 25);
  expect(info4.net, 435);
  splitWeek(m, 260, 15, 160);
  m.applyPhone(PhoneChoice.cracked);
  return m;
}

void main() {
  group('interest', () {
    test('is \$12 per full \$100 owed', () {
      expect(GameModel.interestFor(0), 0);
      expect(GameModel.interestFor(99), 0);
      expect(GameModel.interestFor(100), 12);
      expect(GameModel.interestFor(180), 12);
      expect(GameModel.interestFor(250), 24);
    });
  });

  group('minimum payment', () {
    test('Week 3: interest lands first, then \$25 comes out of the paycheck',
        () {
      final m = GameModel();
      m.chargeToCard(180);
      final info = m.startWeek(3);
      expect(info.gross, 380);
      expect(info.interestAdded, 12); // 180 → 192
      expect(info.minPayment, 25); // 192 → 167
      expect(info.net, 355);
      expect(m.cardBalance, 167);
      expect(m.pendingNetPaycheck, 355);
    });

    test('minimum payment is the full balance when it is under \$25', () {
      final m = GameModel();
      m.chargeToCard(10);
      final info = m.startWeek(4);
      expect(info.minPayment, 10);
      expect(m.cardBalance, 0);
      expect(info.net, 450);
    });

    test('no interest or minimum payment in Weeks 1–2', () {
      final m = GameModel();
      m.chargeToCard(300);
      final info = m.startWeek(2);
      expect(info.interestAdded, 0);
      expect(info.minPayment, 0);
      expect(info.net, 470);
    });
  });

  group('split and essentials', () {
    test('split must allocate the whole paycheck exactly', () {
      final m = GameModel();
      m.startWeek(1);
      expect(m.applySplit(toTin: 100, toJar: 100, toWeek: 100), isFalse);
      expect(m.applySplit(toTin: 200, toJar: 90, toWeek: 165), isTrue);
    });

    test('essentials shortfall goes on the card, plainly', () {
      final m = GameModel();
      m.startWeek(1);
      expect(m.applySplit(toTin: 455, toJar: 0, toWeek: 0), isTrue);
      final onCard = m.applyEssentials();
      expect(onCard, 160);
      expect(m.weekCash, 0);
      expect(m.cardBalance, 160);
    });
  });

  group('shocks', () {
    test('bike from the jar needs the jar to actually cover it', () {
      final m = GameModel();
      m.startWeek(1);
      splitWeek(m, 195, 100, 160);
      expect(m.applyBike(BikeChoice.buffer), isFalse); // jar only has 100
      expect(m.bufferJar, 100);
    });

    test('bus choice: \$30 now, \$45 fee lands in Week 4', () {
      final m = GameModel();
      m.startWeek(1);
      splitWeek(m, 0, 0, 455); // week cash 295 after essentials
      expect(m.applyBike(BikeChoice.bus), isTrue);
      expect(m.weekCash, 265);
      expect(m.busLateFeePending, isTrue);
      final onCard = m.applyBusLateFee();
      expect(onCard, 0);
      expect(m.weekCash, 220);
      expect(m.busLateFeePending, isFalse);
    });
  });

  group('cascade', () {
    test('order is Jar → Week Cash, amounts capped by the shortfall', () {
      final m = GameModel();
      m.rentTin = 400;
      m.bufferJar = 200;
      m.weekCash = 500;
      m.cardBalance = 100;
      final plan = m.prepareCascade();
      // Shortfall is 500: jar (200) then Week Cash (300) covers it exactly.
      expect(plan.map((s) => s.source).toList(), ['Buffer Jar', 'Week Cash']);
      expect(plan.map((s) => s.amount).toList(), [200, 300]);
      while (!m.cascadeDone) {
        m.applyNextCascadeStep();
      }
      expect(m.rentTin, 900);
      expect(m.settleRent(), isTrue);
      // The cascade never touches the card.
      expect(m.cardBalance, 100);
    });

    test('shortfall exactly covered by jar + cash → paid, card untouched',
        () {
      final m = GameModel();
      m.rentTin = 400;
      m.bufferJar = 200;
      m.weekCash = 300;
      m.cardBalance = 150; // balance exists, plenty of room — irrelevant now
      final plan = m.prepareCascade();
      expect(plan.map((s) => s.source).toList(), ['Buffer Jar', 'Week Cash']);
      expect(plan.map((s) => s.amount).toList(), [200, 300]);
      while (!m.cascadeDone) {
        m.applyNextCascadeStep();
      }
      expect(m.rentTin, 900);
      expect(m.settleRent(), isTrue);
      expect(m.cardBalance, 150);
    });

    // Oct 23 mechanics change: rent is paid by bank transfer, so the
    // card never pays rent — card room no longer rescues a shortfall.
    test('plenty of card room no longer rescues a shortfall → Rent Short',
        () {
      final m = GameModel();
      m.rentTin = 100;
      m.bufferJar = 50;
      m.weekCash = 100;
      m.cardBalance = 0; // the full $500 of card room is available
      final plan = m.prepareCascade();
      // Shortfall is 800; jar + cash cover only 150 of it, and there
      // is no Card step to cover the rest.
      expect(plan.map((s) => s.source).toList(), ['Buffer Jar', 'Week Cash']);
      expect(plan.map((s) => s.amount).toList(), [50, 100]);
      while (!m.cascadeDone) {
        m.applyNextCascadeStep();
      }
      expect(m.rentTin, 250);
      expect(m.cardBalance, 0); // untouched by the cascade
      expect(m.settleRent(), isFalse);
      expect(m.classifyEnding(), Ending.rentShort);
    });
  });

  group('endings via full deterministic playthroughs', () {
    test('careful line reaches Rent Paid, Nothing Owed', () {
      final m = playCarefulMonth();
      expect(m.rentTin, 900);
      expect(m.rentShortfall, 0);
      expect(m.settleRent(), isTrue);
      final s = m.summary();
      expect(s.ending, Ending.nothingOwed);
      expect(s.rentPaid, isTrue);
      expect(s.cardBalance, 0);
      // Buffer is reported but does not gate the ending: the jar did
      // its job on the bike and ends at $20.
      expect(s.bufferLeft, 20);
      expect(s.shockPaidFromJar, 180);
      expect(s.interestCharged, 0);
      expect(s.phoneKeptCracked, isTrue);
    });

    test('careless line reaches Rent Paid, On The Card via the cascade', () {
      final m = GameModel();
      // W1: thin tin, night out in full.
      m.startWeek(1);
      splitWeek(m, 100, 0, 355);
      m.applyNightOut(NightOutChoice.go);
      // W2: bike goes on the card.
      m.startWeek(2);
      splitWeek(m, 100, 0, 370);
      expect(m.applyBike(BikeChoice.card), isTrue);
      expect(m.cardBalance, 180);
      // W3: interest 12, minimum 25, net 355.
      final info3 = m.startWeek(3);
      expect(info3.net, 355);
      splitWeek(m, 100, 0, 255);
      m.applyGig(false);
      // W4: interest 12 again, minimum 25, net 435; phone on the card.
      final info4 = m.startWeek(4);
      expect(info4.net, 435);
      splitWeek(m, 100, 0, 335);
      m.applyPhone(PhoneChoice.card);
      expect(m.cardBalance, 244);
      // Rent day: tin is 400, shortfall 500 — all from Week Cash.
      expect(m.rentShortfall, 500);
      final plan = m.prepareCascade();
      expect(plan, hasLength(1));
      expect(plan.single.source, 'Week Cash');
      expect(plan.single.amount, 500);
      while (!m.cascadeDone) {
        m.applyNextCascadeStep();
      }
      expect(m.settleRent(), isTrue);
      final s = m.summary();
      expect(s.ending, Ending.onTheCard);
      expect(s.cardBalance, 244);
      expect(s.bufferLeft, 0);
      expect(s.interestCharged, 24);
      expect(s.shockChargedToCard, 270); // bike 180 + phone 90
    });

    // Even the maximum-destruction line still lands On The Card —
    // not because Rent Short is unreachable (it isn't, since the
    // Oct 23 cascade change took the card out of the rent backstop:
    // see the cash-absorb line below), but because this line parks
    // its splits in the Rent Tin itself, so the tin covers rent in
    // full while the card maxes out on overflow and interest.
    //
    // Historical note: before that change, Rent Short was
    // unreachable by ANY line — the card backstopped rent, value
    // only left via essentials ($640, fixed), the night out (≤$60),
    // the bike (≤$180), the phone (≤$90) and card interest (≤$132),
    // so maximum destruction of $1,102 against $1,765 income + $500
    // card room always left ≥$1,163 accessible, $263 over the rent.
    // With the card out of the cascade, where the money sits matters
    // again — money on the card can't pay the landlord.
    test('maximum spiral lands On The Card (its money sat in the tin)', () {
      final m = GameModel();
      // W1: everything to the tin, Week Cash starved — essentials
      // overflow $160 to the card; night out in full, also on the card.
      m.startWeek(1);
      splitWeek(m, 455, 0, 0);
      expect(m.cardBalance, 160);
      m.applyNightOut(NightOutChoice.go);
      expect(m.cardBalance, 220);
      // W2: essentials overflow again ($380); bike charged — only $120
      // fits under the $500 limit, capping the balance at $500.
      m.startWeek(2);
      splitWeek(m, 470, 0, 0);
      expect(m.cardBalance, 380);
      expect(m.applyBike(BikeChoice.card), isTrue);
      expect(m.cardBalance, 500);
      // W3: maximum interest ($60 on $500), minimum $25, net $355;
      // essentials overflow takes the card to $695.
      final info3 = m.startWeek(3);
      expect(info3.interestAdded, 60);
      expect(info3.net, 355);
      splitWeek(m, 355, 0, 0);
      expect(m.cardBalance, 695);
      m.applyGig(false);
      // W4: interest $72 on $695, minimum $25, net $435; essentials
      // overflow takes the card to $902; the phone charge fits nowhere.
      final info4 = m.startWeek(4);
      expect(info4.interestAdded, 72);
      expect(info4.net, 435);
      splitWeek(m, 435, 0, 0);
      m.applyPhone(PhoneChoice.card);
      expect(m.cardBalance, 902);
      // Rent day: the tin — where the starved splits went — covers
      // the rent in full. Paid, with the card maxed and then some.
      expect(m.rentTin, 1715);
      expect(m.settleRent(), isTrue);
      final s = m.summary();
      expect(s.ending, Ending.onTheCard);
      expect(s.cardBalance, 902);
      expect(s.interestCharged, 132);
    });

    // Rent Short, reached through plausible play (enabled by the
    // Oct 23 cascade change): every paycheck weighted to Week Cash,
    // both shocks absorbed from cash instead of charged, night out
    // in full. The card is never used — and rent can't go on it.
    //
    // Trace: W1 cash 455 −160 essentials −60 night out = 235.
    // W2 +470 −160 −180 bike from cash = 365. W3 +380 −160, gig
    // skipped = 585. W4 +460 −160 −90 phone from cash = 795.
    // Rent day: tin 0, jar 0, cash $795 < $900 shortfall → short.
    test('cash-absorb line reaches Rent Short (card can\'t pay rent)', () {
      final m = GameModel();
      m.startWeek(1);
      splitWeek(m, 0, 0, 455);
      m.applyNightOut(NightOutChoice.go);
      expect(m.weekCash, 235);
      m.startWeek(2);
      splitWeek(m, 0, 0, 470);
      expect(m.applyBike(BikeChoice.weekCash), isTrue);
      expect(m.weekCash, 365);
      m.startWeek(3);
      splitWeek(m, 0, 0, 380);
      m.applyGig(false);
      expect(m.weekCash, 585);
      m.startWeek(4);
      splitWeek(m, 0, 0, 460);
      m.applyPhone(PhoneChoice.weekCash);
      expect(m.weekCash, 795);
      expect(m.cardBalance, 0);
      // Rent day: the cascade moves the $795 of Week Cash and stops.
      expect(m.rentShortfall, 900);
      final plan = m.prepareCascade();
      expect(plan, hasLength(1));
      expect(plan.single.source, 'Week Cash');
      expect(plan.single.amount, 795);
      while (!m.cascadeDone) {
        m.applyNextCascadeStep();
      }
      expect(m.rentTin, 795);
      expect(m.weekCash, 0);
      expect(m.settleRent(), isFalse);
      final s = m.summary();
      expect(s.ending, Ending.rentShort);
      expect(s.rentPaid, isFalse);
      expect(s.rentPaidAmount, 795);
      expect(s.cardBalance, 0); // never used, and couldn't pay rent anyway
      expect(s.bufferLeft, 0);
      expect(s.interestCharged, 0);
      expect(s.shockChargedToCard, 0);
    });

    test('the month is deterministic: same choices, same numbers, twice', () {
      final a = playCarefulMonth().summary();
      final b = playCarefulMonth().summary();
      expect(a.ending, b.ending);
      expect(a.cardBalance, b.cardBalance);
      expect(a.bufferLeft, b.bufferLeft);
      expect(a.rentPaidAmount, b.rentPaidAmount);
      expect(a.timeline, b.timeline);
    });
  });
}
