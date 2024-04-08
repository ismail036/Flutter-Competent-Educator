import 'package:flutter/material.dart';

import 'book.dart';
import 'dbHelper.dart';
import 'package:competenteducator/favoritePage.dart';
import 'package:competenteducator/searchPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

import 'book.dart';
import 'bookDetail.dart';
import 'dbHelper.dart';

class SearchPageBody extends StatefulWidget {
  const SearchPageBody({super.key});

  @override
  State<SearchPageBody> createState() => _SearchPageBodyState();
}

class _SearchPageBodyState extends State<SearchPageBody> {
  TextEditingController _controller = TextEditingController();
  String _searchText = '';

  List<Book> books = [];
  List<String> bookLinkList = [];
  List<String> catList = [];
  List<String> catLink = [];
  List<Book> bookList = [];
  String filter = "";
  int selectedIndex = -1;


  void getBookData(String link) async {
    print(link);
    bookList.clear();
    await getBookDb();
    final Uri url = Uri.parse('https://directory.doabooks.org/discover?query=${link}');
    final response = await http.get(url);
    print(response.statusCode);
    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      print(document);
      final elements = document.querySelectorAll('.row.ds-artifact-item');
      for (var element in elements) {
        String bookLink =
        ("https://directory.doabooks.org/${element.querySelector("img")?.attributes['src'].toString().split("?")[0]}");
        String title = (element.querySelector("h4")!.text.toString());
        String abstract = (element.querySelector(".abstract")!.text.toString());
        String detailPageLink =
        ("https://directory.doabooks.org/${element.querySelector("a")?.attributes['href'].toString()}");
        if(bookLinkList.contains(detailPageLink)){
          Book book = Book(bookLink, title, abstract, true, detailPageLink);
          print(book.name);
          setState(() {
            bookList.add(book);
          });
        }else{
          Book book = Book(bookLink, title, abstract, false, detailPageLink);
          print(book.name);
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
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                margin: EdgeInsets.all(8), // Add margin around the container
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10), // Set border radius for rounded corners
                ),
                child: Row(
                  children: [
                    SizedBox(width: 8,),
                    Icon(Icons.search),
                    SizedBox(width: 8), // Add some space between the icon and text field
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) {
                          setState(() {
                            _searchText = value;
                          });
                        },
                        onSubmitted: (value) {
                          setState(() {
                            bookList.clear();
                          });
                          print('Submitted: $value'); // Handle the submitted text here
                          getBookData(value.replaceAll(" ", "+") + "&submit=" );
                        },
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        
        
            for (int i = 0; i < bookList.length; i++)
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



