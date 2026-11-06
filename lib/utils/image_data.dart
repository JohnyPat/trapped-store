import 'dart:convert';
import 'dart:typed_data';

/// Returns the decoded bytes for a `data:image/...;base64,...` URL.
///
/// Returns `null` when [url] is not an inline image or cannot be decoded, so
/// callers can fall back to their normal asset/network handling.
Uint8List? decodeImageDataUrl(String url) {
  if (!url.startsWith('data:image/')) return null;
  final comma = url.indexOf(',');
  if (comma == -1) return null;
  try {
    return base64Decode(url.substring(comma + 1));
  } on FormatException {
    return null;
  }
}
