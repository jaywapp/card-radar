import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_radar/presentation/providers/kftc_import_provider.dart';
import 'package:card_radar/presentation/router.dart';

class CardRadarApp extends ConsumerStatefulWidget {
  const CardRadarApp({super.key});

  @override
  ConsumerState<CardRadarApp> createState() => _CardRadarAppState();
}

class _CardRadarAppState extends ConsumerState<CardRadarApp> {
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _linkSub = AppLinks().uriLinkStream.listen(_handleDeepLink);
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme != 'cardradar' || uri.host != 'auth') return;
    final code  = uri.queryParameters['code'];
    final error = uri.queryParameters['error'];
    final state = uri.queryParameters['state'] ?? '';
    final notifier = ref.read(kftcImportProvider.notifier);
    if (code != null) {
      notifier.handleAuthCode(code, state);
    } else if (error != null) {
      notifier.handleError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '카드레이더',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
