using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web;

namespace API.Models
{
    public class MovieModel
    {
        private string name;
        private string genres;
        private int votes;
        private int year;
        private double rating;

        public MovieModel()
        {
        }

        public MovieModel(string data)
        {
        }

        public MovieModel(string _name, string _genres, int _votes, double _rating, int _year)
        {
            name = _name;
            genres = _genres;
            votes = _votes;
            rating = _rating;
            year = _year;
        }

        public string Name
        {
            get
            {
                return name;
            }

            set
            {
                name = value;
            }
        }

        public string Genres
        {
            get
            {
                return genres;
            }

            set
            {
                genres = value;
            }
        }

        public int Votes
        {
            get
            {
                return votes;
            }

            set
            {
                votes = value;
            }
        }

        public double Rating
        {
            get
            {
                return rating;
            }
            set
            {
                rating = value;
            }
        }

        public int Year
        {
            get
            {
                return year;
            }
            set
            {
                year = value;
            }
        }
    }
}