import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:card_radar/app.dart';
import 'package:card_radar/core/naver_map_config.dart';
import 'package:card_radar/core/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<String>('user_cards');
  if (supabaseConfigured) {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
  }
  if (naverMapsConfigured) {
    await FlutterNaverMap().init(clientId: naverClientId);
  }
  runApp(const ProviderScope(child: CardRadarApp()));
}
