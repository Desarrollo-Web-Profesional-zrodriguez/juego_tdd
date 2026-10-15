import 'package:flutter_test/flutter_test.dart';
import 'package:momias_guanajuato/main.dart';

void main() {
  testWidgets('MomiasApp carga la pantalla inicial con éxito', (WidgetTester tester) async {
    await tester.pumpWidget(const MomiasApp());
    expect(find.text('Momias de Guanajuato'), findsOneWidget);
    expect(find.textContaining('Vidas: 3'), findsOneWidget);
  });
}
