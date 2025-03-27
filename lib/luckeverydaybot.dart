import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:supabase/supabase.dart';
import 'package:televerse/televerse.dart';
import 'package:televerse_shelf/televerse_shelf.dart';

import 'api/manual_selection.dart';
import 'utils/env_reader.dart';

// Bot configuration
final token = EnvReader.getRequired('BOT_TOKEN');

// Initialize bot
final api = RawAPI(token);

late Bot<Context> bot;
late Conversation<Context> conv;

// Supabase configurations
final supabaseUrl = EnvReader.getRequired('SUPABASE_URL');
final supabaseKey = EnvReader.getRequired('SUPABASE_KEY');
final supabase = SupabaseClient(supabaseUrl, supabaseKey);

Router initBot() {
  final env = EnvReader.get('ENVIRONMENT');
  final isDebug = env == 'debug';
  log('Running in $env mode');
  final Router router = Router();
  if (isDebug) {
    final fetcher = LongPolling.allUpdates();
    bot = Bot.fromAPI(api, fetcher: fetcher);
  } else {
    final webhook = TeleverseShelfWebhook(
      secretToken: EnvReader.get('SECRET_TOKEN'),
    );
    router.post('/webhook', webhook.createHandler());
    bot = Bot.fromAPI(api, fetcher: webhook);
  }
  conv = Conversation(bot);

  // Additional routes here
  router.get(
    '/',
    (req) => Response.ok(
      jsonEncode({'ok': true, 'message': 'All good!'}),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    ),
  );
  router.get('/selectWinner', requestManualWinnerSelection);
  return router;
}
