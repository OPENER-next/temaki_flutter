import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reflectable/reflectable.dart';
import 'main.reflectable.dart';
import 'package:temaki_flutter/temaki_flutter.dart';

const reflector = Reflector();

void main() {
  initializeReflectable();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Temaki Icon Example',
      theme: ThemeData.dark(),
      home: const IconOverviewPage(),
    );
  }
}

class IconOverviewPage extends StatefulWidget {

  const IconOverviewPage({super.key});

  @override
  State<IconOverviewPage> createState() => _IconOverviewPageState();
}

class _IconOverviewPageState extends State<IconOverviewPage> {
  final _classMirror = reflector.reflectType(TemakiIcons) as ClassMirror;
  late final _icons = _classMirror.staticMembers.keys.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Temaki Icon Set'),
      ),
      body: SelectionArea(
        child: GridView.builder(
          primary: true,
          padding: const EdgeInsets.all(15),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
          ),
          itemCount: _icons.length,
          itemBuilder: (BuildContext context, int index) {
            return IconCard(
              name: _icons[index],
              icon: _classMirror.invokeGetter(_icons[index]) as IconData,
            );
          },
        ),
      ),
    );
  }
}

class IconCard extends StatelessWidget {
  final String name;
  final IconData icon;

  const IconCard({
    required this.name,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      child: InkWell(
        onTap: () async {
          final scaffoldRef = ScaffoldMessenger.of(context);
          await Clipboard.setData(ClipboardData(text: name));
          if (scaffoldRef.mounted) {
            scaffoldRef.hideCurrentSnackBar();
            scaffoldRef.showSnackBar(SnackBar(
              content: Text('Copied "$name" to clipboard'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              width: 300,
            ));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Expanded(
                child: Icon(icon,
                  size: 45,
                ),
              ),
              Text(name),
            ],
          ),
        ),
      ),
    );
  }
}


class Reflector extends Reflectable {
  // define required capabilities
  const Reflector() : super(
    staticInvokeCapability,
    declarationsCapability,
    superclassQuantifyCapability,
  );
}

// required so the TemakiIcons class gets reflected
@reflector
class ReflectableTemakiIcons extends TemakiIcons {}
