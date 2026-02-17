import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_app/form_UI.dart';
import 'package:form_builder_app/form_fill_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final uri = Uri.base;

    Widget home;

    if (uri.fragment.startsWith('/form/')) {
      final formId = uri.fragment.replaceFirst('/form/', '');
      home = FormFillScreen(formId: formId);
    } else {
      home = const FormBuilderScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}
