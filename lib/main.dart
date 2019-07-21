import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: ListModel(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}

enum SortType { thumbsUp, thumbsDown }

class ListModel extends Model {
  String apiKey = "c2b70ca814msha095de06eb2970ap1745bfjsncc9a52f177ad";

  List<Result> results = List();

  SortType sortType;

  bool isLoading = false;

  initData() {
    sortType = SortType.thumbsUp;
    results.add(Result(name: "Arham", definition: "stuff"));
    notifyListeners();
  }

  _makeGetRequest(String query) async {
    isLoading = true;
    results.clear();
    notifyListeners();

    String url =
        'https://mashape-community-urban-dictionary.p.rapidapi.com/define?term=$query';
    Response response = await get(
      url,
      headers: {"X-RapidAPI-Key": apiKey},
    );

    int statusCode = response.statusCode; // todo handle errors

    Map<String, String> headers = response.headers;

    //String contentType = headers['content-type'];
    String json = response.body;

    parseJson(json);
  }

  void parseJson(String jsonData) {
    var parsedJson = json.decode(jsonData);

    var list = parsedJson["list"] as List;

    for (var r in list) {
      var result = Result.fromJson(r);
      results.add(result);
    }

    isLoading = false;
    notifyListeners();
  }

  flipSort() {
    if (sortType == SortType.thumbsUp) {
      sortType = SortType.thumbsDown;
    } else {
      sortType = SortType.thumbsUp;
    }
    notifyListeners();
  }
}

class Result {
  String name;
  String definition;
  int thumbsUp;
  int thumbsDown;

  Result({this.name, this.definition, this.thumbsUp, this.thumbsDown});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
        name: json["word"],
        definition: json["definition"],
        thumbsUp: json["thumbs_up"],
        thumbsDown: json["thumbs_down"]);
  }
}

class DictionaryCards extends StatelessWidget {
  Result result;

  DictionaryCards(this.result);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Text(
            result.name,
            style: TextStyle(
              fontSize: 25,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              result.definition,
              style: TextStyle(fontSize: 15),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.thumb_up),
                  Text(result.thumbsUp.toString()),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.thumb_down),
                  Text(result.thumbsDown.toString()),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    ScopedModel.of<ListModel>(context).initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(
            top: padding.height * 0.2,
            left: padding.width * 0.05,
            right: padding.width * 0.05),
        child: Column(
          children: <Widget>[
            Align(
              child: Text(
                "Urban Dictionary",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
              alignment: Alignment.topLeft,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: TextField(
                onSubmitted: (value) {
                  ScopedModel.of<ListModel>(context)._makeGetRequest(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search here",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)))),
              ),
            ),
            ScopedModelDescendant<ListModel>(
              builder: (context, child, model) => Row(
                children: <Widget>[
                  Expanded(
                    child: Container(),
                  ),
                  IconButton(
                      icon: Icon(Icons.thumb_up,
                          color: (model.sortType == SortType.thumbsUp)
                              ? Colors.red
                              : Colors.grey),
                      onPressed: () => model.flipSort()),
                  IconButton(
                      icon: Icon(Icons.thumb_down,
                          color: (model.sortType == SortType.thumbsDown)
                              ? Colors.red
                              : Colors.grey),
                      onPressed: () => model.flipSort()),
                ],
              ),
            ),
            ScopedModelDescendant<ListModel>(
              builder: (context, child, model) => (model.isLoading)
                  ? CircularProgressIndicator()
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: model.results.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return DictionaryCards(model.results[index]);
                      }),
            )
          ],
        ),
      ),
    );
  }
}
