import 'package:flutter/material.dart';
import 'texts_screen.dart';
import 'dictionaries_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<TextsScreenState> _textsScreenKey =
      GlobalKey<TextsScreenState>();
  final GlobalKey<DictionariesScreenState> _dictionariesScreenKey =
      GlobalKey<DictionariesScreenState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFloatingActionButtonPressed() {
    _textsScreenKey.currentState?.addText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Easy Four English'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book), text: 'Тексты'),
            Tab(icon: Icon(Icons.book), text: 'Словари'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TextsScreen(key: _textsScreenKey),
          DictionariesScreen(key: _dictionariesScreenKey),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          return FloatingActionButton(
            onPressed: _onFloatingActionButtonPressed,
            tooltip: _tabController.index == 0
                ? 'Добавить текст'
                : 'Создать словарь',
            child: Icon(_tabController.index == 0 ? Icons.add : Icons.book),
          );
        },
      ),
    );
  }
}
