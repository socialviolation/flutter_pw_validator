/// Strings hold constant strings used across the package
class Strings {
  Strings._();

  static const String AT_LEAST = "At least - character";
  static const String UPPERCASE_LETTER = "- Uppercase letter";
  static const String NUMERIC_CHARACTER = "- Numeric character";
  static const String SPECIAL_CHARACTER = "- Special character";

  static String min(int n) {
    return _pluralize(n, AT_LEAST);
  }

  static String uppercase(int n) {
    return _pluralize(n, UPPERCASE_LETTER);
  }

  static String numeric(int n) {
    return _pluralize(n, NUMERIC_CHARACTER);
  }

  static String special(int n) {
    return _pluralize(n, SPECIAL_CHARACTER);
  }

  static String _pluralize(int n, String msg) {
    return n > 1 ? "${msg}s" : msg;
  }
}
