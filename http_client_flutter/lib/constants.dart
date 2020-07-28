const URL = "https://192.168.0.48:44335";
double defaultHeight = 712;
double defaultWidth = 360;
double defaultCHeight = 360;
double defaultCWidth = 681;
double appheight = 712;
double appwidth = 360;
double appcheight = 360;
double appcwidth = 681;

const List<String> GENRES = [
  "Action",
  "Adventure",
  "Animation",
  "Children",
  "Comedy",
  "Crime",
  "Documentary",
  "Drama",
  "Fantasy",
  "Film-Noir",
  "Horror",
  "IMAX",
  "Musical",
  "Mystery",
  "Romance",
  "Sci-Fi",
  "Thriller",
  "War",
  "Western"
];

getHeight(height) {
  return (height / defaultHeight) * appheight;
}

getWidth(width) {
  return (width / defaultWidth) * appwidth;
}

getCHeight(height) {
  return (height / defaultCHeight) * appcheight;
}

getCWidth(width) {
  return (width / defaultCWidth) * appcwidth;
}
