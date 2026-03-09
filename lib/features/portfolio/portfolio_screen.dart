import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'portfolioadd_screen.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kCardBg = Color(0xFF191919);
const Color _kBtnBg = Color(0xFF282828);
const Color _kGreen = Color(0xFF47D5A6);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kWhite80 = Color(0xCCFFFFFF);
const Color _kGray = Color(0xFF595959);
const Color _kDivider = Color(0xFF1F1F1F);

// ─── Mock Data ────────────────────────────────────────────────────────────────
class _AssetData {
  final String iconPath;
  final bool isJpg;
  final String name;
  final String ticker;
  final String quantity;
  final String value;
  final String profit;

  const _AssetData({
    required this.iconPath,
    required this.isJpg,
    required this.name,
    required this.ticker,
    required this.quantity,
    required this.value,
    required this.profit,
  });
}

const List<_AssetData> _kAssets = [
  _AssetData(
    iconPath: 'assets/images/bitcoin_icon.png',
    isJpg: false,
    name: 'Bitcoin',
    ticker: 'BTC',
    quantity: '0.03664',
    value: '102,909.40',
    profit: '10000.00',
  ),
  _AssetData(
    iconPath: 'assets/images/solana_icon.jpg',
    isJpg: true,
    name: 'Solana',
    ticker: 'SOL',
    quantity: '10.2541',
    value: '40613.41',
    profit: '2000.00',
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Portfolio',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: _kWhite,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Balance Card
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: _BalanceCard(),
                    ),
                    const SizedBox(height: 15),
                    // Action Buttons
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 33),
                      child: _ActionButtonRow(),
                    ),
                    const SizedBox(height: 10),
                    // Assets Divider
                    const _AssetsDivider(),
                    const SizedBox(height: 8),
                    // Asset List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          for (int i = 0; i < _kAssets.length; i++) ...[
                            if (i > 0) const SizedBox(height: 5),
                            _AssetListItem(data: _kAssets[i]),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
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

// ─── Balance Card ─────────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 18, 24),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Current Balance label + Bath button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Balance',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _kWhite80,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: _kGray, width: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Bath',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _kWhite,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Amount + percentage
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '202,000.40',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _kWhite,
                ),
              ),
              const SizedBox(width: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/right_arrow.png',
                    width: 8,
                    height: 8,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '+1.77%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _kGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Invested Balance | Total Profit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invested Balance',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _kWhite80,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '182,000.40',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _kWhite,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Profit',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _kWhite80,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/up_arrow.svg',
                        width: 8,
                        height: 5,
                        colorFilter: const ColorFilter.mode(
                            _kGreen, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '+20,000.00',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _kWhite,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Action Button Row ────────────────────────────────────────────────────────
class _ActionButtonRow extends StatelessWidget {
  const _ActionButtonRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            iconPath: 'assets/images/add_icon.png',
            label: 'Add',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PortfolioAddScreen()),
            ),
          ),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: _ActionButton(
            iconPath: 'assets/images/remove_icon.png',
            label: 'Remove',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: _ActionButton(
            iconPath: 'assets/images/assets_icon.png',
            label: 'Assets',
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: _kBtnBg,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 25,
              height: 25,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _kWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Assets Divider ───────────────────────────────────────────────────────────
class _AssetsDivider extends StatelessWidget {
  const _AssetsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(height: 1, color: _kDivider),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Text(
              'Assets',
              style: GoogleFonts.golosText(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _kGray,
              ),
            ),
          ),
          Expanded(
            child: Container(height: 1, color: _kDivider),
          ),
        ],
      ),
    );
  }
}

// ─── Asset List Item ──────────────────────────────────────────────────────────
class _AssetListItem extends StatelessWidget {
  final _AssetData data;

  const _AssetListItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _kDivider, width: 0.8),
      ),
      child: Row(
        children: [
          // Circular coin icon
          ClipOval(
            child: Image.asset(
              data.iconPath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          // Name + ticker + quantity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      data.name,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: _kWhite,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      data.ticker,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: _kWhite80,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data.quantity,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: _kWhite80,
                  ),
                ),
              ],
            ),
          ),
          // Value + profit
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.value,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: _kWhite,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/up_arrow.svg',
                    width: 8,
                    height: 5,
                    colorFilter: const ColorFilter.mode(
                        _kGreen, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    data.profit,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: _kWhite80,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
