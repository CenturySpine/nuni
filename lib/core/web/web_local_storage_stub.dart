final _values = <String, String>{};

String? readLocalValue(String key) => _values[key];

void writeLocalValue(String key, String? value) {
  if (value == null) {
    _values.remove(key);
  } else {
    _values[key] = value;
  }
}
