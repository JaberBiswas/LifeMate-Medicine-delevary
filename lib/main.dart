import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'utils/firestore_transport_stub.dart';
import 'package:provider/provider.dart';

import 'utils/theme.dart';
import 'utils/routes.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: kIsWeb ? DefaultFirebaseOptions.web : DefaultFirebaseOptions.currentPlatform,
    );
    // On web, do NOT terminate or clear persistence after initialization; it breaks the client.
    // Keep persistence disabled explicitly if desired.
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);
    await configureFirestoreTransport();
  } catch (e) {
    // Firebase not configured yet; app can still run with local fallbacks
  }

  const String appMode = String.fromEnvironment('APP_MODE');
  final bool isAdminMode = args.contains('admin') || appMode.toLowerCase() == 'admin';

  runApp(LifeMateApp(
    initialRoute: isAdminMode ? '/admin/dashboard' : '/home',
  ));
}

class LifeMateApp extends StatelessWidget {
  const LifeMateApp({super.key, this.initialRoute = '/home'});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'LifeMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: initialRoute,
        routes: AppRoutes.routes,
      ),
    );
  }
}

