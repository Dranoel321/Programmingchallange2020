import 'package:flutter/material.dart';
import 'moviecard.dart';
import '../constants.dart';
import '../globals.dart';

Widget MovieList(BuildContext context, AsyncSnapshot snapshot, previousFunction,
    nextFunction) {
  int listSize = 0;
  if (snapshot.data.containsKey("data"))
    listSize = snapshot.data["data"].length;
  return ListView.builder(
      itemCount: listSize +
          (listSize != 0
              ? 2
              : 0), //Only builds the buttons if there is any data
      itemBuilder: (context, index) {
        if (index < listSize) {
          //Build MovieCard for the data relative to the movies
          return MovieCard(
              movie: snapshot.data["data"][index]["Name"],
              year: snapshot.data["data"][index]["Year"],
              genres: snapshot.data["data"][index]["Genres"],
              votes: snapshot.data["data"][index]["Votes"],
              rating: snapshot.data["data"][index]["Rating"]);
        } else if (index == listSize) {
          //Build the previousButton
          return SizedBox(
              height: getHeight(BUTTON_SIZE),
              child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.0)),
                  child: Column(children: <Widget>[
                    MaterialButton(
                        color: Colors.blue,
                        disabledColor: Colors.grey,
                        onPressed: snapshot.data["offset"] != 0
                            ? previousFunction
                            : null,
                        child: Text("Previous")),
                    Divider()
                  ])));
        } else {
          //build the nextButton
          return SizedBox(
              height: getHeight(BUTTON_SIZE),
              child: Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22.0)),
                  child: Column(children: <Widget>[
                    MaterialButton(
                        color: Colors.blue,
                        disabledColor: Colors.grey,
                        onPressed: snapshot.data["offset"] + 10 <
                                snapshot.data["total"]
                            ? nextFunction
                            : null,
                        child: Text("Next")),
                    Divider()
                  ])));
        }
      });
}
