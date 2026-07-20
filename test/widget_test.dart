import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intelligent_patient_mobile_app/app/app.dart';

void main() {
  testWidgets('renders patient app shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PatientFlowApp()));
    await tester.pumpAndSettle();

    expect(find.text('Patient Flow'), findsOneWidget);
    expect(find.text('Healthcare access, made calmer.'), findsOneWidget);
  });
}
