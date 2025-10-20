// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Importe o widget principal do seu aplicativo
import 'package:aula04/app_widget.dart';

void main() {
  testWidgets('Giphy App smoke test', (WidgetTester tester) async {
    // 1. Constrói o seu app, não o MyApp de exemplo.
    await tester.pumpWidget(const GiphyRandomApp());

    // 2. Verifica se o título do seu app está na tela.
    expect(find.text('Buscador de GIF 2.0'), findsOneWidget);

    // 3. Verifica se o botão "Novo GIF" existe.
    expect(find.text('Novo GIF'), findsOneWidget);
    
    // 4. Verifica se o ícone de configurações está presente.
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}