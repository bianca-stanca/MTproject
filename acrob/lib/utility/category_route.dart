import 'package:flutter/material.dart';
import 'package:acrob/screens/info_page.dart';
import 'package:acrob/screens/profile_page.dart';
import 'package:acrob/screens/homepage.dart';
import 'package:acrob/database/db.dart';
import '../database/db.dart';
import 'backdrop.dart';
import 'category.dart';
import 'category_title.dart';
import 'package:flutter/cupertino.dart';

class CategoryRoute extends StatefulWidget {
  @override
  _CategoryRouteState createState() => _CategoryRouteState();
}

var url = 'https://drive.switch.ch/public.php/webdav/';

const simpleTaskKey = "simpleTask";
const periodicTask = "periodicTask";

class _CategoryRouteState extends State<CategoryRoute> {
  Category _defaultCategory;
  Category _currentCategory;
  Widget _currentWidget;
  final _categories = <Category>[];
  static const _categoryNames = <String>['Home', 'Account', 'Info'];
  static const _baseColors = <ColorSwatch>[
    ColorSwatch(0xFF448AFF, {
      'highlight': Color(0xFF82B1FF),
      'splash': Color(0xFF448AFF),
    }),
    ColorSwatch(0xFFFFD28E, {
      'highlight': Color(0xFFFFD28E),
      'splash': Color(0xFFFFA41C),
    }),
    // ColorSwatch(0xFFFFB7DE, {
    //   'highlight': Color(0xFFFFB7DE),
    //   'splash': Color(0xFFF94CBF),
    // }),
    // ColorSwatch(0xFFCE9A9A, {
    //   'highlight': Color(0xFFF94D56),
    //   'splash': Color(0xFF912D2D),
    //   'error': Color(0xFF912D2D),
    // }),
    ColorSwatch(0xFFD7C0E2, {
      'highlight': Color(0xFFD7C0E2),
      'splash': Color(0xFFCA90E5),
    }),
    ColorSwatch(0xFF81A56F, {
      'highlight': Color(0xFF81A56F),
      'splash': Color(0xFF7CC159),
    }),
  ];
  static const _icons = <IconData>[
    Icons.home,
    Icons.person,
    Icons.info,
  ];

  bool sampling = false;

  _initDb() async {
    return DBProvider.db;
  }

  @override
  void initState() {
    _initDb();
    super.initState();
    print("Categories: ");
    print(_categoryNames.length);
    for (var i = 0; i < _categoryNames.length; i++) {
      var category = Category(
        name: _categoryNames[i],
        color: _baseColors[i],
        icon: _icons[i],
      );
      if (i == 0) {
        _defaultCategory = category;
      }
      _categories.add(category);
    }
  }

  /// Function to call when a [Category] is tapped.
  void _onCategoryTap(Category category) {
    setState(() {
      _currentCategory = category;
      if (category.name == "Home") {
        _currentWidget = Homepage(
          category: _currentCategory,
        );
      } else if (category.name == "Account") {
        _currentWidget = ProfilePage(
          category: _currentCategory,
        );
      } else if (category.name == "Info") {
        _currentWidget = InfoPage(
          category: _currentCategory,
        );
      }
    });
  }

  /// Makes the correct number of rows for the list view.
  ///
  /// For portrait, we use a [ListView].
  Widget _buildCategoryWidgets() {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return CategoryTile(
          category: _categories[index],
          onTap: _onCategoryTap,
        );
      },
      itemCount: _categories.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final listView = Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 48.0,
      ),
      child: _buildCategoryWidgets(),
    );

    return Backdrop(
      currentCategory:
          _currentCategory == null ? _defaultCategory : _currentCategory,
      frontPanel: _currentCategory == null
          ? Homepage(
              category: _defaultCategory,
            )
          : _currentWidget,
      backPanel: listView,
      frontTitle: Image.asset(
        'assets/images/acrob_logo.png',
        height: 35,
        alignment: Alignment(1.0, 1.0),
      ),
      backTitle: Text('Menu'),
    );
  }
}
