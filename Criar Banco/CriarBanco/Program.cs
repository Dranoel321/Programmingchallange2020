using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Data.SQLite;
using System.Drawing.Printing;
using System.Globalization;
using System.IO;

namespace CriarBanco
{
    class Program
    {
        private static string path = Directory.GetCurrentDirectory();
        private const bool SUCCESS = false;
        private const bool FAIL = true;
        private static string databasePath = "";
        private static string moviesPath = "";
        private static string ratingsPath = "";

        static void Main(string[] args)
        {
            path = path.Replace(@"Criar Banco\CriarBanco", "");
            databasePath = "URI=file:" + path + "banco.db"; //Replace this value with the path that will be used in the database
            moviesPath = path + @"dataset\movies.csv"; //Replace this value with the path to movies.csv
            ratingsPath = path + @"dataset\ratings.csv"; //Replace this value with the path to ratings.csv
            SQLiteConnection con = new SQLiteConnection(databasePath);
            try
            {
                con.Open();
            }
            catch
            {
                Console.WriteLine("Failed to open database!");
                Environment.Exit(0);
            }

            Console.WriteLine("Database successfully created!");


            if (createTables(con))
            {
                con.Close();
                Environment.Exit(0);
            }
            Console.WriteLine("Wait while the votes are being processed...");

            Dictionary<int, Tuple<double, int>> ratings = new Dictionary<int, Tuple<double, int>>();

            if (buildRatingData(ref ratings))
            {
                con.Close();
                Environment.Exit(0);
            }

            if (fillDatabase(ref ratings, con))
            {
                con.Close();
                Environment.Exit(0);
            }
       
         }

        /********************************************************************************************************************************
         * isDigit(char character)
         * Description: Check if the given character is a digit
        ********************************************************************************************************************************/
        private static bool isDigit(char character)
        {
            return character >= '0' && character <= '9';
        }
        /********************************************************************************************************************************
         * createTables(SQLiteConnection con)
         * Description: Build the tables that will be used by the API
        ********************************************************************************************************************************/
        private static bool createTables(SQLiteConnection con)
        {
            var cmd = new SQLiteCommand(con);
            //Create the table genres
            cmd.CommandText = "CREATE TABLE IF NOT EXISTS \"genres\" ( " +

                    "\"genreId\"   INTEGER," +
                    "\"movieId\"   INTEGER," +
                    "\"genre\" TEXT," +
                    "PRIMARY KEY(\"genreId\" AUTOINCREMENT))";
            try
            {
                cmd.ExecuteNonQuery();
            }
            catch
            {
                Console.WriteLine("Failed to create table genres!");
                return FAIL;
            }

            Console.WriteLine("Table genres successfully created!");

            cmd = new SQLiteCommand(con);
            //Create the table movies
            cmd.CommandText = "CREATE TABLE IF NOT EXISTS \"movies\" ( " +
                "\"movieId\"   INTEGER," +
                "\"name\"  TEXT," +
                "\"rating\"    REAL," +
                "\"year\"  INTEGER," +
                "\"genres\" TEXT, " +
                "\"votes\" INTEGER, " +
                "PRIMARY KEY(\"movieId\"))";
            try
            {
                cmd.ExecuteNonQuery();
            }
            catch
            {
                Console.WriteLine("Failed to create table movies!");
                return FAIL;
            }
            Console.WriteLine("Table movies successfully created!");
            cmd.Dispose();
            return SUCCESS;
        }
        /********************************************************************************************************************************
         * buildRatingData(ref List<Tuple<double, int>> ratings)
         * Description: Process all users' ratings and obtain the mean rating for all movies
        ********************************************************************************************************************************/
        private static bool buildRatingData(ref Dictionary<int, Tuple<double, int>> ratings)
        {
            System.IO.StreamReader ratingsFile = new System.IO.StreamReader(ratingsPath);
            string line = "";
            ratingsFile.ReadLine();
            while ((line = ratingsFile.ReadLine()) != null)
            {
                if (line == "") break;
                string[] attributes = line.Split(',');
                int ratingmovieId = int.Parse(attributes[1]);
                double ratingValue = double.Parse(attributes[2], NumberStyles.AllowDecimalPoint, NumberFormatInfo.InvariantInfo);
                if (ratings.ContainsKey(ratingmovieId))
                    ratings[ratingmovieId] = new Tuple<double, int>(ratings[ratingmovieId].Item1 + ratingValue, ratings[ratingmovieId].Item2 + 1);
                else
                    ratings[ratingmovieId] = new Tuple<double, int>(ratingValue, 1);
            }
            ratingsFile.Close();
            return SUCCESS;
        }

        /********************************************************************************************************************************
         * fillDatabase(ref List<Tuple<double, int>> ratings, SQLiteConnection con)
         * Description: Provide the tables genres and movies the dataset processed data
        ********************************************************************************************************************************/
        private static bool fillDatabase(ref Dictionary<int, Tuple<double, int>> ratings, SQLiteConnection con)
        {
            var cmd = new SQLiteCommand(con);
            System.IO.StreamReader moviesFile = new System.IO.StreamReader(moviesPath);

            SQLiteTransaction transaction = con.BeginTransaction();
            string line = "";
            moviesFile.ReadLine();
            Console.WriteLine("Votes were processed!");
            Console.WriteLine("Wait while the tables are being filled...");
            int index = 0;
            while ((line = moviesFile.ReadLine()) != null)
            {
                int ptr = 0;
                //Separate the csv live
                while (line[ptr] != ',')
                {
                    ptr++;
                }
                int movieId = int.Parse(line.Substring(0, ptr));
                line = line.Substring(ptr + 1);
                for (ptr = line.Length - 1; ptr >= 0; ptr--)
                {
                    if (line[ptr] == ',')
                    {
                        break;
                    }
                }
                string movie = line.Substring(0, ptr);
                if (movie[0] == '"')
                {
                    movie = movie.Substring(1, movie.Length - 2);
                }
                line = line.Substring(ptr + 1);

                //Retrieve the year information
                string year = "-1";
                while (movie[movie.Length - 1] == ' ')
                {
                    movie = movie.Substring(0, movie.Length - 1);
                }
                if (movie[movie.Length - 1] == ')' && isDigit(movie[movie.Length - 2]))
                {
                    year = movie.Substring(movie.Length - 5, 4);
                    movie = movie.Substring(0, movie.Length - 6);
                }

                //Get all genres from that movie and insert into the genres table with the respective movieId
                if (line[0] != '(')
                {
                    string[] listGenres = line.Split("|");
                    foreach (string genre in listGenres)
                    {
                        cmd = new SQLiteCommand(con);
                        cmd.CommandText = String.Format("INSERT INTO genres(movieId, genre) VALUES({0}, \"{1}\")", movieId, genre);
                        cmd.ExecuteNonQuery();
                    }
                }
                cmd = new SQLiteCommand(con);
                string genres = line.Replace("|", ", ");
                //Insert the movie specs into the movies table
                double meanRating = 0;
                int votes = 0;
                if (ratings.ContainsKey(movieId) && ratings[movieId].Item2 != 0)
                {
                    votes = ratings[movieId].Item2;
                    meanRating = (ratings[movieId].Item1 / ratings[movieId].Item2);
                }
                cmd = new SQLiteCommand(con);
                cmd.CommandText = String.Format(CultureInfo.GetCultureInfo("en-CA"), "INSERT INTO movies(movieId, name, rating, year, genres, votes) VALUES({0}, " +
                    "\"{1}\", {2:0.00000000}, {3}, \"{4}\", {5})",movieId, movie, meanRating, year, genres, votes);
                cmd.ExecuteNonQuery();
                index++;
            }

            transaction.Commit();
            Console.WriteLine("Tables successfully filled!");
            cmd.Dispose();
            moviesFile.Close();
            return SUCCESS;
        }
    }
}
