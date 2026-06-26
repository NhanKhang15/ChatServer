import 'package:url_launcher/url_launcher.dart';

/// Mobile/desktop implementation: open URL in external browser to download.
Future<void> downloadFile(String url, String? fileName) async {
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
