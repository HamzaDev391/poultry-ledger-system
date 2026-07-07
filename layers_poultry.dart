import 'dart:io';

// ---------------------------------------------------------------------------
// ENUM: Represents the editable fields of a poultry entry.
// This is an "enhanced enum" because it carries a getter (label) alongside
// its values — used to build a readable menu in updateEntry().
// ---------------------------------------------------------------------------
enum EntryField {
  date,
  numberOfBirds,
  feedPurchasedKg,
  feedCost,
  eggsCollected,
  eggsSold,
  eggSaleAmount,
  deadBirds,
  otherExpenses,
  notes;

  String get label {
    switch (this) {
      case EntryField.date:
        return 'Date';
      case EntryField.numberOfBirds:
        return 'Number of Birds';
      case EntryField.feedPurchasedKg:
        return 'Feed Purchased (kg)';
      case EntryField.feedCost:
        return 'Feed Cost';
      case EntryField.eggsCollected:
        return 'Eggs Collected';
      case EntryField.eggsSold:
        return 'Eggs Sold';
      case EntryField.eggSaleAmount:
        return 'Egg Sale Amount';
      case EntryField.deadBirds:
        return 'Dead Birds';
      case EntryField.otherExpenses:
        return 'Other Expenses';
      case EntryField.notes:
        return 'Notes';
    }
  }
}

// ---------------------------------------------------------------------------
// INPUT HELPERS
// Centralized, reusable input functions using tryParse so the program
// never crashes on bad input — it just re-prompts.
// ---------------------------------------------------------------------------

String promptRequiredString(String prompt) {
  while (true) {
    stdout.write(prompt);
    final input = stdin.readLineSync();
    if (input != null && input.trim().isNotEmpty) {
      return input.trim();
    }
    print('Input cannot be empty. Please try again.');
  }
}

// Notes are optional -> nullable String (demonstrates nullable types).
String? promptOptionalString(String prompt) {
  stdout.write(prompt);
  final input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) return null;
  return input.trim();
}

int promptInt(String prompt, {bool allowNegative = false}) {
  while (true) {
    stdout.write(prompt);
    final input = stdin.readLineSync();
    final value = int.tryParse(input ?? '');
    if (value != null && (allowNegative || value >= 0)) {
      return value;
    }
    print(
      'Please enter a valid ${allowNegative ? '' : 'non-negative '}whole number.',
    );
  }
}

double promptDouble(String prompt, {bool allowNegative = false}) {
  while (true) {
    stdout.write(prompt);
    final input = stdin.readLineSync();
    final value = double.tryParse(input ?? '');
    if (value != null && (allowNegative || value >= 0)) {
      return value;
    }
    print(
      'Please enter a valid ${allowNegative ? '' : 'non-negative '}number.',
    );
  }
}

// ---------------------------------------------------------------------------
// MENU DISPLAY
// ---------------------------------------------------------------------------

void showMenu() {
  print('==============================');
  print('   POULTRY LEDGER SYSTEM');
  print('==============================');
  print('1. Add Daily Entry');
  print('2. View All Entries');
  print('3. Search Entry');
  print('4. Update Entry');
  print('5. Delete Entry');
  print('6. View Summary');
  print('7. Exit');
  print('==============================');
}

// ---------------------------------------------------------------------------
// TABLE PRINTING (shared by View All, Search, and the selector used by
// Update/Delete)
// ---------------------------------------------------------------------------

void printTableHeader() {
  print(
    '${'No'.padRight(4)}'
    '${'Date'.padRight(12)}'
    '${'Birds'.padRight(7)}'
    '${'FeedKg'.padRight(8)}'
    '${'FeedCost'.padRight(10)}'
    '${'EggsColl'.padRight(9)}'
    '${'EggsSold'.padRight(9)}'
    '${'SaleAmt'.padRight(9)}'
    '${'Dead'.padRight(6)}'
    '${'OtherExp'.padRight(9)}'
    'Notes',
  );
  print('-' * 100);
}

void printEntryRow(int index, Map<String, dynamic> entry) {
  final notes = entry['notes'] ?? '-';
  print(
    '${(index + 1).toString().padRight(4)}'
    '${entry['date'].toString().padRight(12)}'
    '${entry['numberOfBirds'].toString().padRight(7)}'
    '${entry['feedPurchasedKg'].toString().padRight(8)}'
    '${entry['feedCost'].toString().padRight(10)}'
    '${entry['eggsCollected'].toString().padRight(9)}'
    '${entry['eggsSold'].toString().padRight(9)}'
    '${entry['eggSaleAmount'].toString().padRight(9)}'
    '${entry['deadBirds'].toString().padRight(6)}'
    '${entry['otherExpenses'].toString().padRight(9)}'
    '$notes',
  );
}

// ---------------------------------------------------------------------------
// FEATURE: ADD ENTRY
// ---------------------------------------------------------------------------

void addEntry(List<Map<String, dynamic>> ledger) {
  print('\n--- Add Daily Entry ---');

  final date = promptRequiredString('Enter date (YYYY-MM-DD): ');
  final numberOfBirds = promptInt('Enter number of birds: ');
  final feedPurchasedKg = promptDouble('Enter feed purchased (kg): ');
  final feedCost = promptDouble('Enter feed cost: ');
  final eggsCollected = promptInt('Enter eggs collected: ');
  final eggsSold = promptInt('Enter eggs sold: ');
  final eggSaleAmount = promptDouble('Enter egg sale amount: ');
  final deadBirds = promptInt('Enter dead birds: ');
  final otherExpenses = promptDouble('Enter other expenses: ');
  final notes = promptOptionalString(
    'Enter notes (optional, press Enter to skip): ',
  );

  // Simple business-logic validation using a logical/comparison check.
  if (eggsSold > eggsCollected) {
    print(
      'Warning: eggs sold ($eggsSold) exceeds eggs collected ($eggsCollected). Entry still saved.',
    );
  }

  final entry = <String, dynamic>{
    'date': date,
    'numberOfBirds': numberOfBirds,
    'feedPurchasedKg': feedPurchasedKg,
    'feedCost': feedCost,
    'eggsCollected': eggsCollected,
    'eggsSold': eggsSold,
    'eggSaleAmount': eggSaleAmount,
    'deadBirds': deadBirds,
    'otherExpenses': otherExpenses,
    'notes': notes,
  };

  ledger.add(entry);
  print('Entry added successfully.\n');
}

// ---------------------------------------------------------------------------
// FEATURE: VIEW ALL ENTRIES
// ---------------------------------------------------------------------------

void viewAllEntries(List<Map<String, dynamic>> ledger) {
  print('\n--- All Entries ---');
  if (ledger.isEmpty) {
    print('No entries found.\n');
    return;
  }

  printTableHeader();
  for (int i = 0; i < ledger.length; i++) {
    printEntryRow(i, ledger[i]);
  }
  print('');
}

// ---------------------------------------------------------------------------
// FEATURE: SEARCH ENTRY BY DATE
// Demonstrates try / on / catch / finally where it genuinely helps: turning
// a "not found" case into a clean, single-message flow instead of nested ifs.
// ---------------------------------------------------------------------------

void searchEntryByDate(List<Map<String, dynamic>> ledger) {
  print('\n--- Search Entry by Date ---');
  if (ledger.isEmpty) {
    print('No entries to search.\n');
    return;
  }

  final date = promptRequiredString('Enter date to search (YYYY-MM-DD): ');
  final matches = <int>[];

  for (int i = 0; i < ledger.length; i++) {
    if (ledger[i]['date'] == date) {
      matches.add(i);
    }
  }

  try {
    if (matches.isEmpty) {
      throw StateError('No entry found for date: $date');
    }
    print('\nFound ${matches.length} entry/entries:');
    printTableHeader();
    for (final index in matches) {
      printEntryRow(index, ledger[index]);
    }
  } on StateError catch (e) {
    print(e.message);
  } finally {
    print('Search complete.\n');
  }
}

// ---------------------------------------------------------------------------
// SHARED HELPER: pick an entry index for Update/Delete.
// Demonstrates try / on RangeError / catch for a genuinely risky operation:
// converting user input into a valid list index.
// ---------------------------------------------------------------------------

int? selectEntryIndex(List<Map<String, dynamic>> ledger) {
  if (ledger.isEmpty) {
    print('No entries available.\n');
    return null;
  }

  viewAllEntries(ledger);
  final choice = promptInt('Enter entry number: ');
  final index = choice - 1;

  try {
    if (index < 0 || index >= ledger.length) {
      throw RangeError.index(index, ledger, 'entry number');
    }
    return index;
  } on RangeError catch (e) {
    print('Invalid selection: ${e.message}');
    return null;
  }
}

// ---------------------------------------------------------------------------
// FEATURE: UPDATE ENTRY
// Uses the EntryField enum + switch to route to the right field.
// ---------------------------------------------------------------------------

void updateEntry(List<Map<String, dynamic>> ledger) {
  print('\n--- Update Entry ---');
  final index = selectEntryIndex(ledger);
  if (index == null) return;

  print('\nSelect field to update:');
  for (final field in EntryField.values) {
    print('${field.index + 1}. ${field.label}');
  }

  final fieldChoice = promptInt('Enter field number: ');
  if (fieldChoice < 1 || fieldChoice > EntryField.values.length) {
    print('Invalid field selection.\n');
    return;
  }

  final selectedField = EntryField.values[fieldChoice - 1];
  final entry = ledger[index];

  switch (selectedField) {
    case EntryField.date:
      entry['date'] = promptRequiredString('Enter new date: ');
      break;
    case EntryField.numberOfBirds:
      entry['numberOfBirds'] = promptInt('Enter new number of birds: ');
      break;
    case EntryField.feedPurchasedKg:
      entry['feedPurchasedKg'] = promptDouble(
        'Enter new feed purchased (kg): ',
      );
      break;
    case EntryField.feedCost:
      entry['feedCost'] = promptDouble('Enter new feed cost: ');
      break;
    case EntryField.eggsCollected:
      entry['eggsCollected'] = promptInt('Enter new eggs collected: ');
      break;
    case EntryField.eggsSold:
      entry['eggsSold'] = promptInt('Enter new eggs sold: ');
      break;
    case EntryField.eggSaleAmount:
      entry['eggSaleAmount'] = promptDouble('Enter new egg sale amount: ');
      break;
    case EntryField.deadBirds:
      entry['deadBirds'] = promptInt('Enter new dead birds: ');
      break;
    case EntryField.otherExpenses:
      entry['otherExpenses'] = promptDouble('Enter new other expenses: ');
      break;
    case EntryField.notes:
      entry['notes'] = promptOptionalString('Enter new notes: ');
      break;
  }

  print('Entry updated successfully.\n');
}

// ---------------------------------------------------------------------------
// FEATURE: DELETE ENTRY
// ---------------------------------------------------------------------------

void deleteEntry(List<Map<String, dynamic>> ledger) {
  print('\n--- Delete Entry ---');
  final index = selectEntryIndex(ledger);
  if (index == null) return;

  final confirm = promptRequiredString(
    'Are you sure you want to delete this entry? (y/n): ',
  );
  if (confirm.toLowerCase() == 'y') {
    ledger.removeAt(index);
    print('Entry deleted successfully.\n');
  } else {
    print('Delete cancelled.\n');
  }
}

// ---------------------------------------------------------------------------
// FEATURE: SUMMARY
// Demonstrates try / on IntegerDivisionByZeroException / catch for a
// genuinely risky calculation: dividing by a bird count that could be zero.
// ---------------------------------------------------------------------------

String computeAverageFeedCostPerBird(double totalFeedCost, int numberOfBirds) {
  try {
    final avg = totalFeedCost.round() ~/ numberOfBirds;
    return avg.toString();
  } on UnsupportedError {
    return 'N/A (no birds recorded)';
  }
}

void viewSummary(List<Map<String, dynamic>> ledger) {
  print('\n--- Summary ---');
  if (ledger.isEmpty) {
    print('No entries to summarize.\n');
    return;
  }

  double totalFeedKg = 0;
  double totalFeedCost = 0;
  int totalEggsCollected = 0;
  int totalEggsSold = 0;
  double totalEggRevenue = 0;
  int totalDeadBirds = 0;
  double totalOtherExpenses = 0;

  for (final entry in ledger) {
    totalFeedKg += entry['feedPurchasedKg'] as double;
    totalFeedCost += entry['feedCost'] as double;
    totalEggsCollected += entry['eggsCollected'] as int;
    totalEggsSold += entry['eggsSold'] as int;
    totalEggRevenue += entry['eggSaleAmount'] as double;
    totalDeadBirds += entry['deadBirds'] as int;
    totalOtherExpenses += entry['otherExpenses'] as double;
  }

  // Uses the most recent entry's bird count as the base for the average.
  final currentBirdCount = ledger.last['numberOfBirds'] as int;
  final avgFeedCostPerBird = computeAverageFeedCostPerBird(
    totalFeedCost,
    currentBirdCount,
  );

  print('Total Feed Purchased : ${totalFeedKg.toStringAsFixed(2)} kg');
  print('Total Feed Cost      : ${totalFeedCost.toStringAsFixed(2)}');
  print('Total Eggs Collected : $totalEggsCollected');
  print('Total Eggs Sold      : $totalEggsSold');
  print('Total Egg Revenue    : ${totalEggRevenue.toStringAsFixed(2)}');
  print('Total Bird Deaths    : $totalDeadBirds');
  print('Total Other Expenses : ${totalOtherExpenses.toStringAsFixed(2)}');
  print('Avg Feed Cost/Bird   : $avgFeedCostPerBird');
  print('');
}

// ---------------------------------------------------------------------------
// MAIN: menu-driven loop
// ---------------------------------------------------------------------------

void main() {
  final List<Map<String, dynamic>> ledger = [];
  bool isRunning = true;

  while (isRunning) {
    showMenu();
    final choice = promptInt('Enter your choice: ');

    switch (choice) {
      case 1:
        addEntry(ledger);
        break;
      case 2:
        viewAllEntries(ledger);
        break;
      case 3:
        searchEntryByDate(ledger);
        break;
      case 4:
        updateEntry(ledger);
        break;
      case 5:
        deleteEntry(ledger);
        break;
      case 6:
        viewSummary(ledger);
        break;
      case 7:
        print('Exiting Poultry Ledger System. Goodbye!');
        isRunning = false;
        break;
      default:
        print('Invalid choice. Please select a number between 1 and 7.\n');
    }
  }
}
