class CallbackQueryData {
  const CallbackQueryData._();

  static const getStarted = 'get-started';
  static const help = 'help';
  static const updateName = 'update-name';
  static const vipStatus = 'vip-status';
  static const language = 'language';
  static const activateVip = 'activate-vip';
  static const invite = 'invite';

  static final languageExp = RegExp(r'^lang-([a-zA-Z]+)$');
}

class PayloadData {
  const PayloadData._();

  static const betPaylod = 'draw-bet';
  static const vipPayload = 'vip';
}

class CommonData {
  const CommonData._();

  static const currency = 'XTR';
  static const channel = 'https://t.me/TheCashSplash';
  static const group = 'https://t.me/+7Kz76alXRuJjODUx';

  static const groupId = -1002602158964;
  static const channelId = -1002697838093;

  static final oneTo2500Exp = RegExp(
    r'^(?:[1-9]|[1-9][0-9]{1,2}|1[0-9]{3}|2[0-4][0-9]{2}|2500)$',
  );

  static const todayPicFileId =
      'AgACAgUAAxkDAAPBZ-RRBEw1oBWBKmICI8fX2JBZQiwAAkPFMRtf1SFXaH1JaxmUP6oBAAMCAAN3AAM2BA';

  static const introFileId =
      'AgACAgUAAxkDAAO2Z-RKOrQa5AlQibQDHhlEOPrswzEAAjzFMRtf1SFXKeFcwArZ2igBAAMCAAN5AAM2BA';
}
