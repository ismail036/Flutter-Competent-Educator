import 'package:competenteducator/read.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'book.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_pdfview/flutter_pdfview.dart';

class BookDetail extends StatelessWidget {
  const BookDetail({super.key});

  static String bookLink = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: Container(
          margin: EdgeInsets.only(top: 13, left: 10),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.green,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Container(
          margin: EdgeInsets.only(top: 22, left: 85),
          child: Image(
            image: AssetImage('assets/logo.png'),
            width: 110,
          ),
        ),
      ),
      body: BookDetailBody(),
    );
  }
}

class BookDetailBody extends StatefulWidget {
  const BookDetailBody({super.key});

  @override
  State<BookDetailBody> createState() => _BookDetailBodyState();
}

class _BookDetailBodyState extends State<BookDetailBody> {
  int currentPage = 0;
  PDFViewController? pdfController;


  Book book = Book("", "", "desc", false, ""  );
  bool isLoading = true; // Track loading state

  void getBookData(String link) async {
    setState(() {
      isLoading = true; // Set loading state to true when fetching data starts
    });
    print(link);
    final Uri url = Uri.parse('${link}');
    final response = await http.get(url);
    print(url);
    print(response);
    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      print(document);

      String bookLink =
      ("https://directory.doabooks.org/${document.querySelector(".img-thumbnail")?.attributes['src'].toString().split("?")[0]}");
      String title =
      (document.querySelector(".page-header.first-page-header")!.text.toString());
      String abstract =
      (document.querySelector(".simple-item-view-description.item-page-field-wrapper.table")!.text.toString());

      String pdfLink = "";
      var aElements = document.querySelectorAll('a[href]');

      // Iterate over the <a> elements
      for (var element in aElements) {
        // Get the href attribute of the <a> element
        String? href = element.attributes['href'];

        // Check if href is not null and ends with ".pdf"
        if (href != null && href.endsWith('.pdf')) {
          // Print the link if it ends with ".pdf"
          print("PDF Link: $href");

          pdfLink = href;
        }
      }

      setState(() {
        book = Book(bookLink, title, abstract, false, pdfLink);
        isLoading = false; // Set loading state to false when data fetching is complete
      });
    } else {
      print('Failed to load page: ${response.statusCode}');
      setState(() {
        isLoading = false; // Set loading state to false if fetching fails
      });
    }
  }

  Future<void> downloadPdf() async {
    // The URL of the PDF you want to download.
    final pdfUrl = book.detailPageLink;

    print(pdfUrl);

    final response = await http.get(Uri.parse(pdfUrl));

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();

      // Define the file path where the PDF will be saved
      final filePath = '${directory.path}/pspdfkit_flutter_quickstart_guide.pdf';

      // Write the PDF content to a file
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      print('PDF downloaded successfully to $filePath');



      Read.filePath = filePath;
    } else {
      // Print an error message if the request fails
      print('Failed to download PDF: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    getBookData(BookDetail.bookLink);
  }

  @override
  Widget build(BuildContext context) {
    print(book?.name);
    print(BookDetail.bookLink);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      child: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while isLoading is true
          : SingleChildScrollView(
            child: Column(
                    children: [
                      SizedBox(height: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    book!.imgLink,
                    width: 200,
                    height: 290,
                    fit: BoxFit.fill,
                  ),
                ),
                Column(
            
                  children: [
                    Container(
                      width: 160,
                      height: 40,
                      child: TextButton(
                        onPressed: () async {

                          if(book.detailPageLink != ""){
                          showDialog(
                          context: context,
                          builder: (BuildContext context) {
                          return AlertDialog(
                          content: Row(
                          children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Text("Loading..."),
                          ],
                          ),
                          );
                          },
                          );

                          await downloadPdf().then((_) {
                          Navigator.pop(context); // downloadPdf tamamlandığında AlertDialog'u kapat
                          });


                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Read()),

                          );

                          }else{
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('PDF Not Found'),
                                  content: Text('The requested PDF file was not found.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        // Close the dialog
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }


                          },
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.green),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        child: Text(
                          'Read',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
            
                    SizedBox(height: 10,),
            
                    Container(
                      width: 160,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          // Düğmeye tıklandığında yapılacak işlemler
                        },
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Colors.green),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Favorite',
                              style: TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            SizedBox(width: 10,),
                            Icon(Icons.favorite,
                              color: Colors.white,
                            ), // Heart (kalp) icon
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20,),
            Text(
              book!.name.replaceAll("\n", "").trimLeft(),
              textAlign: TextAlign.start,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
            Text(book!.desc.toString().replaceAll("Abstract\n", "")),







                    ],
                  ),
          ),
    );
  }
}

