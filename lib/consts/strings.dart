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
}
