import 'package:kumino/model.dart';

@Validatable()
class NewMemberRequest {
  late String reviewId;

  late String username;

  @OneOf(group: "notificationChannel")
  late String? phoneNumberForNotification;

  @OneOf(group: "notificationChannel")
  late String? emailAddressForNotification;
}



class Member {
}