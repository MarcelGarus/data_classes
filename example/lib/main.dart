import 'package:data_classes/data_classes.dart';

part 'main.g.dart';

void main() {
  var me = const User(firstName: 'Marcel', lastName: 'Garus');
  var mySister = me.copyWith(firstName: 'Yvonne');
}

@DataClass()
class MutableUser {
  String firstName;
  String lastName;

  @Nullable()
  String photoUrl;
}
