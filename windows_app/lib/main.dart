import 'package:fluent_ui/fluent_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          accentColor: Colors.blue,
          iconTheme: const IconThemeData(size: 24)),
      darkTheme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          accentColor: Colors.blue,
          iconTheme: const IconThemeData(size: 24)),
      home: SafeArea(
        child: NavigationView(
          appBar: const NavigationAppBar(title: Text("Fluent Design App Bar")),
          pane: NavigationPane(displayMode: PaneDisplayMode.auto, items: [
            PaneItem(icon: const Icon(FluentIcons.add), title: const Text("Sample Page 1")),
            PaneItem(icon: const Icon(FluentIcons.add), title: const Text("Sample Page 2"))
          ]),
        ),
      ),
    );
  }
}
