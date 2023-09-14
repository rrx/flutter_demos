import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';

bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

class TestInputHandler implements TerminalInputHandler {
  const TestInputHandler();

  @override
  String? call(TerminalKeyboardEvent event) {
    print("event: ${event.ctrl} ${event.key} ${event.state}");
    return null;
  }
}

const testInputHandler = CascadeInputHandler([
  TestInputHandler(),
  KeytabInputHandler(),
  CtrlInputHandler(),
  AltInputHandler(),
  //TestInputHandler(),
]);

class TerminalWidgetWithRestart extends StatefulWidget {
  const TerminalWidgetWithRestart({Key? key}) : super(key: key);

  @override
  State<TerminalWidgetWithRestart> createState() =>
      _TerminalWidgetWithRestartState();
}

class _TerminalWidgetWithRestartState extends State<TerminalWidgetWithRestart> {
  @override
  Widget build(BuildContext context) {
    return const TerminalWidget();
  }
}

class TerminalWidget extends StatefulWidget {
  const TerminalWidget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TerminalWidgetState createState() => _TerminalWidgetState();
}

class _TerminalWidgetState extends State<TerminalWidget> {
  int value = 0;

  late Pty pty;
  late Terminal terminal;
  late TerminalController terminalController;

  @override
  void initState() {
    super.initState();
    startTerminal();
  }

  void startTerminal() {
    terminal = Terminal(
      maxLines: 10000,
      inputHandler: testInputHandler,
    );

    terminalController = TerminalController();

    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) _startPty();
      },
    );
  }

  @override
  void dispose() {}

  void _startPty() {
    pty = Pty.start(
      shell,
      columns: terminal.viewWidth,
      rows: terminal.viewHeight,
    );

    pty.output
        .cast<List<int>>()
        .transform(const Utf8Decoder())
        .listen(terminal.write);

    pty.exitCode.then((code) {
      terminal.write('the process exited with exit code $code');
      setState(() {
        startTerminal();
      });
    });

    terminal.onOutput = (data) {
      pty.write(const Utf8Encoder().convert(data));
    };

    terminal.onResize = (w, h, pw, ph) {
      pty.resize(h, w);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: TerminalView(
          shortcuts: myShortcuts,
          terminal,
          controller: terminalController,
          autofocus: true,
          backgroundOpacity: 0.9,
          onSecondaryTapDown: (details, offset) async {
            final selection = terminalController.selection;
            if (selection != null) {
              final text = terminal.buffer.getText(selection);
              terminalController.clearSelection();
              await Clipboard.setData(ClipboardData(text: text));
            } else {
              final data = await Clipboard.getData('text/plain');
              final text = data?.text;
              if (text != null) {
                terminal.paste(text);
              }
            }
          },
        ),
      ),
    );
  }
}

String get shell {
  if (Platform.isMacOS || Platform.isLinux) {
    return Platform.environment['SHELL'] ?? 'bash';
  }

  if (Platform.isWindows) {
    return 'cmd.exe';
  }

  return 'sh';
}

Map<ShortcutActivator, Intent> get myShortcuts {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return _defaultShortcuts;
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return _defaultAppleShortcuts;
  }
}

final _defaultShortcuts = {
  const SingleActivator(LogicalKeyboardKey.keyC, control: true, shift: true):
      CopySelectionTextIntent.copy,
  const SingleActivator(LogicalKeyboardKey.keyV, control: true):
      const PasteTextIntent(SelectionChangedCause.keyboard),
  const SingleActivator(LogicalKeyboardKey.insert, shift: true):
      const PasteTextIntent(SelectionChangedCause.keyboard),
  const SingleActivator(LogicalKeyboardKey.keyA, control: true):
      const SelectAllTextIntent(SelectionChangedCause.keyboard),
  const SingleActivator(LogicalKeyboardKey.keyF, control: true):
      const ToggleFullscreenIntent(SelectionChangedCause.keyboard),
};

final _defaultAppleShortcuts = {
  const SingleActivator(LogicalKeyboardKey.keyC, meta: true):
      CopySelectionTextIntent.copy,
  const SingleActivator(LogicalKeyboardKey.keyV, meta: true):
      const PasteTextIntent(SelectionChangedCause.keyboard),
  const SingleActivator(LogicalKeyboardKey.keyA, meta: true):
      const SelectAllTextIntent(SelectionChangedCause.keyboard),
};

class ToggleFullscreenIntent extends Intent {
  const ToggleFullscreenIntent(SelectionChangedCause cause);
}

class ToggleFullscreenAction extends Action<ToggleFullscreenIntent> {
  ToggleFullscreenAction();

  @override
  Object? invoke(covariant ToggleFullscreenIntent intent) {
    print('invoke');
    return null;
  }
}
