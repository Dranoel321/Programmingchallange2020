Check the wiki for more information on the responses, database structure and info about the app

# Instructions

## Environment

Windows 10

IDE:
- Visual Studio 2019 16.6.5 (with Web Development Build Tools)
- Visual Studio Code 1.47.3
	- Extensions:
		- C# 1.22.1
		- C# Extensions 1.3.5
		- Flutter 3.12.2
		- Dart 3.12.2
		- dart-import 0.2.0
		- NuGet Package Manager 1.1.6
- Android Studio 4.0.1


Dependencies:
- SQLite 3.32.3

## Generate database
1. Put the files movies.csv and ratings.csv
2. Run the project CriaBanco by typing dotnet run in the CLI at the path CriaBanco/CriaBanco, it can take around 1 to 5 minutes to finish loading the data into the database

## Run WebAPI
1. Open the API/API.sln project in the Visual Studio 2019 IDE
2. Create a Virtual Environment in the Project Web Settings
3. Replace the databasePath in API/API/Controllers/MoviesController.cs with the path of the database
4. Replace the binding configuration lines in API\.vs\API\config\applicationhost.config at the WebSite used for this application:
```
<binding protocol="http" bindingInformation="*:44335:*" />
<binding protocol="http" bindingInformation="*:44335:localhost" />
<binding protocol="http" bindingInformation="*:44335:hostip" />
```
where hostip is the IP in the network it is connected

5. Run the project with IIS Express (May need admin privileges)
6. The WebAPI can now be used with the client application

## Client Application with Android Emulator
1. Create an Android Emulator (The application was tested on Nexus 6 API 30)
2. Change the URL in http_client_flutter/constants.dart to http://10.0.2.2:44335
3. Run the application with F5

## Client Application with mobile device
1. Change the URL in http_client_flutter/constants.dart to http://hostip:44335 where hostip is the IP where the API is being hosted
2. Ensure that the mobile phone and the server are on the same network
3. Connect the phone and run the application with F5 (It will need to activate debugging mode in the mobile phone)
It was tested on Xiaomi Mi A2 Lite and Motorola Moto G6



# Resources used
- Asp.Net Core: This framework was used to build the WebAPI. I didn't have used it before but as it had support to C# WebAPI programming, it wasn't very difficult to understand and use it.
- Flutter: This framework was used to build the mobile device application, I had some experience with it in Web projects so it was the first option to use.
- SQLite: This database provider was used because of the easiness to use and install so it was good for using in this application


# Challenges and Decisions
1. The biggest challenge on the database migration was that I made the parse manually to ensure the data was correct even if some lines on the dataset didn't follow any pattern, two decisions were essential at this step:
- Creating a table with the genres only which in return made the queries by genre faster as the searchs were made on string properly not on substrings of the genres, the memory cost of this was very low as the concatenation of these genres were stored in the movies table.
- Extracting the year information from the lines and storing it as values for the same reasons.
- The mean ratings of the movies were calculated before migrating to database and this resulted in less and faster inserts.

2. On the API side, the challenge was that I only programmed in C# once with Windows Phone devices, but I program a lot in C++ in my life and had already developed some APIs in Python so I learned fast. The other problem was that I didn't know that IIS Express is only setted for localhost by default so I had to set it manually to work with my application.

3. On the client application, I chose to use Flutter as I had an experience with a previous project that worked in a similar way, this way I could enhance more time on enhancing the interface. It is also worth saying that the language used in Flutter, Dart, is kinda similar to C++.

# Final Considerations
I was very pleased with the opportunity of participating in the challenge as I could improve a lot my skills in web development. I was satisfied with the results and with the low latency although I wish to improve more at wrapping the classes especially when programming in Flutter as the language is very verbose (although very modular) as not doing it could harm the readability of the code.

# Programming Challenge

Congratulations on being selected to participate in our technical test. It consists of a programming challenge and it will address different skills. Read the instructions carefully and we wish you the best of luck.

## Before You Start

Fork this repository and once you have finished your challenge, grant access to the Github user "kavlac". Upload all your deliverables to your forked repository. We will use it to evaluate your test.

## Introduction

We want you to develop a project that makes uses of the [MovieLens](https://grouplens.org/datasets/movielens/) dataset. It consists of three goals and the details on each one of them is given below.

## Preparing the Data

The first goal of this challenge is to obtain and prepare the data you will work with.

In order to do so, you must download a [publicly available dataset](http://files.grouplens.org/datasets/movielens/ml-25m.zip). You can find the details about what data is stored and how it is structured in the [instructions](http://files.grouplens.org/datasets/movielens/ml-25m-README.html).

Then, you are asked to write a program to read the input files for the dataset and create a database out of it. You can choose to use the database in memory, in files, or in a database management system, as long as you process and consume this data in the upcoming parts.

## Making the Data Available

The second goal of this challenge is to make the processed data available for consumption.

To do such, you must implement a REST API and it should provide the following methods:
- List movies by year: given a year, we want to know what movies match the given year;
- List movies by year and genre: given a year and a genre, we want to know what movies match the given year and are of the given genre;
- List top K rated movies: given a number K, we want to know the best K rated movies in descending order.

## Consuming the Data

The third goal of this challenge is to consume the methods of the REST API.

Thus, you are asked to implement a client application that accesses such an API. It must have a graphical interface to interact with users to consume the three methods above. It is up to you how to design the user interface, as long as it is usable.

## Deliverables

You must provide the following artifacts:
- The source-code of the programs that you implemented;
- A set of instructions on how to prepare the environment, build the programs, run each part of the challenge, and how to use your project;
- Comments on what technologies and patterns you used and the reasons to do so, as well as the decisions you made throughout the challenge;
- Any other artifact you find relevant for your overall evaluation.

## Tips

- Make sure your instructions are easy to follow and that each step works as expected;
- Our main environment is Windows, so please make sure that your solution works on it;
- If you want, you can show us how you can set up your project using Docker;
- We suggest you implement the challenge using the following languages (you can use more than one of them if you want): C#, Java, and/or JavaScript;
- Testing is more than welcome;
- Show us everything you know about best practices in Git;
- Think carefully about your code quality, in terms of maintainability, readability, and simplicity;
- Do not overengineer your solution.
