import 'package:kumino/annotations.dart';

import '../model/book.dart';

@Component()
class BookService {
  Future<Book> getBook(String bookId) async {
    return Book()
      ..id = bookId
      ..title = "How the Steel Was Tempered?"
      ..author = "Nikolai Ostrovsky";
  }
}
