import 'package:kumino/kumino.dart';

import '../service/book.dart';
import '../interceptor/auth.dart';
import '../interceptor/log.dart';

@ApiController(
  prefix: '/api/v1/books',
  interceptors: [TraceFootprint]
)
class BooksController {
  BooksController({
    required this.bookService,
  });

  final BookService bookService;

  @HttpGet(path: "/")
  Future getBook(HttpRequest request) async {
    final bookId = request.query.value("bookId");
    return bookService.getBook(bookId!);
  }

  @HttpPost(path: "/", interceptors: [RequireLogin])
  Future updateBook(HttpRequest request) async {

  }

}