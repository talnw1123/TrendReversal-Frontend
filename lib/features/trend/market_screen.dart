import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/currency_provider.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kBg = Color(0xFF121212);
const Color _kCard = Color(0xFF191919);
const Color _kGreen = Color(0xFF47D5A6);
const Color _kWhite = Color(0xFFFFFFFF);
const Color _kWhite80 = Color(0xCCFFFFFF); // rgba(255,255,255,0.80)

// ─── Mock Data ────────────────────────────────────────────────────────────────
class _MarketCoin {
  final String iconPath;
  final String name;
  final String ticker;
  final double priceTHB;
  final double changePercent;

  const _MarketCoin({
    required this.iconPath,
    required this.name,
    required this.ticker,
    required this.priceTHB,
    required this.changePercent,
  });
}

const List<_MarketCoin> _kMarketCoins = [
  _MarketCoin(
    iconPath: 'assets/images/bitcoin_icon.png',
    name: 'Bitcoin',
    ticker: 'BTC',
    priceTHB: 2902909.40,
    changePercent: 9.77,
  ),
  _MarketCoin(
    iconPath: 'assets/images/solana_icon.jpg',
    name: 'Solana',
    ticker: 'SOL',
    priceTHB: 4340.39,
    changePercent: 9.77,
  ),
  _MarketCoin(
    iconPath: 'assets/images/xrp_icon.png',
    name: 'XRP',
    ticker: 'XRP',
    priceTHB: 71.05,
    changePercent: 9.77,
  ),
  _MarketCoin(
    iconPath: 'assets/images/ethereum_icon.png',
    name: 'Ethereum',
    ticker: 'ETH',
    priceTHB: 99296.35,
    changePercent: 9.77,
  ),
];

// ═══════════════════════════════════════════════════════════════════════════════
// MarketScreen
// ═══════════════════════════════════════════════════════════════════════════════
class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Title ──────────────────────────────────────────────────────
            const SizedBox(height: 42),
            Center(
              child: Text(
                'Market',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: _kWhite,
                ),
              ),
            ),
            const SizedBox(height: 36),

            // ── Coin List ──────────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _kMarketCoins.length,
                separatorBuilder: (_, __) => const SizedBox(height: 5),
                itemBuilder: (context, index) {
                  return _CoinCard(coin: _kMarketCoins[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Coin Card ────────────────────────────────────────────────────────────────
class _CoinCard extends StatelessWidget {
  final _MarketCoin coin;

  const _CoinCard({required this.coin});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CurrencyProvider(),
      builder: (context, _) {
        final currency = CurrencyProvider();
        final price = currency.formatValue(coin.priceTHB);
        final isPositive = coin.changePercent >= 0;
        final changeStr =
            '${isPositive ? '+' : ''}${coin.changePercent.toStringAsFixed(2)}%';
        final changeColor = isPositive ? _kGreen : const Color(0xFFE4472B);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF191919),
                Color(0xFF666666),
              ],
            ),
          ),
          child: Container(
            height: 80,
            margin: const EdgeInsets.all(1.2), // ความหนาของขอบ
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(4.5),
            ),
          child: Row(
            children: [
              // ── Coin Icon ────────────────────────────────────────────────
              ClipOval(
                child: Image.asset(
                  coin.iconPath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),

              // ── Name + Ticker ─────────────────────────────────────────────
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: _kWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    coin.ticker,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: _kWhite80,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ── Price + Change % ──────────────────────────────────────────
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: _kWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    changeStr,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: changeColor,
                    ),
                  ),
                ],
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}
