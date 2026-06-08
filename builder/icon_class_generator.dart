import 'dart:convert';

import 'package:build/build.dart';
import 'package:recase/recase.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

/// The builder used by build runner to generate the icon class file.

Builder iconSetBuilder(BuilderOptions options) => _IconClassBuilder();

class _IconClassBuilder implements Builder {
  @override
  final buildExtensions = const {
    '.json': ['.dart']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    var inputId = buildStep.inputId;

    var newFile = inputId.changeExtension('.dart');

    final jsonString = await buildStep.readAsString(inputId);
    final jsonMap = jsonDecode(jsonString).cast<String, int>();

    final iconClassWriter = IconClassWriter(
      packageName: 'temaki_flutter',
      className: 'TemakiIcons',
      fontFamily: 'TemakiIconFont',
      iconCodeMapping: jsonMap,
    );

    await buildStep.writeAsString(newFile, iconClassWriter.toString());
  }
}


/// Class to generate a class file exposing all icons from the icon font as class fields.

class IconClassWriter {
  final String packageName;
  final String className;
  final String fontFamily;
  final Map<String, int> iconCodeMapping;

  IconClassWriter({
    required this.packageName,
    required this.className,
    required this.fontFamily,
    required this.iconCodeMapping,
  });

  Class _createIconClass() {
    return Class((b) => b
      ..name = className
      ..fields.addAll(_createIconFields()),
    );
  }

  Iterable<Field> _createIconFields() sync* {
    for (final entry in iconCodeMapping.entries) {
      // convert underscore to lower camel case
      final iconName = ReCase(entry.key).camelCase;
      final iconCode = entry.value;

      yield Field((b) => b
        ..static = true
        ..name = iconName
        ..modifier = FieldModifier.constant
        ..type = refer('IconData', 'package:flutter/widgets.dart')
        ..assignment = refer('IconData', 'package:flutter/widgets.dart').newInstance([
          literalNum(iconCode)
        ], {
          'fontFamily': literalString(fontFamily),
          'fontPackage': literalString(packageName),
        }).code,
      );
    }
  }

  @override
  String toString() {
    final library = Library((b) => b
      ..name = packageName
      ..body.addAll([
        _createIconClass(),
      ]),
    );
    final emitter = DartEmitter(allocator: Allocator());

    return DartFormatter(languageVersion: DartFormatter.latestLanguageVersion).format(
      library.accept(emitter).toString(),
    );
  }
}
