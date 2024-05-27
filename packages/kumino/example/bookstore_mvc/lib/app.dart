import 'package:kumino/kumino.dart';
import 'package:kumino/annotations.dart';

import 'controller/books_controller.dart';
import 'controller/members_controller.dart';
import 'controller/review_controller.dart';
import 'listener/new_member_request_listener.dart';
import 'service/book.dart';
import 'service/member.dart';
import 'service/review.dart';

@Controllers([
  BooksController,
  MembersController,
  ReviewController,
])
@EventListeners([
  NewMemberRequestListener,
])
@Components(
  imports: [
    BookService,
    MemberService,
    ReviewService,
  ],
)
class App {}
