/// Alphabetical order for names shown to people: case and accents are
/// ignored ("émile" sorts with "Eric", not after "Zoé"), ties broken by the
/// raw strings so the order stays stable.
int compareNames(String a, String b) {
  final folded = foldForSort(a).compareTo(foldForSort(b));
  return folded != 0 ? folded : a.compareTo(b);
}

/// [text] lower-cased, with the Latin letters' accents removed and the
/// French ligatures spelled out.
String foldForSort(String text) {
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_folds[char] ?? char);
  }
  return buffer.toString();
}

const _folds = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', //
  'æ': 'ae', 'ç': 'c', //
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', //
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', //
  'ñ': 'n', //
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'œ': 'oe', //
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', //
  'ý': 'y', 'ÿ': 'y', //
};
