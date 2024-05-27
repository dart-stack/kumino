import 'dart:async';

import 'package:kumino/annotations.dart';

import '../model/member.dart';
import '../service/review.dart';

@Component()
class NewMemberRequestListener {
  NewMemberRequestListener({
    required this.reviewService,
  });

  final ReviewService reviewService;

  @EventListener(subscribeTo: NewMemberRequest)
  FutureOr handleEvent(NewMemberRequest event) async {
    reviewService.addNewMemberRequest(event);
  }
}
