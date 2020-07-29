import 'package:flutter/material.dart';
import 'constants.dart';
import 'globals.dart';
import 'dart:core';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'widgets/movielistbuilder.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

//Contents of DropDownButtons
List<DropdownMenuItem> yearDropItems1 = List<DropdownMenuItem>();
List<DropdownMenuItem> yearDropItems2 = List<DropdownMenuItem>();
List<DropdownMenuItem> genreDropItems = List<DropdownMenuItem>();

class _MainScreenState extends State<MainScreen> {
  final kValueController = TextEditingController();

  //Contents of the lists
  var yearMovies = Map();
  var genreyearMovies = Map();
  var topKMovies = Map();

  //Indexes for the DropDownButtons
  int yearIndex1, yearIndex2, genreIndex;

  //Offsets used for the WebAPI queries
  List<int> offset = [0, 0, 0];

  //Flages used for the WebAPI queries
  List<bool> searchflag = [false, false, false];

  /*****************************************************************************
   * Callback functions to navigate through the movies' list
   * **************************************************************************/
  offset0Previous() {
    setState(() {
      offset[0] -= 10;
      searchflag[0] = true;
    });
  }

  offset0Next() {
    setState(() {
      offset[0] += 10;
      searchflag[0] = true;
    });
  }

  offset1Previous() {
    setState(() {
      offset[1] -= 10;
      searchflag[1] = true;
    });
  }

  offset1Next() {
    setState(() {
      offset[1] += 10;
      searchflag[1] = true;
    });
  }

  offset2Previous() {
    setState(() {
      offset[2] -= 10;
      searchflag[2] = true;
    });
  }

  offset2Next() {
    setState(() {
      offset[2] += 10;
      searchflag[2] = true;
    });
  }
/**************************************************************************** */

  void errorTreatment(e) {
    //Check if the error was a timeout or if the server could not be reached
    if (e == TimeoutException) {
      final snackBar = SnackBar(
          content: Text("Server timeout"),
          action: SnackBarAction(label: "OK", onPressed: () {}));
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(snackBar);
    } else {
      final snackBar = SnackBar(
          content: Text("Server could not be reached"),
          action: SnackBarAction(label: "OK", onPressed: () {}));
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  Future yearQuery() async {
    //future function for the year queries
    if (searchflag[0] == false) return yearMovies;
    searchflag[0] = false;
    if (yearIndex1 == null) {
      //If there is no value set in the DropDown Button, show the message to the user
      final snackBar = SnackBar(
          content: Text("Choose a value for year"),
          action: SnackBarAction(label: "OK", onPressed: () {}));
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(snackBar);
      return genreyearMovies;
    }
    http.Response response;
    //Get the number of movies that were launched in that year
    String url = URL + "/moviesApi/v1/yearcount?year=$yearIndex1";
    try {
      response = await http.get(url).timeout(const Duration(seconds: 5));
    } catch (e) {
      errorTreatment(e);
      return yearMovies;
    }
    int total = int.parse(response.body);
    //Get a maximum of 10 movies to be shown in the current page starting at offset0
    int offset0 = offset[0];
    url = URL + "/moviesApi/v1/yearquery?year=$yearIndex1&offset=$offset0";
    try {
      response = await http.get(url).timeout(const Duration(seconds: 5));
    } catch (e) {
      errorTreatment(e);
      return yearMovies;
    }
    yearMovies["offset"] = offset[0];
    yearMovies["total"] = total;
    yearMovies["data"] = json.decode(response.body);
    print(yearMovies);
    return yearMovies;
  }

  Future genreyearQuery() async {
    //future function for the genre and year queries
    if (searchflag[1] == false) return genreyearMovies;
    searchflag[1] = false;
    if (yearIndex2 == null || genreIndex == null) {
      //If there is no value set in the DropDown Button, show the message to the user
      final snackBar = SnackBar(
          content: Text("Choose a value for year and genre"),
          action: SnackBarAction(label: "OK", onPressed: () {}));
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(snackBar);
      return genreyearMovies;
    }
    http.Response response;
    //Get the number of movies that were launched in that year and of that genre
    String genre = GENRES[genreIndex];
    String url = URL + "/moviesApi/v1/genrecount?year=$yearIndex2&genre=$genre";
    try {
      response = await http.get(url).timeout(const Duration(seconds: 5));
    } catch (e) {
      errorTreatment(e);
      return genreyearMovies;
    }
    int offset1 = offset[1];
    int total = int.parse(response.body);
    //Get a maximum of 10 movies to be shown in the current page starting at offset1
    url = URL +
        "/moviesApi/v1/genreyearquery?year=$yearIndex2&genre=$genre&offset=$offset1";
    try {
      response = await http.get(url).timeout(const Duration(seconds: 5));
    } catch (e) {
      errorTreatment(e);
      return genreyearMovies;
    }
    genreyearMovies["offset"] = offset[1];
    genreyearMovies["total"] = total;
    genreyearMovies["data"] = json.decode(response.body);
    print(genreyearMovies);
    return genreyearMovies;
  }

  bool isInteger(str) {
    //Check if the string is an integer number
    return int.tryParse(str) != null;
  }

  Future topKQuery() async {
    //future function for the top k ratings queries
    if (searchflag[2] == false) return topKMovies;
    searchflag[2] = false;
    if (!isInteger(kValueController.text)) {
      //If the value set for K is not integer, show the message to the user
      final snackBar = SnackBar(
          content: Text("Choose an integer number for K"),
          action: SnackBarAction(label: "OK", onPressed: () {}));
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(snackBar);
      searchflag[2] = false;
      return topKMovies;
    }
    http.Response response;
    String value = kValueController.text;
    int offset2 = offset[2];
    //Get a maximum of 10 movies to be shown in the current page starting at offset2
    String url = URL + "/moviesApi/v1/topkrating?K=$value&offset=$offset2";
    try {
      response = await http.get(url).timeout(const Duration(seconds: 5));
    } catch (e) {
      errorTreatment(e);
      return topKMovies;
    }
    topKMovies["offset"] = offset[2];
    topKMovies["total"] = int.parse(kValueController.text);
    topKMovies["data"] = json.decode(response.body);
    print(topKMovies);
    return topKMovies;
  }

  @override
  void initState() {
    super.initState();
    /**************************************************************************
     * Initializes the content of the DropDownButtons
     **************************************************************************/
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
    //Get the pixel dimmensions of the screen
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
            body: TabBarView(children: [
              Scaffold(
                  body: Column(children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DropdownButton(
                      hint: Text("Year"),
                      items: yearDropItems1,
                      value: yearIndex1,
                      onChanged: (value) {
                        setState(() {
                          yearIndex1 = value;
                        });
                      },
                    ),
                    Divider(),
                    MaterialButton(
                        onPressed: () {
                          setState(() {
                            searchflag[0] = true;
                            offset[0] = 0;
                          });
                        },
                        child: Text("Query"))
                  ],
                ),
                MovieListBuilder(
                    futureFunction: yearQuery,
                    previousCallback: offset0Previous,
                    nextCallback: offset0Next)
              ])),
              Scaffold(
                  body: Column(children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DropdownButton(
                      hint: Text("Year"),
                      items: yearDropItems2,
                      value: yearIndex2,
                      onChanged: (value) {
                        setState(() {
                          yearIndex2 = value;
                        });
                      },
                    ),
                    Divider(),
                    DropdownButton(
                      hint: Text("Genre"),
                      items: genreDropItems,
                      value: genreIndex,
                      onChanged: (value) {
                        setState(() {
                          genreIndex = value;
                        });
                      },
                    ),
                    Divider(),
                    MaterialButton(
                        onPressed: () {
                          setState(() {
                            searchflag[1] = true;
                            offset[1] = 0;
                          });
                        },
                        child: Text("Query"))
                  ],
                ),
                MovieListBuilder(
                    futureFunction: genreyearQuery,
                    previousCallback: offset1Previous,
                    nextCallback: offset1Next)
              ])),
              Scaffold(
                  body: Column(children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        width: 150,
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "value",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 12.0),
                          ),
                          style: TextStyle(color: Colors.black, fontSize: 12.0),
                          controller: kValueController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: false),
                        )),
                    Divider(),
                    MaterialButton(
                        onPressed: () {
                          setState(() {
                            searchflag[2] = true;
                            offset[2] = 0;
                          });
                        },
                        child: Text("Query"))
                  ],
                ),
                MovieListBuilder(
                    futureFunction: topKQuery,
                    previousCallback: offset2Previous,
                    nextCallback: offset2Next)
              ]))
            ])));
  }
}
