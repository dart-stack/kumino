import 'package:kumino/kumino.dart';

import '../service/member.dart';

@ApiController(
  prefix: "/api/v1",
)
class ReviewController {
  ReviewController({
    required this.memberService,
  });

  final MemberService memberService;

  @HttpPut(path: "/new-member/reviews/{reviewId}/approved")
  Future approveNewMember(HttpRequest request) async {
    final reviewId = request.params.value<String>("reviewId");
    await memberService.approveNewMember(reviewId);
  }

  @HttpPut(path: "/new-member/reviews/{reviewId}/rejected")
  Future rejectNewMember(HttpRequest request) async {
    final reviewId = request.params.value<String>("reviewId");
    await memberService.rejectNewMember(reviewId);
  }
}
