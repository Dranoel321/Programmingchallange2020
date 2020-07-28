import 'package:flutter/material.dart';
import 'constants.dart';
import 'dart:core';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

List<DropdownMenuItem> yearDropItems1 = List<DropdownMenuItem>();
List<DropdownMenuItem> yearDropItems2 = List<DropdownMenuItem>();
List<DropdownMenuItem> genreDropItems = List<DropdownMenuItem>();

class _MainScreenState extends State<MainScreen> {
  GlobalKey<State> keyYear1 = GlobalKey<State>();
  GlobalKey<State> keyYear2 = GlobalKey<State>();
  GlobalKey<State> keyGenre = GlobalKey<State>();
  int yearIndex1, yearIndex2, genreIndex;
  bool searchflag = false;

  Future<List<Map>> yearQuery() async {
    if (searchflag == false) return List<Map>();

    http.Response response;
    String url = URL + "/moviesApi/yearquery?year=$yearIndex1&token=a&offset=0";
    print(url);
    response = await http.get(url);
    print(response.statusCode);
    print(response.body);
    searchflag = false;
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    yearDropItems1 = List<DropdownMenuItem>();
    yearDropItems2 = List<DropdownMenuItem>();
    genreDropItems = List<DropdownMenuItem>();
    for (int i = 2019; i >= 1874; i--) {
      yearDropItems1.add(DropdownMenuItem(child: Text(i.toString()), value: i));
      yearDropItems2.add(DropdownMenuItem(child: Text(i.toString()), value: i));
    }
    for (int i = 0; i < GENRES.length; i++) {
      genreDropItems
          .add(new DropdownMenuItem(child: Text(GENRES[i]), value: i));
    }
  }

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    appcwidth = queryData.size.width;
    appcheight = queryData.size.height;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                  child: Text("Query By Year",
                      style: TextStyle(color: Colors.white))),
              Tab(
                  child: Text("Query By Year And Genre",
                      style: TextStyle(color: Colors.white))),
              Tab(
                  child: Text("Query Top K Rating",
                      style: TextStyle(color: Colors.white))),
            ],
          ),
          title: Text('Movies API'),
        ),
        body: TabBarView(
          children: [
            Scaffold(
                body: Column(children: <Widget>[
              Row(
                children: <Widget>[
                  DropdownButton(
                    key: keyYear1,
                    items: yearDropItems1,
                    value: yearIndex1,
                    onChanged: (value) {
                      setState(() {
                        yearIndex1 = value;
                      });
                    },
                  ),
                  MaterialButton(
                      onPressed: () {
                        setState(() {
                          searchflag = true;
                        });
                      },
                      child: Text("BORA"))
                ],
              ),
              Expanded(
                  child: FutureBuilder(
                      future: yearQuery(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return Container(
                              width: 200.0,
                              height: 200.0,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 5.0,
                              ),
                            );
                          default:
                            if (snapshot.hasError)
                              return Container();
                            else
                              return Container();
                          //return _createGifTable(context, snapshot);
                        }
                      }))
            ])),
            Scaffold(
                body: Column(children: <Widget>[
              Row(
                children: <Widget>[
                  DropdownButton(
                    key: keyYear2,
                    items: yearDropItems2,
                    value: yearIndex2,
                    onChanged: (value) {
                      setState(() {
                        yearIndex2 = value;
                      });
                    },
                  ),
                  DropdownButton(
                    key: keyGenre,
                    items: genreDropItems,
                    value: genreIndex,
                    onChanged: (value) {
                      setState(() {
                        genreIndex = value;
                      });
                    },
                  )
                ],
              ),
            ])),
            Scaffold()
          ],
        ),
      ),
    );
  }
}
