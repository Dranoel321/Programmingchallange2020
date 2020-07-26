using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Data.SQLite;
using System.Globalization;

namespace CriarBanco
{
    class Program
    {
        private const bool SUCCESS = false;
        private const bool FAIL = true;
        private static string databasePath = @"URI=file:C:\Users\Pichau\source\repos\CriarBanco\banco.db"; //Replace this value with the path that will be used in the database
        private static string moviesPath = @"C:\Users\Pichau\Desktop\ml-25m\movies.csv"; //Replace this value with the path to movies.csv
        private static string ratingsPath = @"C:\Users\Pichau\Desktop\ml-25m\ratings.csv"; //Replace this value with the path to ratings.csv

        static void Main(string[] args)
        {
            using var con = new SQLiteConnection(databasePath);
            try
            {
                con.Open();
            }
            catch
            {
                Console.WriteLine("Failed to open database!");
                Environment.Exit(0);
            }

            Console.WriteLine("Banco inicializado com sucesso!");


            if (createTables(con))
            {
                con.Close();
                Environment.Exit(0);
            }
            Console.WriteLine("Aguarde o processamento das notas...");
            string line = "";

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
                    "\"genre\" INTEGER," +
                    "PRIMARY KEY(\"genreId\" AUTOINCREMENT))";
            try
            {
                cmd.ExecuteNonQuery();
            }
            catch
            {
                Console.WriteLine("Falha ao criar tabela genres!");
                return FAIL;
            }

            Console.WriteLine("Tabela genres inicializada com sucesso!");

            cmd = new SQLiteCommand(con);
            //Create the table movies
            cmd.CommandText = "CREATE TABLE IF NOT EXISTS \"movies\" ( " +
                "\"movieId\"   INTEGER," +
                "\"name\"  TEXT," +
                "\"rating\"    REAL," +
                "\"year\"  INTEGER," +
                "PRIMARY KEY(\"movieId\"))";
            try
            {
                cmd.ExecuteNonQuery();
            }
            catch
            {
                Console.WriteLine("Falha ao criar tabela movies!");
                return FAIL;
            }
            Console.WriteLine("Tabela movies inicializada com sucesso!");
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
            Console.WriteLine("Notas processadas!");
            Console.WriteLine("Aguarde o preenchimento das tabelas...");
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
                    string[] genres = line.Split("|");
                    foreach (string genre in genres)
                    {
                        cmd = new SQLiteCommand(con);
                        cmd.CommandText = String.Format("INSERT INTO genres(movieId, genre) VALUES({0}, \"{1}\")", movieId, genre);
                        cmd.ExecuteNonQuery();
                    }
                }
                cmd = new SQLiteCommand(con);

                //Insert the movie specs into the movies table
                double meanRating = 0;
                if (ratings.ContainsKey(movieId) && ratings[movieId].Item2 != 0)
                {
                    meanRating = (ratings[movieId].Item1 / ratings[movieId].Item2);
                }
                cmd = new SQLiteCommand(con);
                cmd.CommandText = String.Format(CultureInfo.GetCultureInfo("en-CA"), "INSERT INTO movies(movieId, name, rating, year) VALUES({0}, \"{1}\", {2:0.00000000}, {3})",
                                                                                    movieId, movie, meanRating, year);
                cmd.ExecuteNonQuery();
                index++;
            }

            transaction.Commit();
            Console.WriteLine("Tabelas preenchidas com sucesso!");
            cmd.Dispose();
            moviesFile.Close();
            return SUCCESS;
        }
    }
}
