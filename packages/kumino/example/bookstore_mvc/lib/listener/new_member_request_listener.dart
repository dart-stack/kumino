import 'dart:async';

import 'package:kumino/kumino.dart';

import '../model/member.dart';
import '../service/review.dart';

@EventListener()
class NewMemberRequestListener {
  NewMemberRequestListener({
    required this.reviewService,
  });

  final ReviewService reviewService;

  FutureOr handleEvent(EventContext context, NewMemberRequest event) async {
    reviewService.addNewMemberRequest(event);
  }
}
