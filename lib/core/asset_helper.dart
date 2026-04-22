class AssetHelper {
  static String getAssetImagePath(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC':
      case 'BITCOIN':
        return 'assets/images/bitcoin_circle_icon.png';
      case 'GOLD':
        return 'assets/images/GOLD.jpg';
      case 'THAI':
      case 'SET':
      case 'SET 50':
      case 'SET50':
        return 'assets/images/SET.png';
      case 'US':
      case 'S&P 500':
      case 'S&P500':
        return 'assets/images/SP500.png';
      case 'UK':
      case 'FTSE 100':
      case 'FTSE100':
      case 'FTSE':
        return 'assets/images/FTSE100.png';
      default:
        // Default fallback if unknown
        return 'assets/images/assets_icon.png';
    }
  }
}
