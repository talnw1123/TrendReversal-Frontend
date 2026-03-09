import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kSectionBg = Color(0xFF000000);
const Color _kInputBg = Color(0xFF282828);
const Color _kGreen = Color(0xFF47D5A6);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kGray = Color(0xFF999999);
const Color _kDark = Color(0xFF050505);

// ─── Mock Data ────────────────────────────────────────────────────────────────
const List<String> _kMarketOptions = [
  'Bitcoin (BTC)',
  'Ethereum (ETH)',
  'Solana (SOL)',
  'BNB (BNB)',
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class PortfolioAddScreen extends StatefulWidget {
  const PortfolioAddScreen({super.key});

  @override
  State<PortfolioAddScreen> createState() => _PortfolioAddScreenState();
}

class _PortfolioAddScreenState extends State<PortfolioAddScreen> {
  String _selectedMarket = 'Bitcoin (BTC)';
  DateTime _selectedDate = DateTime(2026, 12, 10);
  final TextEditingController _priceCtrl =
      TextEditingController(text: '60,000');
  final TextEditingController _quantityCtrl =
      TextEditingController(text: '0.02575');

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

  String get _ticker {
    final match = RegExp(r'\((\w+)\)').firstMatch(_selectedMarket);
    return match?.group(1) ?? '';
  }

  String get _coinName {
    return _selectedMarket.split(' (').first;
  }

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
            const SizedBox(height: 20),
            // ── Title ──────────────────────────────────────────────────────
            Text(
              'Portfolio',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: _kWhite,
              ),
            ),
            const SizedBox(height: 16),
            // ── Section container ──────────────────────────────────────────
            Expanded(
              child: Container(
                color: _kSectionBg,
                child: Column(
                  children: [
                    // "Edit Portfolio" tab header
                    _EditPortfolioTab(),
                    // Scrollable form + preview
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Market Type ──────────────────────────────
                            _FieldLabel('Market Type'),
                            const SizedBox(height: 6),
                            _MarketDropdown(
                              value: _selectedMarket,
                              items: _kMarketOptions,
                              onChanged: (v) =>
                                  setState(() => _selectedMarket = v!),
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
                            _FieldLabel('Purchase Price'),
                            const SizedBox(height: 6),
                            _TextInputField(
                              controller: _priceCtrl,
                              suffix: 'Bath',
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 14),
                            // ── Quantity ──────────────────────────────────
                            _FieldLabel('Quantity'),
                            const SizedBox(height: 6),
                            _TextInputField(
                              controller: _quantityCtrl,
                              suffix: _ticker,
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 24),
                            // ── Preview Card ──────────────────────────────
                            _PreviewCard(
                              coinName: _coinName,
                              ticker: _ticker,
                              dateText: _formattedDate,
                              price: _priceCtrl.text,
                              quantity: _quantityCtrl.text,
                            ),
                            const SizedBox(height: 24),
                            // ── Add Button ────────────────────────────────
                            _AddButton(onTap: () {}),
                          ],
                        ),
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
      BoxShadow(
        color: Color(0x80000000),
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
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
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: GoogleFonts.golosText(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _kWhite,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          dropdownColor: _kInputBg,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: _kWhite, size: 20),
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

  const _TextInputField({
    required this.controller,
    required this.suffix,
    required this.keyboardType,
    required this.onChanged,
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
  final String quantity;

  const _PreviewCard({
    required this.coinName,
    required this.ticker,
    required this.dateText,
    required this.price,
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
                'assets/images/bitcoin_circle_icon.png',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
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
              '${price.isEmpty ? '0' : price} Bath',
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
            SvgPicture.asset(
              'assets/icons/up_arrow_green.svg',
              width: 8,
              height: 5,
              colorFilter:
                  const ColorFilter.mode(_kGreen, BlendMode.srcIn),
            ),
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
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: _kGreen,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
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
