import 'package:data_classes/data_classes.dart';

part 'main.g.dart';

// ignore_for_file: unused_element

void main() {
  var me = const User(firstName: 'Marcel', lastName: 'Garus');
  var mySister = me.copyWith(firstName: 'Yvonne');
}

@DataClass()
class $User {
  String firstName;
  String lastName;

  @Nullable()
  String photoUrl;
}
