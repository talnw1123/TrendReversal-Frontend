import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kSectionBg = Color(0xFF000000);
const Color _kInputBg = Color(0xFF282828);
const Color _kRed = Color(0xFFE4472B);
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

class _AssetInfo {
  final String iconPath;
  final String ticker;
  final String coinName;
  final String sellingPrice;
  final String quantity;
  final String date;

  const _AssetInfo({
    required this.iconPath,
    required this.ticker,
    required this.coinName,
    required this.sellingPrice,
    required this.quantity,
    required this.date,
  });
}

const Map<String, _AssetInfo> _kAssetMap = {
  'Bitcoin (BTC)': _AssetInfo(
    iconPath: 'assets/images/bitcoin_circle_icon.png',
    ticker: 'BTC',
    coinName: 'Bitcoin',
    sellingPrice: '60,000',
    quantity: '0.02575',
    date: '12/10/2026',
  ),
  'Ethereum (ETH)': _AssetInfo(
    iconPath: 'assets/images/bitcoin_circle_icon.png',
    ticker: 'ETH',
    coinName: 'Ethereum',
    sellingPrice: '98,000',
    quantity: '0.51200',
    date: '11/05/2026',
  ),
  'Solana (SOL)': _AssetInfo(
    iconPath: 'assets/images/bitcoin_circle_icon.png',
    ticker: 'SOL',
    coinName: 'Solana',
    sellingPrice: '12,500',
    quantity: '10.2541',
    date: '09/22/2026',
  ),
  'BNB (BNB)': _AssetInfo(
    iconPath: 'assets/images/bitcoin_circle_icon.png',
    ticker: 'BNB',
    coinName: 'BNB',
    sellingPrice: '22,000',
    quantity: '5.0000',
    date: '08/15/2026',
  ),
};

// ═══════════════════════════════════════════════════════════════════════════════
// PortfolioRemoveScreen
// ═══════════════════════════════════════════════════════════════════════════════
class PortfolioRemoveScreen extends StatefulWidget {
  const PortfolioRemoveScreen({super.key});

  @override
  State<PortfolioRemoveScreen> createState() => _PortfolioRemoveScreenState();
}

class _PortfolioRemoveScreenState extends State<PortfolioRemoveScreen> {
  String _selectedMarket = 'Bitcoin (BTC)';

  _AssetInfo get _currentAsset => _kAssetMap[_selectedMarket]!;

  void _onRemove() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kInputBg,
        title: Text(
          'Confirm Remove',
          style: GoogleFonts.inter(color: _kWhite, fontWeight: FontWeight.w500),
        ),
        content: Text(
          'Remove ${_currentAsset.coinName} (${_currentAsset.ticker}) from your portfolio?',
          style: GoogleFonts.inter(color: _kGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: _kGray)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Remove',
                style: GoogleFonts.inter(color: _kRed, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
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
            // ── Title ─────────────────────────────────────────────────────
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
                    const _EditPortfolioTab(),
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Market Type ───────────────────────────────
                            const _FieldLabel('Market Type'),
                            const SizedBox(height: 6),
                            _MarketDropdown(
                              value: _selectedMarket,
                              items: _kMarketOptions,
                              onChanged: (v) =>
                                  setState(() => _selectedMarket = v!),
                            ),
                            const SizedBox(height: 20),
                            // ── Preview Card ──────────────────────────────
                            _PreviewCard(asset: _currentAsset),
                            const SizedBox(height: 28),
                            // ── Remove Button ─────────────────────────────
                            _RemoveButton(onTap: _onRemove),
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
  const _EditPortfolioTab();

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
            color: _kRed,
          ),
        ),
        const SizedBox(height: 10),
        Container(height: 1.5, color: _kRed),
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
    border: Border.all(color: _kRed.withOpacity(0.5), width: 1),
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

// ─── Preview Card ─────────────────────────────────────────────────────────────
class _PreviewCard extends StatelessWidget {
  final _AssetInfo asset;

  const _PreviewCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _PreviewCardContent(
        key: ValueKey(asset.ticker),
        asset: asset,
      ),
    );
  }
}

class _PreviewCardContent extends StatelessWidget {
  final _AssetInfo asset;

  const _PreviewCardContent({super.key, required this.asset});

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
                asset.iconPath,
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
                    text: asset.coinName,
                    style: const TextStyle(
                      fontFamily: 'Franklin Gothic Demi',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: _kWhite,
                    ),
                  ),
                  TextSpan(
                    text: ' (${asset.ticker})',
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
              asset.date,
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
        // ── Selling Price row ─────────────────────────────────────────────
        Row(
          children: [
            Text(
              'Selling Price',
              style: GoogleFonts.golosText(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _kGray,
              ),
            ),
            const Spacer(),
            Text(
              '${asset.sellingPrice} Bath',
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
            // Down arrow (rotated up_arrow.svg) in red
            Transform.rotate(
              angle: math.pi,
              child: SvgPicture.asset(
                'assets/icons/up_arrow.svg',
                width: 8,
                height: 5,
                colorFilter: const ColorFilter.mode(_kRed, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${asset.quantity} ${asset.ticker}',
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

// ─── Remove Button ────────────────────────────────────────────────────────────
class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RemoveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: _kRed,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          'Remove',
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
