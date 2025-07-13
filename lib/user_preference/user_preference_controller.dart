import 'package:partymap_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreference {
  Future<bool> saveUser(UserModel userModel) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('token', userModel.token ?? '');
    await sp.setBool('isLogin', userModel.isLogin ?? false);
    return true;
  }

  Future<UserModel> getUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final token = sp.getString('token');
    final isLogin = sp.getBool('isLogin');
    return UserModel(token: token, isLogin: isLogin);
  }

  Future<bool> removeUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.clear();
    return true;
  }
}
