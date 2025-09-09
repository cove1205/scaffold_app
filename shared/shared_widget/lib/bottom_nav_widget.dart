import 'package:flutter/material.dart';

import 'lazy_load_indexed_stack.dart';

class BottomNavItem {
  final Widget page;

  final Widget icon;

  final String? name;

  final Widget? selectedIcon;

  BottomNavItem({
    required this.page,
    required this.icon,
    this.name,
    this.selectedIcon,
  });
}

/// 底部导航页面
class BottomNavPage extends StatefulWidget {
  const BottomNavPage({
    super.key,
    required this.menuList,
    this.floatingActionButton,
    this.appBar,
  });

  final List<BottomNavItem> menuList;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: widget.menuList
            .map(
              (e) => BottomNavigationBarItem(
                icon: e.icon,
                activeIcon: e.selectedIcon,
                label: e.name,
              ),
            )
            .toList(),
        onTap: (int index) {
          if (currentIndex != index) {
            setState(() {
              currentIndex = index;
            });
          }
        },
        currentIndex: currentIndex,
      ),
      body: LazyLoadIndexedStack(
        index: currentIndex,
        children: widget.menuList.map((e) => e.page).toList(),
      ),
    );
  }
}
