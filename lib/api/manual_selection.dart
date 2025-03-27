import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import '../luckeverydaybot.dart';
import '../scheduled/winner_selector.dart';
import '../utils/env_reader.dart';

Future<Response> requestManualWinnerSelection(Request req) async {
  final secret = req.headers['x-secret-token'];
  final ogToken = EnvReader.getRequired('SECRET_TOKEN');

  if (secret != ogToken) {
    final res = jsonEncode({'ok': false, 'message': 'You for real?'});
    return Response.badRequest(
      body: res,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
  }
  final selector = WinnerSelector(supabase: supabase);
  selector.selectWinner().ignore();

  final res = jsonEncode({'ok': true, 'messaeg': 'Winner selection initiated'});
  return Response.ok(
    res,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
}
