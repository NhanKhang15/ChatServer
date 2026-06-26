// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation: create an anchor element with download attribute
/// to trigger native browser file download.
Future<void> downloadFile(String url, String? fileName) async {
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName ?? 'download')
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
