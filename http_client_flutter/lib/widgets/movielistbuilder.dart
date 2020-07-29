import 'package:flutter/material.dart';
import 'movielist.dart';

class MovieListBuilder extends StatelessWidget {
  const MovieListBuilder(
      {Key key, futureFunction, previousCallback, nextCallback})
      : _futureFunction = futureFunction,
        _previousCallback = previousCallback,
        _nextCallback = nextCallback,
        super(key: key);

  final _futureFunction;
  final _previousCallback;
  final _nextCallback;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: FutureBuilder(
            future:
                _futureFunction(), //When setState is called this widget is built based on the return of _futureFunction
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Container(
                    width: 200.0,
                    height: 200.0,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 5.0,
                    ),
                  );
                default:
                  if (snapshot.hasError)
                    return Container();
                  else
                    return MovieList(
                        context, snapshot, _previousCallback, _nextCallback);
              }
            }));
  }
}
