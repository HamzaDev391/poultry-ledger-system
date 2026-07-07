# Poultry Ledger System

A console-based poultry farm record-keeping system written in **pure procedural Dart** — no classes, no OOP. Built as a personal showcase of core Dart fundamentals before moving on to object-oriented programming.

## Why this project exists

Before learning OOP, I wanted a project that proves solid command of Dart's foundational concepts: functions, collections, control flow, null safety, enums, and exception handling — all without leaning on classes or objects as a crutch.

## What it does

A menu-driven CLI for tracking daily poultry farm activity:

```
==============================
   POULTRY LEDGER SYSTEM
==============================
1. Add Daily Entry
2. View All Entries
3. Search Entry
4. Update Entry
5. Delete Entry
6. View Summary
7. Exit
==============================
```

Each daily entry records:
- Date
- Number of birds
- Feed purchased (kg) and feed cost
- Eggs collected and eggs sold, plus egg sale amount
- Dead birds
- Other expenses
- Notes (optional)

The **Summary** view rolls all entries up into totals: feed purchased, feed cost, eggs collected/sold, egg revenue, bird deaths, other expenses, and an average feed cost per bird.

## Dart concepts demonstrated

- **Collections** — the entire dataset is a `List<Map<String, dynamic>>`, no custom classes involved
- **Functions** — every feature is its own function; nothing is crammed into `main()`
- **Null safety** — nullable `String?` used for optional notes, with `??` fallbacks when displaying
- **Enums (enhanced)** — `EntryField` enum with a `label` getter drives the "which field do you want to update?" menu
- **Exception handling** — used deliberately, not everywhere:
  - `try` / `on StateError` / `catch` / `finally` for a date search with no match
  - `try` / `on RangeError` / `catch` for validating a user-selected list index
  - `try` / `on IntegerDivisionByZeroException` / `catch` for a safe average calculation
- **Input validation** — all console input goes through `tryParse`-based helpers that reprompt on invalid input instead of crashing
- **Control flow & loops** — `switch` statements for menu routing and field selection, `for`/`for-in` loops for iteration

## Running it

Requires the [Dart SDK](https://dart.dev/get-dart).

```bash
dart run layer_poultry.dart
```

## Roadmap

This is a deliberate pre-OOP checkpoint. Once OOP is learned, a natural next step would be refactoring entries into a proper class-based model — but that's out of scope for this version by design.
