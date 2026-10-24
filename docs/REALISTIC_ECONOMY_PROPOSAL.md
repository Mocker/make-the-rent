# Realistic Economy Proposal — for Ryan's approval (Oct 23, 2026)

Principle (Ryan, Oct 23): don't make Rent Short easy, don't punish the player with
anything that feels unfair — make the numbers a *realistic scenario*. US cost of
living vs entry-level take-home pay is tight on its own; every cost is named and
real, nothing evaporates. This replaces the earlier "Week Stuff %" sink idea,
which is **dropped**.

## Grounding (checked Oct 23, 2026)

- Oregon standard minimum wage (Lane County / Eugene): **$15.55/hr** from
  Jul 1, 2026 (BOLI). Oregon has **no tip credit** — baristas keep tips on top.
- Barista reality: ~$15.55–16.50/hr + ~$1–2/hr tips, variable shifts ~29 hrs/wk
  → ≈ $2,150/mo gross → **≈ $1,730–1,780/mo take-home** after federal + Oregon
  tax + FICA.
- Eugene rents (RentCafe / Apartments.com, fall 2026): studio avg ≈ $1,190–1,430,
  1BR avg ≈ $1,430–1,520. A solo barista at market average **cannot carry a
  place alone at all** — the honest version of Alex's place is a below-market
  older studio at $900 (51% of take-home; the burden itself is the lesson).
- USDA Thrifty Food Plan (2025): single adult ≈ $250–310/mo on a 4-person
  basis; +20% single-person adjustment → **≈ $300–370/mo groceries floor**.

## Proposed numbers (game terms, 4 weekly paychecks)

| Item | Current (v2) | Proposed | Basis |
|---|---|---|---|
| Paychecks (take-home) | 650 / 650 / 510 / 650 = $2,460 | **455 / 470 / 380 / 460 = $1,765** | Variable shifts at $15.55 + tips, net |
| Rent | $900 | **$900 (keep)** | Below-market studio; story note |
| Essentials / week | $180 flat | **$160/wk = $640/mo, itemized in UI**: groceries $75/wk (USDA thrifty ≈ $300/mo), utilities ≈ $42/wk ($165/mo), phone ≈ $13/wk ($50/mo), bus pass ≈ $12/wk (~$45–50/mo), laundry/toiletries ≈ $18/wk ($75/mo) | Named real costs, shown as lines |
| Night out | 60 / 25 / 0 | keep | |
| Bike shock | $180 / bus $30 + $45 fee | keep | Real repair range |
| W3 side gig | +$50 net | keep | |
| Phone shock | $90 / charge / live-with-crack | keep | Real 3rd-party screen repair |
| Card | $500 limit, $12 per full $100, $25 min | keep | |

Monthly math: income $1,765 − rent $900 − essentials $640 = **$225 total slack**.
Both shocks together are $270 — more than the month's entire slack. That single
fact is the game.

## Ending definitions — one forced change

Current best ending (rent paid + buffer ≥ $50) becomes **mathematically
impossible** when both shocks are absorbed: the jar would need $180 + $90 + $50
= $320 of throughput against $225 of slack. An empty jar after absorbing two
shocks isn't failure — it's the jar having done its job.

- **Rent Paid, Nothing Owed** — rent paid, card balance $0. (Buffer left is
  still shown in the Reveal/Comparison as a number, just not gated.)
- **Rent Paid, On The Card** — rent paid, card balance > $0.
- **Rent Short** — cascade can't cover rent.

## Traced lines (hand-traced; test-verification is part of implementation)

- **Careful line** (tin ~$200–250/wk, jar built to $180 by Week 2, cheap night
  out, gig taken, phone lived-with or absorbed): bike fully absorbed by the
  jar; Week 3's short paycheck pushes ~$25 of essentials onto the card —
  cleared by the Week 4 minimum payment. Ends: rent paid, card $0 →
  **Nothing Owed**, buffer near $0. Tight the whole way, never hopeless.
- **Careless line** (charge both shocks, full night out, thin tin splits):
  card ≈ $245 + interest at rent day, cash thin → **On The Card**.
- **Spiral line** (charge everything + essentials overflow in the short week):
  card approaches the $500 limit, cascade runs out of card room →
  **Rent Short** becomes reachable. Exact reachability to be proven by unit
  tests during implementation (the builder verifies playthroughs, as before).

## What does NOT change

All mechanics (SPLIT / CHOOSE / ABSORB-or-CHARGE, cascade order, Run It Back,
Reveal, practice mode), all dilemma/shock content, and the no-lecture,
no-suggested-split rules. Copy gains the itemized essentials lines and one
story line establishing the below-market studio.

## Addendum (Oct 23, 2026) — card out of the rent cascade

Ryan approved one mechanics change after these numbers were implemented:
**the card no longer participates in the rent-day Shortfall Cascade.** Rent
is paid by bank transfer, so the card can't cover rent; the cascade is now
Rent Tin → Buffer Jar → Week Cash → Rent Short. (Essentials overflow and
shocks can still go on the card — only rent can't.)

Effect: the "≥ $1,163 always accessible" proof in the traced lines above no
longer holds, because card room no longer counts toward rent. Rent Short is
now reachable through plausible play — all-cash splits that absorb both
shocks end with $795 accessible at rent day against the $900 rent — while
the careful and careless lines end exactly as traced above (Nothing Owed:
card $0, buffer $20; On The Card: card $244). Implemented and covered by
deterministic playthrough tests the same day.
