import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:kamusi/utils/colors.dart';

import 'package:kamusi/helpers/app_settings.dart';
import 'package:kamusi/models/generic_model.dart';
import 'package:kamusi/helpers/sqlite_helper.dart';
import 'package:kamusi/widgets/as_loader.dart';

class TabViewGeneric extends StatefulWidget {
  final String tabname;
  const TabViewGeneric(this.tabname);

  @override
  TabViewGenericState createState() => TabViewGenericState();
}

class TabViewGenericState extends State<TabViewGeneric> {
  AsLoader loader = AsLoader();
  SqliteHelper db = SqliteHelper();

  Future<Database> dbFuture;
  List<GenericModel> items = List<GenericModel>();
  List<String> letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'R', 'S', 'T', 'U', 'V', 'W', 'Y', 'Z' ];
  String letterSearch;

  TabViewGenericState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => updateListView(context));
  }

  void updateListView(BuildContext context) async {
    loader.showWidget();
    dbFuture = db.initializeDatabase();
    dbFuture.then((database) {
      Future<List<GenericModel>> itemListFuture = db.getGenericList(widget.tabname);
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
      Future<List<GenericModel>> itemListFuture = db.getGenericSearch(_letter, widget.tabname, true);
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
              itemBuilder: listView,
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

  Widget listView(BuildContext context, int index) {
    String strContent = "<b>" + items[index].title + "</b>";

    try {
      if (items[index].maana.length > 1) {
        strContent = strContent + '<ul>';
        var strContents = items[index].maana.split(";");

        if (strContents.length > 1) {
          try {
            for (int i = 0; i < strContents.length; i++) {
              var strExtra = strContents[i].split(":");
              strContent = strContent + "<li>" + strExtra[0].trim() + "</li>";
            }
          } catch (Exception) {}
        } else {
          var strExtra = strContents[0].split(":");
          strContent = strContent + "<li>" + strExtra[0].trim() + "</li>";
        }
        strContent = strContent + '</ul>';
      }
      return Card(
        elevation: 2,
        child: GestureDetector(
          child: Html(
            data: strContent,
            style: {
              "html": Style(
                fontSize: FontSize(20.0),
              ),
              "ul": Style(
                fontSize: FontSize(18.0),
              ),
            },
          ),
        ),
      );
    } catch (Exception) {
      return Container();
    }
  }

}