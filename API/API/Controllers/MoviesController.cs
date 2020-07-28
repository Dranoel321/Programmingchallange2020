using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Text.Json;
using System.Text.Json.Serialization;
using API.Models;
using System.Data.SQLite;
using Microsoft.Ajax.Utilities;


namespace API.Controllers
{
    [RoutePrefix("moviesapi")]
    public class MoviesController : ApiController
    {
        private static string databasePath = @"URI=file:C:\Users\Pichau\Documents\GitHub\Programmingchallange2020\banco.db"; //Replace this value with the path that will be used in the database
     
        [AcceptVerbs("GET")]
        [Route("yearquery")]
        public string QueryByYear(string token, int year, int offset)
        {
            SQLiteConnection con = new SQLiteConnection(databasePath);
            con.Open();
            List<MovieModel> movies = new List<MovieModel>();
            SQLiteCommand cmd = new SQLiteCommand(con);
            cmd.CommandText = String.Format("SELECT name, genres, votes, rating, year FROM movies where year = {0} LIMIT {1}, 10", year, offset);
            var selectReader = cmd.ExecuteReader();
            while(selectReader.Read())
            {
                string name = selectReader["name"].ToString();
                string genres = selectReader["genres"].ToString();
                int votes = int.Parse(selectReader["votes"].ToString());
                double rating = double.Parse(selectReader["rating"].ToString());
                movies.Add(new MovieModel(name, genres, votes, rating, year));
            }
            con.Close();
            con.Dispose();
            cmd.Dispose();
            return JsonSerializer.Serialize(movies);
        }

        [AcceptVerbs("GET")]
        [Route("yearcount")]
        public string YearCount(string token, int year)
        {
            SQLiteConnection con = new SQLiteConnection(databasePath);
            con.Open();
            SQLiteCommand cmd = new SQLiteCommand(con);
            cmd.CommandText = String.Format("SELECT COUNT(name) AS ret FROM movies WHERE year = {0}", year);
            var selectReader = cmd.ExecuteReader();
            selectReader.Read();
            int elements = int.Parse(selectReader["ret"].ToString());
            con.Close();
            con.Dispose();
            cmd.Dispose();
            return JsonSerializer.Serialize(elements);
        }

        [AcceptVerbs("GET")]
        [Route("genreyearquery")]
        public string QueryByGenreAndYear(string token, int year, string genre, int offset)
        {
            SQLiteConnection con = new SQLiteConnection(databasePath);
            con.Open();

            List<MovieModel> movies = new List<MovieModel>();
            SQLiteCommand cmd = new SQLiteCommand(con);
            cmd.CommandText = String.Format("SELECT m.name, m.genres, m.votes, m.rating, m.year as ret FROM movies as m JOIN genres as g " + 
                "WHERE g.genre = \"{0}\" AND m.year = {1} AND g.movieId = m.movieId ORDER BY m.name ASC LIMIT {2}, 10", genre, year, offset);
            var selectReader = cmd.ExecuteReader();
            while (selectReader.Read())
            {
                string name = selectReader["name"].ToString();
                string genres = selectReader["genres"].ToString();
                int votes = int.Parse(selectReader["votes"].ToString());
                double rating = double.Parse(selectReader["rating"].ToString());
                movies.Add(new MovieModel(name, genres, votes, rating, year));
            }
            System.Diagnostics.Debug.WriteLine(year);
            con.Close();
            con.Dispose();
            cmd.Dispose();
            return JsonSerializer.Serialize(movies);
        }

        [AcceptVerbs("GET")]
        [Route("genrecount")]
        public string GenreCount(string token, int year, string genre)
        {
            SQLiteConnection con = new SQLiteConnection(databasePath);
            con.Open();
            SQLiteCommand cmd = new SQLiteCommand(con);
            cmd.CommandText = String.Format("SELECT COUNT(m.name) as ret FROM movies as m JOIN genres as g WHERE g.genre = \"{0}\" " + 
                "AND m.year = {1} AND g.movieId = m.movieId ORDER BY m.name ASC", genre, year);
            var selectReader = cmd.ExecuteReader();
            selectReader.Read();
            int elements = int.Parse(selectReader["ret"].ToString());
            con.Close();
            con.Dispose();
            cmd.Dispose();
            return JsonSerializer.Serialize(elements);
        }

        [AcceptVerbs("GET")]
        [Route("topkrating")]
        public string GetKBestRatings(string token, int K)
        {
            SQLiteConnection con = new SQLiteConnection(databasePath);
            con.Open();
            SQLiteCommand cmd = new SQLiteCommand(con);
            cmd.CommandText = String.Format("SELECT name, genres, votes, rating, year FROM movies ORDER BY rating DESC, votes DESC, name ASC LIMIT 0, 10");
            var selectReader = cmd.ExecuteReader();
            List<MovieModel> movies = new List<MovieModel>();
            while (selectReader.Read())
            {
                movies.Add(new MovieModel(selectReader["name"].ToString(), selectReader["genres"].ToString(), int.Parse(selectReader["votes"].ToString()), 
                    double.Parse(selectReader["rating"].ToString()), int.Parse(selectReader["year"].ToString())));
            }
            con.Close();
            con.Dispose();
            cmd.Dispose();
            return JsonSerializer.Serialize(movies);
        }
    }
}
