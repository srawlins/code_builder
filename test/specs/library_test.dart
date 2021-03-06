// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_builder/code_builder.dart';
import 'package:test/test.dart';

import '../common.dart';

void main() {
  useDartfmt();

  group('File', () {
    final $LinkedHashMap = refer('LinkedHashMap', 'dart:collection');

    test('should emit a source file with manual imports', () {
      expect(
        new Library((b) => b
          ..directives.add(new Directive.import('dart:collection'))
          ..body.add(new Field((b) => b
            ..name = 'test'
            ..modifier = FieldModifier.final$
            ..assignment = $LinkedHashMap.newInstance([]).code))),
        equalsDart(r'''
            import 'dart:collection';
          
            final test = new LinkedHashMap();
          ''', new DartEmitter()),
      );
    });

    test('should emit a source file with a deferred import', () {
      expect(
        new Library(
          (b) => b
            ..directives.add(
              new Directive.importDeferredAs(
                'package:foo/foo.dart',
                'foo',
              ),
            ),
        ),
        equalsDart(r'''
          import 'package:foo/foo.dart' deferred as foo;
        '''),
      );
    });

    test('should emit a source file with a "show" combinator', () {
      expect(
        new Library(
          (b) => b
            ..directives.add(
              new Directive.import(
                'package:foo/foo.dart',
                show: ['Foo', 'Bar'],
              ),
            ),
        ),
        equalsDart(r'''
          import 'package:foo/foo.dart' show Foo, Bar;
        '''),
      );
    });

    test('should emit a source file with a "hide" combinator', () {
      expect(
        new Library(
          (b) => b
            ..directives.add(
              new Directive.import(
                'package:foo/foo.dart',
                hide: ['Foo', 'Bar'],
              ),
            ),
        ),
        equalsDart(r'''
          import 'package:foo/foo.dart' hide Foo, Bar;
        '''),
      );
    });

    test('should emit a source file with allocation', () {
      expect(
        new Library((b) => b
          ..body.add(new Field((b) => b
            ..name = 'test'
            ..modifier = FieldModifier.final$
            ..assignment =
                new Code.scope((a) => 'new ${a($LinkedHashMap)}()')))),
        equalsDart(r'''
          import 'dart:collection';
          
          final test = new LinkedHashMap();
        ''', new DartEmitter(new Allocator())),
      );
    });

    test('should emit a source file with allocation + prefixing', () {
      expect(
        new Library((b) => b
          ..body.add(new Field((b) => b
            ..name = 'test'
            ..modifier = FieldModifier.final$
            ..assignment =
                new Code.scope((a) => 'new ${a($LinkedHashMap)}()')))),
        equalsDart(r'''
          import 'dart:collection' as _i1;
          
          final test = new _i1.LinkedHashMap();
        ''', new DartEmitter(new Allocator.simplePrefixing())),
      );
    });
  });
}
