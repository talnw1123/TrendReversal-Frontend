import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trend_reversal_frontend/features/nagbar/nagbar.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kCard = Color(0xFF191919);
const Color _kDarkCard = Color(0xFF282828);
const Color _kRed = Color(0xFFE4472B);
const Color _kGreen = Color(0xFF47D5A6);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kGray = Color(0xFF595959);
const Color _kDivider = Color(0xFF1F1F1F);
const Color _kWhite80 = Color(0xCCFFFFFF);
const Color _kWhite50 = Color(0x80FFFFFF);
const Color _kNotifDot = Color(0xFFDB2110);
const Color _kCardBorder = Color(0xFF282828);

// ─── Mock Data ────────────────────────────────────────────────────────────────
class _CryptoData {
  final String iconPath;
  final bool isNetworkIcon;
  final String name;
  final String price;
  final String chartAsset;
  final bool isPositive;

  const _CryptoData({
    required this.iconPath,
    this.isNetworkIcon = false,
    required this.name,
    required this.price,
    required this.chartAsset,
    required this.isPositive,
  });
}

const List<_CryptoData> _kCryptoList = [
  _CryptoData(
    iconPath: 'assets/images/bitcoin_icon.png',
    name: 'Bitcoin (BTC)',
    price: '2,902,909.40 Bath',
    chartAsset: 'assets/icons/btc_chart.svg',
    isPositive: true,
  ),
  _CryptoData(
    iconPath: 'assets/images/solana_icon.jpg',
    name: 'Solana (SOL)',
    price: '4,340.39 Bath',
    chartAsset: 'assets/icons/sol_chart.svg',
    isPositive: false,
  ),
];

class _TransactionData {
  final String iconPath;
  final String trend;
  final String time;
  final String amount;
  final bool isUptrend;

  const _TransactionData({
    required this.iconPath,
    required this.trend,
    required this.time,
    required this.amount,
    required this.isUptrend,
  });
}

const List<_TransactionData> _kTransactions = [
  _TransactionData(
    iconPath: 'assets/images/ethereum_icon.png',
    trend: 'Downtrend',
    time: '18:59',
    amount: '99,296.35',
    isUptrend: false,
  ),
  _TransactionData(
    iconPath: 'assets/images/xrp_icon.png',
    trend: 'Downtrend',
    time: '14:20',
    amount: '71.05',
    isUptrend: false,
  ),
  _TransactionData(
    iconPath: 'assets/images/bitcoin_icon.png',
    trend: 'Uptrend',
    time: '11:09',
    amount: '2,902,909.40',
    isUptrend: true,
  ),
  _TransactionData(
    iconPath: 'assets/images/solana_icon.jpg',
    trend: 'Uptrend',
    time: '01:00',
    amount: '4,340.39',
    isUptrend: true,
  ),
];

// ═══════════════════════════════════════════════════════════════════════════════
// HomeScreen
// ═══════════════════════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      bottomNavigationBar: AppNavBar(
        selectedIndex: _selectedIndex,
        onTabSelected: (index) => setState(() => _selectedIndex = index),
        onCenterTap: () {},
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              // ── App Bar ───────────────────────────────────────────────────
              const _HomeAppBar(),
              const SizedBox(height: 22),
              // ── Crypto Cards ──────────────────────────────────────────────
              const _CryptoCardsList(),
              const SizedBox(height: 28),
              // ── Transactions ──────────────────────────────────────────────
              const _SectionDivider(label: 'Transactions'),
              const SizedBox(height: 4),
              ..._kTransactions.map((t) => _TransactionItem(data: t)),
              // See more
              Padding(
                padding: const EdgeInsets.only(right: 24, top: 10, bottom: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      'See more',
                      style: GoogleFonts.golosText(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _kRed,
                      ),
                    ),
                  ),
                ),
              ),
              // ── Portfolio ─────────────────────────────────────────────────
              const _SectionDivider(label: 'Portfolio'),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: _PortfolioCard(),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _HomeAppBar
// ═══════════════════════════════════════════════════════════════════════════════
class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Quantix',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: _kWhite,
            ),
          ),
          // Bell icon with red notification dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icons/notification_icon.png',
                    width: 18,
                    height: 18,
                    color: _kWhite,
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: _kNotifDot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _CryptoCardsList
// ═══════════════════════════════════════════════════════════════════════════════
class _CryptoCardsList extends StatelessWidget {
  const _CryptoCardsList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 24, right: 24),
        itemCount: _kCryptoList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) => _CryptoCard(data: _kCryptoList[index]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _CryptoCard
// ═══════════════════════════════════════════════════════════════════════════════
class _CryptoCard extends StatelessWidget {
  final _CryptoData data;
  const _CryptoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Card is ~60% of screen width, matching the BTC card proportion
    final cardWidth = (screenWidth - 48) * 0.63;

    return SizedBox(
      width: cardWidth,
      height: 172,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Card body ─────────────────────────────────────────────────────
          Positioned(
            top: 22,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: _kCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + price row (left-padded to make room for icon)
                  Padding(
                    padding: const EdgeInsets.only(left: 60, right: 10, top: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.name,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _kWhite,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.price,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: _kWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Navigate icon
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _kDarkCard,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.north_east_rounded,
                            size: 12,
                            color: _kWhite.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Chart SVG
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    child: SvgPicture.asset(
                      data.chartAsset,
                      width: double.infinity,
                      height: 47,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Coin icon (overlaps top-left of card) ─────────────────────────
          Positioned(
            top: 0,
            left: 8,
            child: ClipOval(
              child: Image.asset(
                data.iconPath,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _SectionDivider
// ═══════════════════════════════════════════════════════════════════════════════
class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: _kDivider)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.golosText(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _kGray,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 1, color: _kDivider)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _TransactionItem
// ═══════════════════════════════════════════════════════════════════════════════
class _TransactionItem extends StatelessWidget {
  final _TransactionData data;
  const _TransactionItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _kCardBorder, width: 1),
      ),
      child: Row(
        children: [
          // Coin icon
          ClipOval(
            child: Image.asset(
              data.iconPath,
              width: 30,
              height: 30,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          // Trend + time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.trend,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: _kWhite,
                      ),
                    ),
                    const SizedBox(width: 5),
                    // Trend indicator arrow
                    data.isUptrend
                        ? SvgPicture.asset(
                            'assets/icons/uptrend_arrow.svg',
                            width: 8,
                            height: 5,
                            colorFilter: const ColorFilter.mode(
                              _kGreen,
                              BlendMode.srcIn,
                            ),
                          )
                        : Transform.rotate(
                            angle: 3.14159,
                            child: SvgPicture.asset(
                              'assets/icons/uptrend_arrow.svg',
                              width: 8,
                              height: 5,
                              colorFilter: const ColorFilter.mode(
                                _kRed,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  data.time,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: _kWhite50,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            data.amount,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: _kWhite,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _PortfolioCard
// ═══════════════════════════════════════════════════════════════════════════════
class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row: Current Balance label + Bath badge ───────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Balance',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _kWhite80,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _kDarkCard,
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
          const SizedBox(height: 8),
          // ── Balance value + % indicator ───────────────────────────────────
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
              const SizedBox(width: 12),
              Row(
                children: [
                  Image.asset(
                    'assets/images/right_arrow.png',
                    width: 10,
                    height: 10,
                    color: _kGreen,
                  ),
                  const SizedBox(width: 2),
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
          // ── Invested Balance | Total Profit ───────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invested Balance',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _kWhite80,
                ),
              ),
              Text(
                'Total Profit',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _kWhite80,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '182,000.40',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _kWhite,
                ),
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/uptrend_arrow.svg',
                    width: 9,
                    height: 5,
                    colorFilter: const ColorFilter.mode(
                      _kGreen,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
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
          const SizedBox(height: 20),
          // ── Action buttons ────────────────────────────────────────────────
          Row(
            children: [
              _ActionButton(
                iconPath: 'assets/images/add_icon.png',
                label: 'Add',
                onTap: () {},
              ),
              const SizedBox(width: 15),
              _ActionButton(
                iconPath: 'assets/images/remove_icon.png',
                label: 'Remove',
                onTap: () {},
              ),
              const SizedBox(width: 15),
              _ActionButton(
                iconPath: 'assets/images/assets_icon.png',
                label: 'Assets',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _ActionButton
// ═══════════════════════════════════════════════════════════════════════════════
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: _kDarkCard,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 25,
                height: 25,
                color: _kWhite,
              ),
              const SizedBox(height: 6),
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
      ),
    );
  }
}
