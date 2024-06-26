import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:shared_preferences/shared_preferences.dart';
import 'book.dart';
import 'bookDetail.dart';
import 'package:competenteducator/favoritePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

import 'book.dart';
import 'bookDetail.dart';
import 'dbHelper.dart';



class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FavoriteBody()
    );
  }
}


class FavoriteBody extends StatefulWidget {
  const FavoriteBody({super.key});

  @override
  State<FavoriteBody> createState() => _FavoriteBodyState();
}

class _FavoriteBodyState extends State<FavoriteBody> {
  List<Book> books = [];
  List<String> bookLinkList = [];
  List<String> catList = [];
  List<String> catLink = [];
  List<Book> bookList = [];
  String filter = "";
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    getData();
    getBookData("browse?type=classification_text&value=Accident+and+emergency+medicine");
  }

  void getData() async {
    await getBookDb();
    final Uri url = Uri.parse(
        'https://directory.doabooks.org/browse?rpp=1000&sort_by=-1&type=classification_text&etal=-1&starts_with=A&order=ASC');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print("l");
      final document = parser.parse(response.body);
      final elements = document.querySelectorAll('.ds-table-cell.odd');
      for (var element in elements) {
        setState(() {
          catList.add(element.text);
        });
        final anchor =
        element.querySelector('a'); // Her bir elementin içindeki <a> etiketini seçiyoruz
        if (anchor != null) {
          setState(() {
            print(catLink);
            catLink.add(anchor.attributes['href'].toString());
          });
        }
      }
    } else {
      print('Failed to load page: ${response.statusCode}');
    }
  }



  void getBookData(String link) async {
    print(link);
    bookList.clear();
    await getBookDb();
    final Uri url = Uri.parse('https://directory.doabooks.org/${link}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      print(document);
      final elements = document.querySelectorAll('.ds-artifact-item.odd');
      for (var element in elements) {
        String bookLink =
        ("https://directory.doabooks.org/${element.querySelector("img")?.attributes['src'].toString().split("?")[0]}");
        String title = (element.querySelector(".artifact-title")!.text.toString());
        String abstract = (element.querySelector(".artifact-abstract")!.text.toString());
        String detailPageLink =
        ("https://directory.doabooks.org/${element.querySelector("a")?.attributes['href'].toString()}");
        if(bookLinkList.contains(detailPageLink)){
          Book book = Book(bookLink, title, abstract, true, detailPageLink);
          setState(() {
            bookList.add(book);
          });
        }else{
          Book book = Book(bookLink, title, abstract, false, detailPageLink);
          setState(() {
            bookList.add(book);
          });
        }

      }
    } else {
      print('Failed to load page: ${response.statusCode}');
    }
  }


  Future<void> getBookDb() async {
    DbHelper db = DbHelper();
    await db.open();
    books = await db.getBooks();
    for (var book in books) {
      bookLinkList.add(book.detailPageLink);
    }
  }

  Future<void> addBookDb(int i) async{
    DbHelper db = DbHelper();
    await db.open();

    db.insertBook(bookList[i]);

    getBookDb();


    print(bookList[i].detailPageLink);
  }

  Future<void> deleteBook(String bookLink) async{
    DbHelper db = DbHelper();
    await db.open();
    db.deleteBookByDetailPageLink(bookLink);
    bookLinkList.clear();
    getBookDb();
  }

  @override
  Widget build(BuildContext context) {
    print(catList.length);
    getBookDb();
    return Container(
      color: Colors.white70,
      padding: EdgeInsets.all(7),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(7), // Adjust the value as needed
              ),
              padding: EdgeInsets.all(6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Image(
                      image: AssetImage('assets/filterIcon.png'),
                      width: 26,
                      height: 26,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    for (int i = 3; i < catList.length; i++)
                      Container(
                        padding: EdgeInsets.all(4),
                        margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: selectedIndex == i ? Colors.green : Colors.grey, // Set the color conditionally
                          borderRadius: BorderRadius.circular(7), // Adjust the value as needed
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              filter = catList[i].split('[')[0];
                              getBookData(catLink[i]);
                              // Update the index of the selected container
                              selectedIndex = i;
                            });
                          },
                          child: Text(catList[i].split('[')[0]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.all(14),
              child: Text(
                filter,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            for (int i = 0; i < bookList.length; i++)
              if(bookLinkList.contains(bookList[i].detailPageLink ))
              GestureDetector(
                onTap: () {
                  print(bookList[i].detailPageLink);
                  BookDetail.bookLink = bookList[i].detailPageLink;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookDetail()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3), // Gölge rengi ve opaklığı
                        spreadRadius: 2, // Yayılma yarıçapı
                        blurRadius: 3, // Bulanıklık yarıçapı
                        offset: Offset(0, 2), // Gölgenin konumu
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          bookList[i].imgLink,
                          width: 170,
                          height: 260,
                          fit: BoxFit.fill,
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 170,
                            child: Text(
                              bookList[i].name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: 180,
                            child: Text(
                              bookList[i].desc.length <= 180 ? bookList[i].desc : '${bookList[i].desc.substring(0, 180)}...',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: 180,
                            alignment: Alignment.center,
                            child: IconButton(
                              icon: Icon(
                                bookList[i].isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: bookList[i].isFavorite ? Colors.green : null, // Beğenildiğinde rengi yeşile dönüştürür.
                              ),
                              onPressed: () {
                                setState(()  {
                                  if(bookList[i].isFavorite == false){
                                    addBookDb(i);
                                  }else{
                                    deleteBook(bookList[i].detailPageLink);
                                  }
                                  bookList[i].isFavorite = !bookList[i].isFavorite; // İkon durumunu tersine çevirir.
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}