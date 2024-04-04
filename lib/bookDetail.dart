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


  Book book = Book("", "", "desc", false, "");
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

      setState(() {
        book = Book(bookLink, title, abstract, false, "");
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
    final pdfUrl = 'https://library.oapen.org/bitstream/handle/20.500.12657/40057/9781138422575.pdf';

    // Send a GET request to the URL
    final response = await http.get(Uri.parse(pdfUrl));

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      // Get the directory for the app's documents
      final directory = await getApplicationDocumentsDirectory();

      // Define the file path where the PDF will be saved
      final filePath = '${directory.path}/pspdfkit_flutter_quickstart_guide.pdf';

      // Write the PDF content to a file
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      print('PDF downloaded successfully to $filePath');
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
                        onPressed: () {
                          downloadPdf();
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


                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.8, // Adjust height as needed
                              child: PDFView(
                                filePath: "/data/user/0/com.example.competenteducator/app_flutter/pspdfkit_flutter_quickstart_guide.pdf",
                                enableSwipe: true,
                                swipeHorizontal: true,
                                autoSpacing: false,
                                pageSnap: true,
                                defaultPage: currentPage,
                                fitPolicy: FitPolicy.WIDTH,
                                onPageChanged: (page, total) {
                                  setState(() {
                                    currentPage = page!;
                                  });
                                },
                                onViewCreated: (PDFViewController vc) {
                                  setState(() {
                                    pdfController = vc;
                                  });
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.navigate_before),
                                  onPressed: () {
                                    if (currentPage > 0 && pdfController != null) {
                                      pdfController!.setPage(currentPage - 1);
                                    }
                                  },
                                ),
                                Text(
                                  '${currentPage + 1}',
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                IconButton(
                                  icon: Icon(Icons.navigate_next),
                                  onPressed: () {
                                    if (pdfController != null) {
                                      pdfController!.getPageCount().then((count) {
                                        if (currentPage < count! - 1) {
                                          pdfController!.setPage(currentPage + 1);
                                        }
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),




                    ],
                  ),
          ),
    );
  }
}

