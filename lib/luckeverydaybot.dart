import 'package:supabase/supabase.dart';
import 'package:televerse/televerse.dart';

import 'utils/env_reader.dart';

// Bot configuration
final token = EnvReader.getRequired('BOT_TOKEN');
final adminIds = EnvReader.getIntList('BOT_ADMIN_IDS');

// Initialize bot
final api = RawAPI(token);
final bot = Bot.fromAPI(api);

// Supabase configurations
final supabaseUrl = EnvReader.getRequired('SUPABASE_URL');
final supabaseKey = EnvReader.getRequired('SUPABASE_KEY');
final supabase = SupabaseClient(supabaseUrl, supabaseKey);
