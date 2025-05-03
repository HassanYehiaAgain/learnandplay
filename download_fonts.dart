import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('Downloading font files...');
  
  // Font URLs
  final fontUrls = {
    'PressStart2P-Regular.ttf': 'https://fonts.gstatic.com/s/pressstart2p/v15/e3t4euO8T-267oIAQAu6jDQyK3nVivM.ttf',
    'PixelifySans-Regular.ttf': 'https://fonts.gstatic.com/s/pixelifysans/v2/CHy2V-3HFUT7adnAcRcgLTnN7egYCQ.ttf',
    'PixelifySans-Bold.ttf': 'https://fonts.gstatic.com/s/pixelifysans/v2/CHy2V-3HFUT7adnAcRcgLTnN7QgaCQ.ttf',
    'Inter-Regular.ttf': 'https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfMZg.ttf',
    'Inter-Bold.ttf': 'https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuFuYMZg.ttf',
  };

  // Create fonts directory
  final fontsDir = Directory('assets/fonts');
  if (!await fontsDir.exists()) {
    await fontsDir.create(recursive: true);
  }

  // Download each font
  for (final entry in fontUrls.entries) {
    final fontName = entry.key;
    final fontUrl = entry.value;
    final fontFile = File('assets/fonts/$fontName');
    
    print('Downloading $fontName...');
    
    try {
      final response = await http.get(Uri.parse(fontUrl));
      if (response.statusCode == 200) {
        await fontFile.writeAsBytes(response.bodyBytes);
        print('Downloaded $fontName successfully');
      } else {
        print('Failed to download $fontName: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading $fontName: $e');
    }
  }
  
  print('Font download completed!');
} 