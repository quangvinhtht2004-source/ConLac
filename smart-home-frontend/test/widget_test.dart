import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home_frontend/main.dart';

void main() {
  testWidgets('SmartHome app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartHomeApp());

    // Verify login screen loads
    expect(find.text('SmartHome'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsWidgets);
  });
}
