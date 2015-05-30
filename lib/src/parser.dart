library svg.src.parser;

import 'dart:math';

import 'package:svg/src/command.dart';
import 'package:svg/src/grammar.dart';
import 'package:quiver/iterables.dart';

class SvgParserDefinition extends SvgGrammarDefinition {
  const SvgParserDefinition();

  @override
  svgPath() => super.svgPath().map((Iterable r) => r.toList(growable: false));

  @override
  moveToDrawToCommandGroup() => super.moveToDrawToCommandGroup().map((result) {
    result = result.where((r) => r != null);
    return concat(result);
  });

  @override
  drawToCommands() => super.drawToCommands().map((result) {
    return concat(result.map((r) => r is Iterable ? r : [r]));
  });

  @override
  closePath() => super.closePath().map((_) => const [const CloseCommand()]);

  @override
  moveTo() => super.moveTo().map((List result) {
    // Single move.
    if (result[2] is Point) {
      return [new MoveToPathCommand((result[2]))];
    }

    // Multiple move.
    if (result[2] is Iterable) {
      return (result[2] as Iterable).where((e) => e is Point).map((p) {
        return new MoveToPathCommand(p);
      });
    }
  });

  @override
  lineTo() => super.lineTo().map((List result) {
    // Single line.
    if (result[2] is Point) {
      return [new LineToPathCommand((result[2]))];
    }

    // Multiple lines.
    if (result[2] is Iterable) {
      return (result[2] as Iterable).where((e) => e is Point).map((p) {
        return new LineToPathCommand(p);
      }).toList(growable: false);
    }
  });

  @override
  coordinatePair() => super.coordinatePair().map((result) {
    return new Point(result[0], result[2]);
  });

  @override
  number() => super.number().map((result) {
    final sign = result[0];
    num number = result[1];
    if (sign == '-') {
      number = -number;
    }
    return number;
  });

  @override
  commaWhitespace() => super.commaWhitespace().map((_) => null);

  @override
  integerConstant() => super.integerConstant().flatten().map(int.parse);

  @override
  floatingPointConstant() {
    return super.floatingPointConstant().flatten().map(double.parse);
  }

  @override
  fractionalConstant() {
    return super.fractionalConstant().flatten().map(double.parse);
  }
}
