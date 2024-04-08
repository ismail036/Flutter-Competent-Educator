  import 'package:sqflite/sqflite.dart';

import 'book.dart';

  class DbHelper {

    String bookDatabaseName = "bookDatabase3";
    String bookTableName = "book3";
    int _version = 1;
    late Database database;


    Future<void> open() async {
      database = await openDatabase(
          bookDatabaseName, version: _version, onCreate: (db, version) {
        db.execute(
            "CREATE TABLE $bookTableName (id INTEGER PRIMARY KEY AUTOINCREMENT,imgLink TEXT,name TEXT,desc TEXT,isFavorite BOOLEAN,detailPageLink TEXT)"
        );
      });
    }

    Future<int> insertBook(Book book) async {
      return await database.insert(bookTableName, book.toMap());
    }


    Future<List<Book>> getBooks() async {
      List<Map<String, dynamic>> booksMapList = await database.query(
          bookTableName);
      List<Book> booksList = [];
      bool isFavorite = false;
      for (var bookMap in booksMapList) {
        if (bookMap['isFavorite'] == 1) {
          isFavorite = true;
        }
        Book book = Book(
          bookMap['imgLink'],
          bookMap['name'],
          bookMap['desc'],
          isFavorite,
          bookMap['detailPageLink'],
        );
        booksList.add(book);
      }
      return booksList;
    }


    Future<void> deleteBookByDetailPageLink(String detailPageLink) async {
      await database.execute(
        'DELETE FROM $bookTableName WHERE detailPageLink = ?',
        [detailPageLink],
      );
    }
  }