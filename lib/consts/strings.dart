class CallbackQueryData {
  const CallbackQueryData._();

  static const getStarted = 'get-started';
  static const help = 'help';

  static final languageExp = RegExp(r'^lang-([a-zA-Z]+)$');
}

class PayloadData {
  const PayloadData._();

  static const betPaylod = 'draw-bet';
}

class CommonData {
  const CommonData._();

  static const currency = 'XTR';
  static const channel = 'https://t.me/luckystareveryday';
  static const group = 'https://t.me/+oN3UYRdvhHU5MGVh';
}
