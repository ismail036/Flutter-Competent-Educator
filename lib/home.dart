import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin: EdgeInsets.only(top: 15),
          child: Center(
            child: Image(
              image: AssetImage('assets/logo.png'),
              width: 110,// Replace with your image path
            ),
          ),
        )
      ),
      body: HomeBody(),
    );
  }
}


class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {


  void getData() async {
    final Uri url = Uri.parse('https://directory.doabooks.org/browse?rpp=1000&sort_by=-1&type=classification_text&etal=-1&starts_with=B&order=ASC');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print("l");
      final document = parser.parse(response.body);
      final elements = document.querySelectorAll('.ds-table-cell.odd');
      for (var element in elements) {
        print(element.text);
      }
    } else {
      print('Failed to load page: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return const Placeholder();
  }
}
