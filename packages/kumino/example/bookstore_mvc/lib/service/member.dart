import 'package:kumino/kumino.dart';

import '../model/member.dart';

class MemberService {
  MemberService({
    required this.validator,
  });

  final Validator validator;

  Future checkUsernameIsAvailable(String username) {
    throw UnimplementedError();
  }

  Future checkNewMemberRequest(NewMemberRequest request) async {
    await checkUsernameIsAvailable(request.username);
  }

  Future approveNewMember(String reviewId) async {}

  Future rejectNewMember(String reviewId) async {}
}
