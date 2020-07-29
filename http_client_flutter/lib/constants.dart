const URL =
    "http://192.168.0.48:44335"; //Must be changed to the IP where the WebAPI is served

//These are constants based on a given cellphone that was used to develop this application
//The c-values are the useful area of the screen
const double defaultHeight = 712;
const double defaultWidth = 360;
const double defaultCWidth = 681;
const double defaultCHeight = 360;

const double EPS = 1e-5;
const int CARD_SIZE = 210;
const int BUTTON_SIZE = 70;
const TITLE_LIMIT = 45;

double appheight = 712; //The height in pixels of the screen
double appwidth = 360; //The width in pixels of the screen

//The genres that were in the dataset
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
