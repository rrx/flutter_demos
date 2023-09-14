import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'terminal.dart';
import 'package:flutter/services.dart';
import 'platform_menu.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

void main() async {
  // initialize acrylic
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  if (defaultTargetPlatform == TargetPlatform.windows) {
    await Window.hideWindowControls();
    await Window.setEffect(
      effect: WindowEffect.mica,
      dark: true,
    );
  }

  // run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: AppPlatformMenu(
          child: KeyboardWrapper(child: TerminalWidgetWithRestart())),
    );
  }
}

class KeyboardWrapper extends StatefulWidget {
  const KeyboardWrapper({super.key, required this.child});
  final Widget child;

  @override
  State<KeyboardWrapper> createState() => _KeyboardWrapperState();
}

class _KeyboardWrapperState extends State<KeyboardWrapper> {
  TestController controller = TestController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
            const TestIntent(),
      },
      child: Actions(
          dispatcher: LoggingActionDispatcher(),
          actions: <Type, Action<Intent>>{
            TestIntent: TestAction(controller),
          },
          child: widget.child),
    );
  }
}

/// A ShortcutManager that logs all keys that it handles.
class LoggingShortcutManager extends ShortcutManager {
  @override
  KeyEventResult handleKeypress(BuildContext context, RawKeyEvent event) {
    final KeyEventResult result = super.handleKeypress(context, event);
    print("shortcut");
    if (result == KeyEventResult.handled) {
      print('Handled shortcut $event in $context');
    }
    return result;
  }
}

/// An ActionDispatcher that logs all the actions that it invokes.
class LoggingActionDispatcher extends ActionDispatcher {
  @override
  Object? invokeAction(
    covariant Action<Intent> action,
    covariant Intent intent, [
    BuildContext? context,
  ]) {
    print('Action invoked: $action($intent) from $context');
    super.invokeAction(action, intent, context);

    return null;
  }
}

class TestIntent extends Intent {
  const TestIntent();
}

class TestAction extends Action<TestIntent> {
  TestAction(this.controller);

  final TestController controller;

  @override
  Object? invoke(covariant TestIntent intent) {
    print("test intent");
    controller.clear();

    return null;
  }
}

class TestController {
  TestController();
  void clear() {}
}
