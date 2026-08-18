class BasePath {
  static String get assetBasePath => 'assets/images/';
}

enum AssetPath {
  appIcon('app_icon'),
  appLogo('app_logo'),
  cambodiaFlag('cambodia_flag'),
  dashboard('dashboard'),
  englishFlag('english_flag'),
  paid('paid'),
  placeholder('placeholder'),
  profileBackground('profile_background'),
  riel('riel'),
  unpaid('unpaid'),
  usd('usd'),
  check('check'),
  checking('checking'),
  termCondition('term_condition'),
  appLogoFtBg('app_logo_ft_bg'),
  fb('fb'),
  linked('linked'),
  twitter('twitter_logo'),
  youtube('youtube'),

  iconpaid('icon/paid'),
  iconOnline('icon/Online'),
  iconShedule('icon/shedule'),
  iconLeave('icon/Leave'),
  iconscro('icon/scro'),
  iconattenden('icon/attenden'),
  iconinformation('icon/information'),
  iconevent('icon/event'),
  iconreport('icon/report');

  final String key;
  const AssetPath(this.key);

  String get path {
    return '${BasePath.assetBasePath}$key.png';
  }
}
