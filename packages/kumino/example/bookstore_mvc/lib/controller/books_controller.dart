import 'dart:io';

import 'package:kumino/kumino.dart';
import 'package:kumino/annotations.dart';

import '../service/book.dart';
import '../interceptor/auth.dart';
import '../interceptor/log.dart';

@ApiController(
  prefix: '/api/v1/books',
  interceptors: [TraceFootprint],
)
class BooksController {
  BooksController({
    required this.bookService,
  });

  final BookService bookService;

  @GetRoute(path: "/")
  Future getBook(HttpRequest request) async {
    final bookId = request.query.value("bookId");
    return bookService.getBook(bookId!);
  }

  @PostRoute(
    path: "/",
    interceptors: [RequireLogin],
  )
  Future updateBook(HttpRequest request) async {}
}
