import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:kamusi/utils/colors.dart';

import 'package:kamusi/helpers/app_settings.dart';
import 'package:kamusi/models/neno_model.dart';
import 'package:kamusi/helpers/sqlite_helper.dart';
import 'package:kamusi/views/neno_item.dart';
import 'package:kamusi/widgets/as_loader.dart';

class TabViewNeno extends StatefulWidget {

  @override
  TabViewNenoState createState() => TabViewNenoState();
}

class TabViewNenoState extends State<TabViewNeno> {
  AsLoader loader = AsLoader();
  SqliteHelper db = SqliteHelper();

  Future<Database> dbFuture;
  List<NenoModel> items = List<NenoModel>();
  List<String> letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'R', 'S', 'T', 'U', 'V', 'W', 'Y', 'Z' ];
  String letterSearch;

  TabViewNenoState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => updateListView(context));
  }

  void updateListView(BuildContext context) async {
    loader.showWidget();
    dbFuture = db.initializeDatabase();
    dbFuture.then((database) {
      Future<List<NenoModel>> itemListFuture = db.getNenoList();
      itemListFuture.then((resultList) {
        setState(() {
          items = resultList;
          loader.hideWidget();
        });
      });
    });
  }

  void setSearchingLetter(String _letter) async {
    loader.showWidget();
    letterSearch = _letter;
    items.clear();
    dbFuture = db.initializeDatabase();
    dbFuture.then((database) {
      Future<List<NenoModel>> itemListFuture = db.getNenoSearch(_letter, true);
      itemListFuture.then((resultList) {
        setState(() {
          items = resultList;
          loader.hideWidget();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Provider.of<AppSettings>(context).isDarkMode ? BoxDecoration()
          : BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [ 0.1, 0.4, 0.6, 0.9 ],
                colors: [ Colors.black, ColorUtils.baseColor,  ColorUtils.primaryColor, ColorUtils.lightColor ]),
            ),
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height - 130,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            margin: EdgeInsets.only(top: 25),
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return NenoItem('ItemIndex_' + items[index].id.toString(), items[index], context);
              }
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            //margin: EdgeInsets.only(top: 5),
            child: Column(
              children: <Widget>[
                Container(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    itemCount: letters.length,
                    itemBuilder: lettersView,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 200,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: loader,
          ),
        ],
      ),
    );
  }

  Widget lettersView(BuildContext context, int index) {
    return Container(
      width: 60,
      child: GestureDetector(
        onTap: () {
          setSearchingLetter(letters[index]);
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
            side: BorderSide(color: Provider.of<AppSettings>(context).isDarkMode ? ColorUtils.white : ColorUtils.secondaryColor, width: 1.5),
          ),      
          elevation: 5,
          child: Hero(
            tag: letters[index],
            child: Container(
              padding: const EdgeInsets.all(2),
              child: Center(
                child: Text(
                  letters[index],
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}