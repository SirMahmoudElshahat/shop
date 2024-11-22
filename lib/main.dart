import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/screens/grocery_screen.dart';
import 'package:shop/screens/new_item.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
            brightness: Brightness.dark,
            seedColor: const Color.fromARGB(255, 146, 230, 247),
            surface: const Color.fromARGB(255, 44, 50, 60)),
        scaffoldBackgroundColor: const Color.fromARGB(255, 49, 57, 59),
      ),
      initialRoute: 'home',
      routes: {
        'home': (context) => const GroceryScreen(),
        'home/newItem': (context) => const NewItem(),
      },
    );
  }
}
