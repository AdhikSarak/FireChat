import 'package:firebase_core/firebase_core.dart';
import 'package:firechat/common/enums/message_enum.dart';
import 'package:firechat/common/repositories/common_firebase_storage_repositories.dart';
import 'package:firechat/common/utils/colors.dart';
import 'package:firechat/common/utils/error.dart';
import 'package:firechat/common/utils/utils.dart';

import 'package:firechat/common/widgets/loader.dart';
import 'package:firechat/features/auth/controller/auth_controller.dart';
import 'package:firechat/features/landing/screens/landing_screen.dart';
import 'package:firechat/firebase_options.dart';
import 'package:firechat/mobile_layout_screen.dart';
import 'package:firechat/models/message.dart';
import 'package:firechat/models/user_model.dart';
import 'package:firechat/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';


GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            color: appBarColor,
          )),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: ref.watch(userDataAuthProvider).when(data: (user) {
        if (user == null) {
          return const LandingScreen();
        } else {
          return const MobileLayoutScreen();
        }
      }, error: (e, trace) {
        return ErrorScreen(error: e.toString());
      }, loading: () {
        return const Loader();
      }),
    );
  }
}
