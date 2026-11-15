import 'package:flutter/material.dart';
import 'game_model.dart';

void main() => runApp(const RentDueApp());

class RentDueApp extends StatelessWidget {
  const RentDueApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rent Due!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

enum Phase {
  title,
  split,
  room,
  dilemma,
  shock,
  cascade,
  ending,
  reveal,
  comparison,
  practiceEnd,
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameModel model = GameModel();
  Phase phase = Phase.title;
  int runNumber = 1;
  bool practice = false;

  PaycheckInfo? lastPaycheck;
  int allocTin = 0;
  int allocJar = 0;
  int allocWeek = 0;
  int essentialsOnCard = 0;
  String lateFeeNote = '';
  bool _lateFeeApplied = false;

  RunSummary? run1Summary;
  RunSummary? currentSummary;
  String? reflection;

  // ---------- flow control ----------
  void _startRun(int run, {bool practiceMode = false}) {
    setState(() {
      model = GameModel();
      runNumber = run;
      practice = practiceMode;
      currentSummary = null;
      reflection = null;
      _lateFeeApplied = false;
      lateFeeNote = '';
      _beginWeek(1);
    });
  }

  void _beginWeek(int w) {
    lastPaycheck = model.startWeek(w);
    allocTin = 0;
    allocJar = 0;
    allocWeek = 0;
    essentialsOnCard = 0;
    phase = Phase.split;
  }

  void _confirmSplit() {
    final ok =
        model.applySplit(toTin: allocTin, toJar: allocJar, toWeek: allocWeek);
    if (!ok) return;
    setState(() {
      essentialsOnCard = model.applyEssentials();
      phase = Phase.room;
    });
  }

  void _roomContinue() {
    setState(() {
      switch (model.week) {
        case 1:
          phase = Phase.dilemma; // night out
        case 2:
          phase = Phase.shock; // bike
        case 3:
          phase = Phase.dilemma; // side gig
        case 4:
          if (!_lateFeeApplied) {
            _lateFeeApplied = true;
            final hadFee = model.busLateFeePending;
            final onCard = model.applyBusLateFee();
            if (hadFee) {
              lateFeeNote = 'The \$45 bus late-shift fee was paid first'
                  '${onCard > 0 ? ' (\$$onCard went on the card)' : ''}.';
            }
          }
          phase = Phase.shock; // phone
      }
    });
  }

  void _afterWeekEvent() {
    setState(() {
      if (practice) {
        phase = Phase.practiceEnd;
      } else if (model.week < 4) {
        _beginWeek(model.week + 1);
      } else {
        _rentDay();
      }
    });
  }

  void _rentDay() {
    if (model.rentShortfall == 0) {
      model.settleRent();
      _finishRun();
    } else {
      model.prepareCascade();
      phase = Phase.cascade;
    }
  }

  void _finishRun() {
    currentSummary = model.summary();
    phase = Phase.ending;
  }

  void _endingContinue() {
    setState(() {
      if (runNumber == 1) {
        run1Summary = currentSummary;
        phase = Phase.reveal;
      } else {
        phase = Phase.comparison;
      }
    });
  }

  void _toTitle() {
    setState(() {
      phase = Phase.title;
      run1Summary = null;
      currentSummary = null;
      practice = false;
    });
  }

  // ---------- shared bits ----------
  static const String _footer =
      'Card interest is simplified for play: \$12 per \$100 owed, applied at the '
      'start of Weeks 3 and 4. The Buffer Jar earns nothing.';

  Widget _footerWidget() => const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text(_footer,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.black54)),
      );

  Widget _bigButton(String label, VoidCallback? onPressed,
      {bool primary = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: primary
            ? FilledButton(
                onPressed: onPressed,
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(label, style: const TextStyle(fontSize: 16))))
            : OutlinedButton(
                onPressed: onPressed,
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(label, style: const TextStyle(fontSize: 16)))),
      ),
    );
  }

  bool get _isPayingPhase =>
      phase == Phase.split ||
      phase == Phase.dilemma ||
      phase == Phase.shock ||
      phase == Phase.cascade;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rent Due!'),
        actions: [
          if (phase != Phase.title)
            Center(
                child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                  practice
                      ? 'Practice'
                      : 'Run $runNumber · Week ${model.week} of 4',
                  style: const TextStyle(fontSize: 13)),
            )),
        ],
      ),
      body: Stack(
        children: [
          if (_isPayingPhase) ...[
            Positioned.fill(
              child: Image.asset(
                'assets/bg_pay.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF2).withValues(alpha: 0.82),
                ),
              ),
            ),
          ],
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isPayingPhase) ...[
                        BalancesBar(
                          model: model,
                          pendingTin: phase == Phase.split ? allocTin : 0,
                          pendingJar: phase == Phase.split ? allocJar : 0,
                        ),
                        const SizedBox(height: 10),
                      ],
                      _phaseWidget(),
                      _footerWidget(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _phaseWidget() {
    switch (phase) {
      case Phase.title:
        return _title();
      case Phase.split:
        return _split();
      case Phase.room:
        return _room();
      case Phase.dilemma:
        return model.week == 1 ? _nightOut() : _gig();
      case Phase.shock:
        return model.week == 2 ? _bike() : _phone();
      case Phase.cascade:
        return _cascade();
      case Phase.ending:
        return _ending();
      case Phase.reveal:
        return _reveal();
      case Phase.comparison:
        return _comparison();
      case Phase.practiceEnd:
        return _practiceEnd();
    }
  }

  // ---------- screens ----------
  Widget _title() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('RENT DUE!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
        const Text('One Month, Run It Back',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 17)),
        const SizedBox(height: 16),
        const BreathingAlex(height: 220),
        const SizedBox(height: 12),
        const Text(
          'Alex, 23. Barista — shifts change week to week. First apartment. '
          'Rent is \$900, due after the fourth paycheck.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 6),
        const Text(
          'The place is an older studio a few blocks from the café — '
          '\$900 is less than most places nearby ask.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 20),
        _bigButton('Play — Run 1', () => _startRun(1)),
        _bigButton('Practice Week 1', () => _startRun(1, practiceMode: true),
            primary: false),
      ],
    );
  }

  Widget _split() {
    final net = model.pendingNetPaycheck;
    final allocated = allocTin + allocJar + allocWeek;
    final remaining = net - allocated;
    final info = lastPaycheck;
    Widget stepper(String name, String detail, int value,
        void Function(int) set) {
      void bump(int d) {
        setState(() {
          var v = value + d;
          if (v < 0) v = 0;
          final others = allocated - value;
          if (others + v > net) v = net - others;
          set(v);
        });
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$name — \$$value',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600)),
              Text(detail, style: const TextStyle(fontSize: 12.5)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                      onPressed: () => bump(-50), child: const Text('−50')),
                  OutlinedButton(
                      onPressed: () => bump(-10), child: const Text('−10')),
                  OutlinedButton(
                      onPressed: () => bump(10), child: const Text('+10')),
                  OutlinedButton(
                      onPressed: () => bump(50), child: const Text('+50')),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Week ${model.week} payday',
            style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (info != null) ...[
          Text('Paycheck: \$${info.gross}'),
          if (info.interestAdded > 0)
            Text('Card interest added first: +\$${info.interestAdded}'),
          if (info.minPayment > 0)
            Text('Card minimum payment taken first: −\$${info.minPayment}'),
          if (model.week == 3)
            const Text(
                'Shifts were cut. This paycheck is \$90 smaller than last '
                'week\'s.'),
        ],
        Text(remaining > 0
            ? 'Still on the table: \$$remaining of \$$net'
            : 'All \$$net is in the containers.'),
        const SizedBox(height: 8),
        stepper('Rent Tin', 'Locked away until rent day. Goal: \$900 by Week 4.',
            allocTin, (v) => allocTin = v),
        stepper('Buffer Jar', 'Only opens when something breaks.', allocJar,
            (v) => allocJar = v),
        stepper('Week Cash', 'Food, bills and everything else come out of this.',
            allocWeek, (v) => allocWeek = v),
        const SizedBox(height: 8),
        const Text(
          'Every week, \$160 comes out of Week Cash for essentials:',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const Text(
          'Groceries — \$75\n'
          'Utilities — \$42\n'
          'Phone — \$13\n'
          'Bus pass — \$12\n'
          'Laundry & toiletries — \$18',
          style: TextStyle(fontSize: 13),
        ),
        const Text(
          'If Week Cash is short, the rest goes on the card.',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 8),
        _bigButton(
          remaining == 0 ? 'Split it' : 'Split it (put every dollar somewhere)',
          remaining == 0 ? _confirmSplit : null,
        ),
      ],
    );
  }

  Widget _room() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Week ${model.week} — the apartment',
            style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (essentialsOnCard > 0)
          Text('Essentials cost \$${GameModel.weeklyEssentials}. Week Cash was '
              'short, so \$$essentialsOnCard went on the card.'),
        const SizedBox(height: 8),
        RoomScene(model: model),
        const SizedBox(height: 12),
        _bigButton('Continue', _roomContinue),
      ],
    );
  }

  Widget _eventShell(
      String title, String body, String imageAsset, List<Widget> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title,
            style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(body, style: const TextStyle(fontSize: 15)),
        const SizedBox(height: 10),
        EventImageCard(assetPath: imageAsset),
        const SizedBox(height: 12),
        ...buttons,
      ],
    );
  }

  Widget _nightOut() {
    return _eventShell(
      'Friday night',
      'Friends are doing a group gift and a night out. It costs \$60. '
          'Going cheaper — \$25 — means saying so out loud. Skipping is free.',
      'assets/event_night_out.jpg',
      [
        _bigButton('Go — \$60', () {
          model.applyNightOut(NightOutChoice.go);
          _afterWeekEvent();
        }),
        _bigButton('Go cheaper — \$25', () {
          model.applyNightOut(NightOutChoice.cheaper);
          _afterWeekEvent();
        }, primary: false),
        _bigButton('Skip — \$0', () {
          model.applyNightOut(NightOutChoice.skip);
          _afterWeekEvent();
        }, primary: false),
      ],
    );
  }

  Widget _gig() {
    return _eventShell(
      'A weekend side gig',
      'One weekend of event work: +\$80 pay, −\$30 costs. Net +\$50 to Week '
          'Cash. Or rest.',
      'assets/event_gig.jpg',
      [
        _bigButton('Take it — +\$50', () {
          model.applyGig(true);
          _afterWeekEvent();
        }),
        _bigButton('Rest — \$0', () {
          model.applyGig(false);
          _afterWeekEvent();
        }, primary: false),
      ],
    );
  }

  Widget _bike() {
    final jarOk = model.bufferJar >= GameModel.bikeCost;
    final cashOk = model.weekCash >= GameModel.bikeCost;
    return _eventShell(
      'The bike broke',
      'Alex\'s bike — the way to work — needs \$180 of repairs. Today.',
      'assets/event_bike.jpg',
      [
        _bigButton(
            jarOk
                ? 'Pay \$180 from the Buffer Jar'
                : 'Buffer Jar has \$${model.bufferJar} — not enough',
            jarOk
                ? () {
                    model.applyBike(BikeChoice.buffer);
                    _afterWeekEvent();
                  }
                : null),
        _bigButton(
            cashOk
                ? 'Pay \$180 from Week Cash'
                : 'Week Cash has \$${model.weekCash} — not enough',
            cashOk
                ? () {
                    model.applyBike(BikeChoice.weekCash);
                    _afterWeekEvent();
                  }
                : null,
            primary: false),
        _bigButton('Put \$180 on the card', () {
          model.applyBike(BikeChoice.card);
          _afterWeekEvent();
        }, primary: false),
        _bigButton('Bus instead — \$30 pass now, \$45 late fee in Week 4', () {
          model.applyBike(BikeChoice.bus);
          _afterWeekEvent();
        }, primary: false),
      ],
    );
  }

  Widget _phone() {
    return _eventShell(
      'The phone screen cracked',
      '${lateFeeNote.isNotEmpty ? '$lateFeeNote\n\n' : ''}'
          'Rent is due in 3 days. A new screen is \$90.',
      'assets/event_phone.jpg',
      [
        _bigButton('Fix it from Week Cash — \$90', () {
          model.applyPhone(PhoneChoice.weekCash);
          _afterWeekEvent();
        }),
        _bigButton('Put \$90 on the card', () {
          model.applyPhone(PhoneChoice.card);
          _afterWeekEvent();
        }, primary: false),
        _bigButton('Live with the crack — \$0', () {
          model.applyPhone(PhoneChoice.cracked);
          _afterWeekEvent();
        }, primary: false),
      ],
    );
  }

  Widget _cascade() {
    final plan = model.cascadePlan;
    final done = model.cascadeDone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Rent day',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text('The Rent Tin has \$${model.rentTin} of \$${GameModel.rentDue}. '
            'Short by \$${model.rentShortfall}. Money moves in this order: '
            'Buffer Jar, then Week Cash.'),
        const Text('Rent is paid by bank transfer — the card can\'t cover rent.'),
        const SizedBox(height: 10),
        const EventImageCard(assetPath: 'assets/event_rent.jpg'),
        const SizedBox(height: 10),
        for (var i = 0; i < plan.length; i++)
          ListTile(
            leading: Icon(i < model.cascadeIndex
                ? Icons.check_circle
                : Icons.circle_outlined),
            title: Text('${plan[i].source} → \$${plan[i].amount}'),
          ),
        if (!done && plan.isNotEmpty)
          _bigButton(
              'Move \$${plan[model.cascadeIndex].amount} from '
              '${plan[model.cascadeIndex].source}',
              () => setState(() => model.applyNextCascadeStep()))
        else
          _bigButton('Settle rent', () {
            setState(() {
              model.settleRent();
              _finishRun();
            });
          }),
      ],
    );
  }

  String _endingTitle(Ending e) => switch (e) {
        Ending.nothingOwed => 'Rent paid — nothing owed',
        Ending.onTheCard => 'Rent paid — on the card',
        Ending.rentShort => 'Rent short',
      };

  Widget _ending() {
    final s = currentSummary!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_endingTitle(s.ending),
            style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        RoomScene(model: model),
        const SizedBox(height: 10),
        Text('Rent paid: \$${s.rentPaidAmount} of \$${GameModel.rentDue}'),
        Text('Card balance: \$${s.cardBalance}'),
        Text('Buffer Jar left: \$${s.bufferLeft}'),
        if (s.phoneKeptCracked)
          const Text('The phone is still cracked. It still works.'),
        if (s.ending == Ending.onTheCard && s.cardBalance > 0)
          Text('Next month starts with a '
              '\$${s.cardBalance < 25 ? s.cardBalance : 25} minimum payment '
              'already waiting.'),
        const SizedBox(height: 12),
        _bigButton(
            runNumber == 1 ? 'See the numbers' : 'Compare the two runs',
            _endingContinue),
      ],
    );
  }

  Widget _reveal() {
    final s = run1Summary ?? currentSummary!;
    final cardTotal = s.shockChargedToCard + s.interestCharged;
    Widget row(String label, int amt) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 16))),
              Text('\$$amt',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('The numbers',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text('This month, as it actually happened:'),
        const SizedBox(height: 8),
        row('Shocks put on the card', s.shockChargedToCard),
        row('Interest the card added', s.interestCharged),
        row('Total cost of shocks on the card', cardTotal),
        const Divider(),
        row('Shocks paid straight from the Buffer Jar', s.shockPaidFromJar),
        const SizedBox(height: 16),
        _bigButton('Run It Back — same month, your call', () => _startRun(2)),
        _bigButton('Back to title', _toTitle, primary: false),
      ],
    );
  }

  Widget _comparison() {
    final a = run1Summary;
    final b = currentSummary!;
    Widget row(String label, String va, String vb) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text(label)),
              Expanded(flex: 2, child: Text(va, textAlign: TextAlign.center)),
              Expanded(flex: 2, child: Text(vb, textAlign: TextAlign.center)),
            ],
          ),
        );
    const choices = [
      'I fed the jar first',
      'I skipped a want',
      'I still used the card — but less',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Two runs, same month',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        row('', 'Run 1', 'Run 2'),
        const Divider(),
        row('Rent paid', a == null ? '—' : (a.rentPaid ? 'Yes' : 'No'),
            b.rentPaid ? 'Yes' : 'No'),
        row('Card balance', a == null ? '—' : '\$${a.cardBalance}',
            '\$${b.cardBalance}'),
        row('Buffer left', a == null ? '—' : '\$${a.bufferLeft}',
            '\$${b.bufferLeft}'),
        row('Interest paid', a == null ? '—' : '\$${a.interestCharged}',
            '\$${b.interestCharged}'),
        const SizedBox(height: 16),
        const Text('What did you change?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in choices)
              ChoiceChip(
                label: Text(c),
                selected: reflection == c,
                onSelected: (_) => setState(() => reflection = c),
              ),
          ],
        ),
        if (reflection != null)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Noted. It\'s your month.'),
          ),
        const SizedBox(height: 16),
        _bigButton('Back to title', _toTitle),
        _bigButton('Play the month again', () => _startRun(1),
            primary: false),
      ],
    );
  }

  Widget _practiceEnd() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Practice done',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const Text('That was one week. The full month is four.'),
        const SizedBox(height: 12),
        _bigButton('Play the full month', () => _startRun(1)),
        _bigButton('Back to title', _toTitle, primary: false),
      ],
    );
  }
}

/// Alex placeholder art (Stage-A option A, whole image) with a subtle
/// breathing scale. SAM segmentation / rig2d is a gated later step.
class BreathingAlex extends StatefulWidget {
  const BreathingAlex({super.key, this.height = 180});
  final double height;
  @override
  State<BreathingAlex> createState() => _BreathingAlexState();
}

class _BreathingAlexState extends State<BreathingAlex>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2400))
    ..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.03).animate(_c),
      child: Image.asset('assets/alex.png', height: widget.height),
    );
  }
}

/// The room: Buffer Jar (5 fill levels), Rent Tin (target $900),
/// Card (colour band + label), Fridge (level from Week Cash), Alex, and
/// bike/phone state lines. State is always shown by fill AND words.
class RoomScene extends StatelessWidget {
  const RoomScene({super.key, required this.model, this.compact = false});
  final GameModel model;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bandColor =
        [Colors.blueGrey, Colors.amber, Colors.red][model.cardBand];
    final bandWord = ['Cool', 'Warm', 'Hot'][model.cardBand];
    final fridgeBars = model.weekCash >= GameModel.weeklyEssentials
        ? 3
        : (model.weekCash >= 60 ? 2 : (model.weekCash > 0 ? 1 : 0));
    const fridgeWords = ['Empty', 'Low', 'Stocked', 'Full'];
    return Card(
      color: const Color(0xFFFFF8EC),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 84,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.brown, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 80 * (model.jarLevel / 5),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Text(
                          'Buffer Jar\n\$${model.bufferJar} · level '
                          '${model.jarLevel}/5',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: BreathingAlex(height: compact ? 120 : 170),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 84,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (var i = 0; i < 3; i++)
                              Container(
                                height: 14,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                color: i < fridgeBars
                                    ? Colors.green.shade300
                                    : Colors.grey.shade200,
                              ),
                          ],
                        ),
                      ),
                      Text('Fridge\n${fridgeWords[fridgeBars]}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Rent Tin: \$${model.rentTin} of \$${GameModel.rentDue} · '
                    'rent due after paycheck 4',
                    style: const TextStyle(fontSize: 12.5))),
            LinearProgressIndicator(
              value: (model.rentTin / GameModel.rentDue).clamp(0.0, 1.0),
              minHeight: 12,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bandColor.withValues(alpha: 0.25),
                      border: Border.all(color: bandColor, width: 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Card: \$${model.cardBalance} ($bandWord)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12.5)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Week Cash: \$${model.weekCash}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12.5)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Bike: ${model.bikeBroken ? 'broken (bus pass)' : 'working'} · '
              'Phone: ${model.phoneKeptCracked ? 'cracked — kept' : 'fine'}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact live balance strip shown during paying / allocation stages so the
/// player always sees their Buffer Jar, Rent Tin, and Card totals.
class BalancesBar extends StatelessWidget {
  const BalancesBar({
    super.key,
    required this.model,
    this.pendingTin = 0,
    this.pendingJar = 0,
  });

  final GameModel model;
  final int pendingTin;
  final int pendingJar;

  @override
  Widget build(BuildContext context) {
    final bandColor =
        [Colors.blueGrey, Colors.amber, Colors.red][model.cardBand];
    final bandWord = ['Cool', 'Warm', 'Hot'][model.cardBand];

    Widget tile({
      required String label,
      required String value,
      String? sub,
      Color? tint,
      Color? border,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: tint ?? Colors.white.withValues(alpha: 0.92),
            border: Border.all(
              color: border ?? Colors.brown.withValues(alpha: 0.25),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              if (sub != null)
                Text(sub,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        tile(
          label: 'Buffer Jar',
          value: '\$${model.bufferJar}',
          sub: pendingJar > 0
              ? '+\$$pendingJar this week'
              : 'level ${model.jarLevel}/5',
          tint: const Color(0xFFFFF8E6).withValues(alpha: 0.95),
          border: Colors.amber.shade700.withValues(alpha: 0.45),
        ),
        const SizedBox(width: 8),
        tile(
          label: 'Rent Tin',
          value: '\$${model.rentTin}',
          sub: pendingTin > 0
              ? '+\$$pendingTin · of \$${GameModel.rentDue}'
              : 'of \$${GameModel.rentDue} due',
          tint: const Color(0xFFF1F8F5).withValues(alpha: 0.95),
          border: Colors.teal.shade600.withValues(alpha: 0.45),
        ),
        const SizedBox(width: 8),
        tile(
          label: 'Card',
          value: '\$${model.cardBalance}',
          sub: '$bandWord · limit \$${GameModel.cardLimit}',
          tint: bandColor.withValues(alpha: 0.14),
          border: bandColor.withValues(alpha: 0.75),
        ),
      ],
    );
  }
}

/// Framed 16:9 static event illustration shown during playthrough events.
class EventImageCard extends StatelessWidget {
  const EventImageCard({super.key, required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
