import 'package:flutter/material.dart';
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Expanded(
                      child: Icon(
                        _classMirror.invokeGetter(_icons[index]) as IconData,
                      ),
                    ),
                    Text(_icons[index]),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class Reflector extends Reflectable {
  // define required capabillities
  const Reflector() : super(
    staticInvokeCapability,
    declarationsCapability,
    superclassQuantifyCapability,
  );
}

// required so the TemakiIcons class gets reflected
@reflector
class ReflectableTemakiIcons extends TemakiIcons {}
