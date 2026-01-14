import 'package:flutter/material.dart';

class CurrencyInfo {
  final String code;   // ISO 4217
  final String name;   // Official name
  final String symbol; // Display symbol

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

const List<String> topCurrencyCodes = ['GBP', 'USD', 'INR'];


/// 🔒 Frozen ISO-4217 currency registry
const Map<String, CurrencyInfo> currencyRegistry = {
  // 🔝 Preferred / common
  'GBP': CurrencyInfo(
    code: 'GBP',
    name: 'British Pound Sterling',
    symbol: '£',
  ),
  'USD': CurrencyInfo(
    code: 'USD',
    name: 'United States Dollar',
    symbol: '\$',
  ),
  'INR': CurrencyInfo(
    code: 'INR',
    name: 'Indian Rupee',
    symbol: '₹',
  ),

  // 🌍 Common ISO currencies
  'EUR': CurrencyInfo(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
  ),
  'AUD': CurrencyInfo(
    code: 'AUD',
    name: 'Australian Dollar',
    symbol: 'A\$',
  ),
  'CAD': CurrencyInfo(
    code: 'CAD',
    name: 'Canadian Dollar',
    symbol: 'C\$',
  ),
  'CHF': CurrencyInfo(
    code: 'CHF',
    name: 'Swiss Franc',
    symbol: 'CHF',
  ),
  'JPY': CurrencyInfo(
    code: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
  ),
  'CNY': CurrencyInfo(
    code: 'CNY',
    name: 'Chinese Yuan',
    symbol: '¥',
  ),
  'SGD': CurrencyInfo(
    code: 'SGD',
    name: 'Singapore Dollar',
    symbol: 'S\$',
  ),
  'NZD': CurrencyInfo(
    code: 'NZD',
    name: 'New Zealand Dollar',
    symbol: 'NZ\$',
  ),
  'ZAR': CurrencyInfo(
    code: 'ZAR',
    name: 'South African Rand',
    symbol: 'R',
  ),
  'AED': CurrencyInfo(
    code: 'AED',
    name: 'UAE Dirham',
    symbol: 'د.إ',
  ),
  'SAR': CurrencyInfo(
    code: 'SAR',
    name: 'Saudi Riyal',
    symbol: '﷼',
  ),
};


class CurrencyDropdown extends StatefulWidget {
  final String selectedCode;
  final ValueChanged<String> onChanged;

  const CurrencyDropdown({
    super.key,
    required this.selectedCode,
    required this.onChanged,
  });

  @override
  State<CurrencyDropdown> createState() => _CurrencyDropdownState();
}

class _CurrencyDropdownState extends State<CurrencyDropdown> {
  final TextEditingController _searchController = TextEditingController();
  late List<CurrencyInfo> _filtered;

  static const List<String> _topCodes = ['GBP', 'USD', 'INR'];

  @override
  void initState() {
    super.initState();
    _filtered = _allCurrencies;
  }

  List<CurrencyInfo> get _topCurrencies =>
      _topCodes.map((c) => currencyRegistry[c]!).toList();

  List<CurrencyInfo> get _allCurrencies =>
      currencyRegistry.values
          .where((c) => !_topCodes.contains(c.code))
          .toList()
        ..sort((a, b) => a.code.compareTo(b.code));

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allCurrencies;
      } else {
        final q = query.toLowerCase();
        _filtered = _allCurrencies.where((c) {
          return c.code.toLowerCase().contains(q) ||
              c.name.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openPicker(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Currency',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.selectedCode} '
                  '(${currencyRegistry[widget.selectedCode]!.symbol})',
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    _searchController.clear();
    _filtered = _allCurrencies;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Select currency'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Search
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search currency',
                  ),
                  onChanged: (v) {
                    setDialogState(() {
                      if (v.isEmpty) {
                        _filtered = _allCurrencies;
                      } else {
                        final q = v.toLowerCase();
                        _filtered = _allCurrencies.where((c) {
                          return c.code.toLowerCase().contains(q) ||
                              c.name.toLowerCase().contains(q);
                        }).toList();
                      }
                    });
                  },
                ),

                const SizedBox(height: 12),

                /// List
                SizedBox(
                  height: 360,
                  width: double.maxFinite,
                  child: ListView(
                    children: [
                      /// Top currencies
                      ..._topCurrencies.map(
                            (c) => _CurrencyTile(
                          currency: c,
                          onTap: () {
                            widget.onChanged(c.code);
                            Navigator.pop(context);
                          },
                        ),
                      ),

                      const Divider(),

                      /// All currencies
                      ..._filtered.map(
                            (c) => _CurrencyTile(
                          currency: c,
                          onTap: () {
                            widget.onChanged(c.code);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  final CurrencyInfo currency;
  final VoidCallback onTap;

  const _CurrencyTile({
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${currency.code} — ${currency.name}'),
      trailing: Text(
        currency.symbol,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }
}