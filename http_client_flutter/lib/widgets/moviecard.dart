import 'package:flutter/material.dart';
import '../constants.dart';
import '../globals.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:two_letter_icon/two_letter_icon.dart';

class MovieCard extends StatelessWidget {
  const MovieCard(
      {Key key,
      @required String movie,
      @required String genres,
      @required int year,
      @required int votes,
      @required double rating})
      : _movie = movie,
        _genres = genres,
        _year = year,
        _votes = votes,
        _rating = rating,
        super(key: key);
  final String _movie;
  final String _genres;
  final int _year;
  final int _votes;
  final double _rating;

  buildTitle(String movieName, int movieYear) {
    //This function is used to limit the title of the movie so that the widget not overflow
    //It's used to ensure that the size of the MovieCards are standardized
    if (movieName.length > TITLE_LIMIT)
      movieName = movieName.substring(0, TITLE_LIMIT);
    if (movieYear == -1)
      return movieName;
    else
      return "$movieName ($movieYear)";
  }

  double roundRating(double ratingValue) {
    //This function is used to round the values to the nearest 0.5 stars multiple
    //as the widget used only supports full and half stars
    int lo = ratingValue.floor();
    if (ratingValue <= lo + 0.25 - EPS) return lo + 0.0;
    if (ratingValue <= lo + 0.75 - EPS) return lo + 0.5;
    return lo + 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: getHeight(CARD_SIZE),
        child: Card(
          child: Row(
            children: <Widget>[
              SizedBox(
                  width: getWidth(80),
                  child: Container(
                    alignment: Alignment.center,
                    child: TwoLetterIcon(
                      _movie,
                    ),
                  )),
              Flexible(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                    Text(
                      buildTitle(_movie, _year),
                      style: TextStyle(
                        fontSize: getHeight(20),
                      ),
                    ),
                    Text(_genres),
                    Text("Votes: $_votes"),
                    RatingBar(
                      ignoreGestures: true,
                      initialRating: roundRating(_rating),
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {},
                    ),
                    Text("Rating: " + _rating.toStringAsFixed(2) + " out of 5")
                  ]))
            ],
          ),
        ));
  }
}
