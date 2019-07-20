import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

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

class ListModel extends Model{

  String apiKey;

  List<Result> results = List();

  initData(){
    results.add(Result("Arham", "Baddest Bitch of them all"));
  }



}

class Result {
  String name;
  String definition;

  Result(this.name, this.definition);
}

class DictionaryCards extends StatelessWidget{
  Result result;

  DictionaryCards(this.result);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Text(result.name, style: TextStyle(fontSize: 25,),),
          Text(result.definition, style: TextStyle(fontSize: 15),),
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
        padding:
        EdgeInsets.only(top: padding.height * 0.2, left: padding.width * 0.05, right: padding.width * 0.05),
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
                onChanged: (value) {},
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search here",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.all(Radius.circular(5.0)))),
              ),
            ),

            Row(
              children: <Widget>[
                IconButton(icon: Icon(Icons.thumb_up), onPressed: null),
                IconButton(icon: Icon(Icons.thumb_down), onPressed: null),
              ],
            ),

            ScopedModelDescendant<ListModel>(
              builder: (context, child, model) => ListView.builder(shrinkWrap: true , itemCount: model.results.length,itemBuilder: (BuildContext ctxt, int index) {
                return DictionaryCards(model.results[index]);
              }),
            )

          ],
        ),
      ),
    );
  }
}
