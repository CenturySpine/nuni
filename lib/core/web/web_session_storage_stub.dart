final _values = <String, String>{};

String? readSessionValue(String key) => _values[key];

void writeSessionValue(String key, String? value) {
  if (value == null) {
    _values.remove(key);
  } else {
    _values[key] = value;
  }
}
