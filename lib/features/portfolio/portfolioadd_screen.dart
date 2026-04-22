import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/asset_helper.dart';
import 'portfolio_controller.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kSectionBg = Color(0xFF191919);
const Color _kInputBg = Color(0xFF282828);
const Color _kGreen = Color(0xFF47D5A6);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kGray = Color(0xFF999999);
const Color _kDark = Color(0xFF050505);

// ─── Market Options (mapped to backend AssetId) ───────────────────────────────
const List<Map<String, String>> _kMarkets = [
  {'label': 'Bitcoin (BTC)', 'id': 'BTC'},
  {'label': 'Gold', 'id': 'Gold'},
  {'label': 'SET 50', 'id': 'Thai'},
  {'label': 'S&P 500 (US)', 'id': 'US'},
  {'label': 'FTSE 100 (UK)', 'id': 'UK'},
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class PortfolioAddScreen extends StatefulWidget {
  const PortfolioAddScreen({super.key});

  @override
  State<PortfolioAddScreen> createState() => _PortfolioAddScreenState();
}

class _PortfolioAddScreenState extends State<PortfolioAddScreen> {
  final _ctrl = PortfolioController();
  Map<String, String> _selectedMarket = _kMarkets.first;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _quantityCtrl = TextEditingController();
  bool _submitting = false;
  String _selectedCurrency = 'THB';

  @override
  void dispose() {
    _priceCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  String get _formattedDate {
    return '${_selectedDate.month.toString().padLeft(2, '0')}/'
        '${_selectedDate.day.toString().padLeft(2, '0')}/'
        '${_selectedDate.year}';
  }

  String get _ticker => _selectedMarket['id'] ?? '';
  String get _coinName => _selectedMarket['label']?.split(' (').first ?? '';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _kGreen,
            onPrimary: _kDark,
            surface: Color(0xFF282828),
            onSurface: _kWhite,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 22),
            // Header: back button + title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                children: [
                  _BackButton(onTap: () => Navigator.pop(context)),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Portfolio',
                        style: GoogleFonts.golosText(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: _kWhite,
                        ),
                      ),
                    ),
                  ),
                  // Balance spacer to keep title centred
                  const SizedBox(width: 44),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // ── Section container ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 20),
              child: Container(
                decoration: BoxDecoration(
                  color: _kSectionBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // "Edit Portfolio" tab header
                    _EditPortfolioTab(),
                    // Scrollable form + preview
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ... (content remains the same)
                          // ── Market Type ──────────────────────────────
                          _FieldLabel('Market Type'),
                          const SizedBox(height: 6),
                          _MarketDropdown(
                            value: _selectedMarket['label']!,
                            items: _kMarkets.map((m) => m['label']!).toList(),
                            onChanged: (v) => setState(() {
                              _selectedMarket = _kMarkets.firstWhere(
                                (m) => m['label'] == v,
                                orElse: () => _kMarkets.first,
                              );
                            }),
                          ),
                          const SizedBox(height: 14),
                          // ── Time-in ──────────────────────────────────
                          _FieldLabel('Time-in'),
                          const SizedBox(height: 6),
                          _DateField(
                            dateText: _formattedDate,
                            onTap: _pickDate,
                          ),
                          const SizedBox(height: 14),
                          // ── Purchase Price ────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _FieldLabel('Purchase Price'),
                              Row(
                                children: ['THB', 'USD']
                                    .map(
                                      (c) => GestureDetector(
                                        onTap: () => setState(
                                          () => _selectedCurrency = c,
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _selectedCurrency == c
                                                ? _kGreen
                                                : _kInputBg,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: _kGreen.withValues(
                                                alpha: 0.5,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            c,
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _selectedCurrency == c
                                                  ? _kDark
                                                  : _kWhite,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _TextInputField(
                            controller: _priceCtrl,
                            suffix: _selectedCurrency,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            inputFormatters: [ThousandsSeparatorInputFormatter()],
                          ),
                          const SizedBox(height: 14),
                          // ── Quantity ──────────────────────────────────
                          _FieldLabel('Quantity'),
                          const SizedBox(height: 6),
                          _TextInputField(
                            controller: _quantityCtrl,
                            suffix: _ticker,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                            inputFormatters: [ThousandsSeparatorInputFormatter()],
                          ),
                          const SizedBox(height: 24),
                          // ── Preview Card ──────────────────────────────
                          _PreviewCard(
                            coinName: _coinName,
                            ticker: _ticker,
                            dateText: _formattedDate,
                            price: _priceCtrl.text,
                            currency: _selectedCurrency,
                            quantity: _quantityCtrl.text,
                          ),
                          const SizedBox(height: 24),
                          // ── Add Button ────────────────────────────────
                          _AddButton(
                            loading: _submitting,
                            onTap: _submitting
                                ? null
                                : () async {
                                    final price = double.tryParse(
                                      _priceCtrl.text.replaceAll(',', ''),
                                    );
                                    final quantity = double.tryParse(
                                      _quantityCtrl.text.replaceAll(',', ''),
                                    );
                                    if (price == null ||
                                        quantity == null ||
                                        price <= 0 ||
                                        quantity <= 0) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'กรุณากรอกข้อมูลให้ครบถ้วน',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() => _submitting = true);
                                    final buyDate =
                                        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
                                    final ok = await _ctrl.addItem(
                                      assetId: _selectedMarket['id']!,
                                      quantity: quantity,
                                      buyPrice: price,
                                      currency: _selectedCurrency,
                                      buyDate: buyDate,
                                    );
                                    setState(() => _submitting = false);
                                    if (!mounted) return;
                                    if (ok) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('เพิ่มสินทรัพย์สำเร็จ'),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'เกิดข้อผิดพลาด ลองใหม่อีกครั้ง',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Edit Portfolio Tab ───────────────────────────────────────────────────────
class _EditPortfolioTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 14),
        Text(
          'Edit Portfolio',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _kGreen,
          ),
        ),
        const SizedBox(height: 10),
        Container(height: 1.5, color: _kGreen),
      ],
    );
  }
}

// ─── Field Label ──────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.golosText(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _kGray,
      ),
    );
  }
}

// ─── Input Box Decoration ─────────────────────────────────────────────────────
BoxDecoration _inputDecoration() {
  return BoxDecoration(
    color: _kInputBg,
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: _kGreen.withOpacity(0.5), width: 1),
    boxShadow: const [
      BoxShadow(color: Color(0x80000000), blurRadius: 6, offset: Offset(0, 2)),
    ],
  );
}

// ─── Market Dropdown ──────────────────────────────────────────────────────────
class _MarketDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _MarketDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: _inputDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: GoogleFonts.golosText(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _kWhite,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          dropdownColor: _kInputBg,
          icon: const Icon(Icons.keyboard_arrow_down, color: _kWhite, size: 20),
          isExpanded: true,
          style: GoogleFonts.golosText(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: _kWhite,
          ),
        ),
      ),
    );
  }
}

// ─── Date Field ───────────────────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final String dateText;
  final VoidCallback onTap;

  const _DateField({required this.dateText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: _inputDecoration(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                dateText,
                style: GoogleFonts.golosText(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: _kWhite,
                ),
              ),
            ),
            Image.asset(
              'assets/images/calendar_icon.png',
              width: 16,
              height: 16,
              color: _kWhite,
              colorBlendMode: BlendMode.srcIn,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Text Input Field ─────────────────────────────────────────────────────────
class _TextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String suffix;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const _TextInputField({
    required this.controller,
    required this.suffix,
    required this.keyboardType,
    required this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: _inputDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: onChanged,
              inputFormatters: inputFormatters,
              style: GoogleFonts.golosText(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _kWhite,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              cursorColor: _kGreen,
            ),
          ),
          Text(
            suffix,
            style: GoogleFonts.golosText(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _kWhite,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Preview Card ─────────────────────────────────────────────────────────────
class _PreviewCard extends StatelessWidget {
  final String coinName;
  final String ticker;
  final String dateText;
  final String price;
  final String currency;
  final String quantity;

  const _PreviewCard({
    required this.coinName,
    required this.ticker,
    required this.dateText,
    required this.price,
    required this.currency,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Coin header row ───────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                AssetHelper.getAssetImagePath(ticker),
                width: 30,
                height: 30,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 30,
                  height: 30,
                  color: _kInputBg,
                  child: Center(
                    child: Text(
                      ticker.isNotEmpty ? ticker[0].toUpperCase() : '?',
                      style: GoogleFonts.inter(color: _kWhite, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: coinName,
                    style: const TextStyle(
                      fontFamily: 'Franklin Gothic Demi',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: _kWhite,
                    ),
                  ),
                  TextSpan(
                    text: ' ($ticker)',
                    style: GoogleFonts.golosText(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _kGray,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              dateText,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _kWhite,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // ── Divider ───────────────────────────────────────────────────────
        Container(height: 1, color: _kBg),
        const SizedBox(height: 14),
        // ── Purchase Price row ────────────────────────────────────────────
        Row(
          children: [
            Text(
              'Purchase Price',
              style: GoogleFonts.golosText(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _kGray,
              ),
            ),
            const Spacer(),
            Text(
              '${price.isEmpty ? '0' : price} $currency',
              style: GoogleFonts.golosText(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _kWhite,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // ── Quantity row ──────────────────────────────────────────────────
        Row(
          children: [
            Text(
              'Quantity',
              style: GoogleFonts.golosText(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _kGray,
              ),
            ),
            const Spacer(),
            const SizedBox(width: 4),
            Text(
              '${quantity.isEmpty ? '0' : quantity} $ticker',
              style: GoogleFonts.golosText(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _kWhite,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Add Button ───────────────────────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool loading;
  const _AddButton({required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: loading ? _kGreen.withOpacity(0.5) : _kGreen,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Add',
                style: GoogleFonts.golosText(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _kDark,
                ),
              ),
      ),
    );
  }
}
// ─── Back Button ─────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Ink(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: Colors.white.withOpacity(0.1),
        splashColor: Colors.white.withOpacity(0.05),
        child: Center(
          child: Image.asset(
            'assets/icons/back_icon.png',
            width: 20,
            height: 20,
          ),
        ),
      ),
    );
  }
}

// ─── Input Formatter ─────────────────────────────────────────────────────────
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    int selectionIndex = newValue.selection.end;
    String text = newValue.text.replaceAll(',', '');

    // Handle leading minus
    bool isNegative = text.startsWith('-');
    if (isNegative) text = text.substring(1);

    // Handle decimal point
    List<String> parts = text.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    if (integerPart.isEmpty && decimalPart.isEmpty && !isNegative) return newValue;

    String formattedInteger = "";
    if (integerPart.isNotEmpty) {
      double? val = double.tryParse(integerPart);
      if (val != null) {
        formattedInteger = NumberFormat('#,###').format(val);
      } else {
        return oldValue;
      }
    } else if (isNegative) {
      formattedInteger = "";
    }

    String newText = (isNegative ? '-' : '') + formattedInteger + decimalPart;

    // Adjust cursor position
    int newSelectionIndex = selectionIndex + (newText.length - newValue.text.length);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newSelectionIndex.clamp(0, newText.length)),
    );
  }
}

