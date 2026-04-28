class AssetHelper {
  static String getAssetImagePath(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC':
      case 'BITCOIN':
        return 'assets/images/bitcoin_circle_icon.png';
      case 'GOLD':
      case 'XAU':
        return 'assets/images/GOLD.svg';
      case 'THAI':
      case 'SET':
      case 'SET 50':
      case 'SET50':
        return 'assets/images/SET50.svg';
      case 'US':
      case 'SPX':
      case 'S&P 500':
      case 'S&P500':
        return 'assets/images/SP500.png';
      case 'UK':
      case 'UKX':
      case 'FTSE 100':
      case 'FTSE100':
      case 'FTSE':
        return 'assets/images/FTSE100.svg';
      default:
        // Default fallback if unknown
        return 'assets/images/assets_icon.png';
    }
  }

  static bool isSvg(String path) => path.toLowerCase().endsWith('.svg');
}
