import 'package:televerse/televerse.dart';

import '../consts/strings.dart';
import '../database/user_methods.dart';
import '../extensions/user_ext.dart';
import '../luckeverydaybot.dart';

Future<void> myChatMemberHandler(Context ctx) async {
  final newChatMember = ctx.chatMemberUpdated!.newChatMember;

  if (ctx.chat != null && ctx.chat!.type != ChatType.private) {
    if (newChatMember.status == ChatMemberStatus.member) {
      await ctx.reply(
        "It's better to use me in private chat - @${ctx.me.username}! Win big, Amigo! 🎁",
      );
      ctx.leaveChat().ignore();
      return;
    }
    return;
  }

  final isBlocked = newChatMember.status == ChatMemberStatus.kicked;

  final user = await ctx.user;
  if (user == null) {
    return;
  }

  final methods = UserMethods(supabase);
  await methods.updateUser(user.copyWith(blocked: isBlocked));
}

Future<void> chatMemberHandler(Context ctx) async {
  final user = await ctx.user;

  if (user == null) {
    return;
  }

  final status = ctx.chatMemberUpdated!.newChatMember.status;

  final chat = ctx.chat!;
  final isChannel = CommonData.channelId == chat.id;
  final isGroup = CommonData.groupId == chat.id;
  if (!isChannel && !isGroup) {
    return;
  }
  final methods = UserMethods(supabase);

  final isMember = [
    ChatMemberStatus.member,
    ChatMemberStatus.administrator,
  ].contains(status);

  if (isGroup) {
    methods.updateUser(user.copyWith(hasJoinedGroup: isMember)).ignore();
    if (isMember) {
      await ctx.api.sendMessage(
        ChatID(user.userId),
        user.lang.thanksForJoiningChat,
      );
    }
  }

  if (isChannel) {
    methods.updateUser(user.copyWith(hasJoinedChannel: isMember)).ignore();
    if (isMember) {
      await ctx.api.sendMessage(
        ChatID(user.userId),
        user.lang.thanksForJoiningChannel,
      );
    }
  }
}
