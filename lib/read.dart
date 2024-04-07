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


class Read extends StatelessWidget {
  const Read({super.key});

  static String filePath = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReadBody(),
    );
  }
}



class ReadBody extends StatefulWidget {
  const ReadBody({super.key});

  @override
  State<ReadBody> createState() => _ReadBodyState();
}

class _ReadBodyState extends State<ReadBody> {
  int currentPage = 0;
  int totalPages = 0;
  PDFViewController? pdfController;

  @override
  Widget build(BuildContext context) {
    return Container(
      child:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),

                Container(
                  margin: EdgeInsets.only(left: 17),
                  child: Image(
                    image: AssetImage('assets/logo.png'),
                    width: 110,
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      Text("Pages"),
                      Text(
                        '${currentPage + 1}/${totalPages}',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ],
                  ),
                )

              ],
            ),




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
                onRender: (total) {
                  setState(() {
                    totalPages = total!;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                    color: Colors.green,
                    size: 35,
                  ),
                  onPressed: () {
                    if (currentPage > 0 && pdfController != null) {
                      pdfController!.setPage(currentPage - 1);
                    }
                  },
                ),

                IconButton(
                  icon: Icon(Icons.arrow_forward,
                    color: Colors.green,
                    size: 35,
                  ),
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
    );
  }
}