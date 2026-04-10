import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'portfolio_controller.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kSectionBg = Color(0xFF000000);
const Color _kInputBg = Color(0xFF282828);
const Color _kGreen = Color(0xFF47D5A6);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kGray = Color(0xFF999999);
const Color _kDark = Color(0xFF050505);

// ─── Data ───────────────────────────────────────────────────────────────────
const List<String> _kMarketOptions = [
  'Bitcoin (BTC)',
  'Ethereum (ETH)',
  'Solana (SOL)',
  'BNB (BNB)',
  'Gold (XAU)',
  'SET 50 (SET50)',
  'FTSE 100 (FTSE100)',
  'S&P 500 (SPX)',
];

const Map<String, String> _kIdMapping = {
  'Bitcoin': 'BTC',
  'Ethereum': 'ETH',
  'Solana': 'SOL',
  'BNB': 'BNB',
  'Gold': 'GOLD',
  'SET 50': 'SET50',
  'FTSE 100': 'FTSE100',
  'S&P 500': 'SPX',
};

// ─── Screen ───────────────────────────────────────────────────────────────────
class PortfolioAddScreen extends StatefulWidget {
  const PortfolioAddScreen({super.key});

  @override
  State<PortfolioAddScreen> createState() => _PortfolioAddScreenState();
}

class _PortfolioAddScreenState extends State<PortfolioAddScreen> {
  final _ctrl = PortfolioController();
  bool _submitting = false;

  String _selectedMarket = 'Bitcoin (BTC)';
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _priceCtrl = TextEditingController(text: '');
  final TextEditingController _quantityCtrl = TextEditingController(text: '');

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

  String get _displayName => _selectedMarket.split(' (').first;

  Future<void> _onSave() async {
    if (_priceCtrl.text.isEmpty || _quantityCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')));
      return;
    }

    setState(() => _submitting = true);
    try {
      final assetId = _kIdMapping[_displayName] ?? _displayName;

      await _ctrl.addPortfolioItem(
        assetId: assetId,
        assetLabel: _displayName,
        buyPrice: double.parse(_priceCtrl.text.replaceAll(',', '')),
        quantity: double.parse(_quantityCtrl.text.replaceAll(',', '')),
        purchaseDate: _selectedDate.toIso8601String(),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text('Portfolio',
                style: GoogleFonts.inter(fontSize: 24, color: _kWhite)),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _sectionHeader('Add Asset'),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Select Market'),
                          _dropdown(),
                          const SizedBox(height: 24),
                          _label('Buy Price'),
                          _textField(_priceCtrl, 'Price'),
                          const SizedBox(height: 24),
                          _label('Quantity'),
                          _textField(_quantityCtrl, 'Quantity'),
                          const SizedBox(height: 24),
                          _label('Date'),
                          _datePicker(),
                          const SizedBox(height: 40),
                          _actionButtons(),
                          const SizedBox(height: 30),
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

  Widget _sectionHeader(String label) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: _kSectionBg,
        child: Center(
          child: Text(label,
              style: GoogleFonts.golosText(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _kGreen)),
        ),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: GoogleFonts.inter(fontSize: 16, color: _kWhite)),
      );

  Widget _dropdown() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: _kInputBg, borderRadius: BorderRadius.circular(10)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedMarket,
            isExpanded: true,
            dropdownColor: _kInputBg,
            icon: const Icon(Icons.keyboard_arrow_down, color: _kWhite),
            items: _kMarketOptions
                .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(m, style: const TextStyle(color: _kWhite))))
                .toList(),
            onChanged: (v) => setState(() => _selectedMarket = v!),
          ),
        ),
      );

  Widget _textField(TextEditingController ctrl, String hint) => Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: _kInputBg, borderRadius: BorderRadius.circular(10)),
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: _kWhite),
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: _kGray)),
        ),
      );

  Widget _datePicker() => GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(primary: _kGreen)),
                child: child!),
          );
          if (picked != null) setState(() => _selectedDate = picked);
        },
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: _kInputBg, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Text(_formattedDate,
                  style: const TextStyle(color: _kWhite, fontSize: 16)),
              const Spacer(),
              const Icon(Icons.calendar_today, color: _kWhite, size: 20),
            ],
          ),
        ),
      );

  Widget _actionButtons() => Row(
        children: [
          Expanded(
            child: _btn('Cancel', _kInputBg, _kWhite, () => Navigator.pop(context)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _btn(_submitting ? '...' : 'Save', _kGreen, _kDark, _onSave),
          ),
        ],
      );

  Widget _btn(String label, Color bg, Color text, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Center(
              child: Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w600, color: text))),
        ),
      );
}
