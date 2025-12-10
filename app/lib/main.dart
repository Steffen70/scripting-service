import "package:app/app.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return GetMaterialApp(
      title: "Scripting Demo",
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale("en", "US"),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),
      themeMode: ThemeMode.system,
      home: const HomeView(),
    );
  }
}
