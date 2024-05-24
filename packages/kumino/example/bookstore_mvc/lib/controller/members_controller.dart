import 'dart:async';

import 'package:kumino/kumino.dart';

import '../model/member.dart';
import '../service/member.dart';

@ApiController(prefix: "/api/v1/members")
class MembersController {
  MembersController({
    required this.eventPublisher,
    required this.memberService,
  });

  // TODO: Use special publisher to publish the application event?
  final EventPublisher eventPublisher;

  final MemberService memberService;

  @HttpPut(path: "/")
  FutureOr register(HttpRequest request) async {
    final req = await request.serializeBodyAs<NewMemberRequest>();
    await memberService.checkNewMemberRequest(req);

    await eventPublisher.publishEvent(req);
  }
}
