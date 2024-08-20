import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({ super.key });

  @override
  ChangePasswordPageState createState() => ChangePasswordPageState();
}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  final UserAPI _userAPI = UserAPI();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Change Password",
            style: TextStyle(
              color: secondaryColor,
            ),
          )
        ),
        leading: IconButton(
          icon: const Icon(
            Ionicons.arrow_back
          ),
          onPressed: (() {
            Navigator.pop(context);
          }),
        ),
      ),
      body: MySafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            PasswordTextFields(
              controller: _currentPasswordController,
              title: "Current Password",
              masked: true,
            ),
            PasswordTextFields(
              controller: _newPasswordController,
              title: "New Password",
              masked: true,
            ),
            PasswordTextFields(
              controller: _confirmPasswordController,
              title: "Confirm Password",
              masked: true,
            ),
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Change",
                  bgColor: primaryDark,
                  icon: Ionicons.lock_open,
                  callback: (() async {
                    if(_validateForm()) {
                      await _changePassword().then((resp) {
                        if(resp) {
                          Log.success(message: "🔓 Change Password");
                          if (context.mounted) {
                            // update password success, show the message
                            ScaffoldMessenger.of(context).showSnackBar(
                              createSnackBar(
                                message: "Password Change Successfully",
                                icon: const Icon(
                                  Ionicons.checkmark,
                                  color: Colors.green,
                                ),
                                duration: 3,
                              )
                            );
                          }
          
                          // clear the text fields
                          _currentPasswordController.clear();
                          _newPasswordController.clear();
                          _confirmPasswordController.clear();
                        }
                        else {
                          if (context.mounted) {
                            // update password failed
                            ScaffoldMessenger.of(context).showSnackBar(
                              createSnackBar(
                                message: "Unable to Change Password",
                                duration: 3,
                              )
                            );
                          }
                        }
                      }).onError((error, stackTrace) {
                        if (context.mounted) {
                          // update password failed
                          ScaffoldMessenger.of(context).showSnackBar(
                            createSnackBar(
                              message: "Error when Change Password",
                              duration: 3,
                            )
                          );
                        }
                      });
                    }
                  })
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Cancel",
                  bgColor: secondaryDark,
                  icon: Ionicons.close,
                  callback: (() {
                    // return back to the previous screen
                    Navigator.pop(context);
                  })
                ),
                const SizedBox(width: 10,),
              ],
            )
          ],
        ),
      ),
    );
  }

  bool _validateForm() {
    // validate the form, and ensure all is filled correctly
    // first, let's check if all fields is being filled
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if(currentPassword.isNotEmpty && newPassword.isNotEmpty && confirmPassword.isNotEmpty) {
      // all not empty, ensure that all the length is >= 6
      if(currentPassword.length >= 6 && newPassword.length >= 6 && confirmPassword.length >= 6) {
        // all have length at least 6, so now confirm if the new and confirm password is the same or not?
        if(newPassword == confirmPassword) {
          // ensure all 3 is not same password
          if (currentPassword == newPassword) {
            ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Password is the same"));
            return false;
          }
          else {
            // all good!
            return true;
          }
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "New and Confirmed password missmatch"));
          return false;
        }
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Password minimum length is 6"));
        return false;
      }
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Please fill all required fields"));
      return false;
    }
  }

  Future<bool> _changePassword() async {
    bool ret = false;
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;

    // show the loading screen
    LoadingScreen.instance().show(context: context);

    // try to update the password
    await _userAPI.updatePassword(currentPassword, newPassword).then((_) {
      // password is updated, set the return value as true
      ret = true; 
    }).onError((error, stackTrace) {
      // got error
      throw Exception(error.toString());
    }).whenComplete(() {
      // remove the loading screen once finished
      LoadingScreen.instance().hide();
    });

    return ret;
  }
}