// ignore: camel_case_extensions
// ignore_for_file: unnecessary_null_comparison, camel_case_extensions, duplicate_ignore

extension extString on String {
  bool get isValidEmail {
    final emailRegExp =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegExp.hasMatch(this);
  }

  bool get isValidName {
    final nameRegExp = RegExp(r"^\s*([A-Za-z]+ ?)+\.?\s*$");
    return nameRegExp.hasMatch(this);
  }

  bool get isValidPassword {
    final passwordRegExp =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*~]).{8,}$');
    return passwordRegExp.hasMatch(this);
  }

  bool get isValidPhone {
    final phoneRegExp = RegExp(r"^\d{10}$");
    return phoneRegExp.hasMatch(this);
  }
}

int APPID = 1854289249;
String APPSIGN =
    "52f1161e2759186fa7a211df68c71e9fe38af061ceb0fc0dc85e8d50610e8dbb";
