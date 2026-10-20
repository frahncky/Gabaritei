import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/features/lab/circuit.dart';

void main() {
  const input = CircuitInput(volts: 12, r1: 20, r2: 40);

  test('Lei de Ohm: I = V / R', () {
    final r = CircuitReading.solve(LabMode.ohm, input);
    expect(r.total, closeTo(0.6, 1e-9));
    expect(r.power, closeTo(7.2, 1e-9));
  });

  test('série: mesma corrente e tensão dividida', () {
    final r = CircuitReading.solve(LabMode.serie, input);
    expect(r.req, 60);
    expect(r.total, closeTo(0.2, 1e-9));
    expect(r.v1 + r.v2, closeTo(12, 1e-9));
    expect(r.v2, closeTo(8, 1e-9));
  });

  test('paralelo: corrente se divide e Req é menor que o menor R', () {
    final r = CircuitReading.solve(LabMode.paralelo, input);
    expect(r.i1, closeTo(0.6, 1e-9));
    expect(r.i2, closeTo(0.3, 1e-9));
    expect(r.total, closeTo(0.9, 1e-9));
    expect(r.req, lessThan(20));
  });

  test('situação do circuito conforme o limite', () {
    LabStatus status(LabMode mode, double volts, double r1) =>
        CircuitReading.solve(mode, CircuitInput(volts: volts, r1: r1)).status;

    expect(status(LabMode.ohm, 0, 20), LabStatus.off);
    expect(status(LabMode.ohm, 12, 20), LabStatus.safe); // 0,6 A
    expect(status(LabMode.ohm, 13, 5), LabStatus.near); // 2,6 A
    expect(status(LabMode.ohm, 24, 5), LabStatus.over); // 4,8 A
    expect(status(LabMode.potencia, 24, 20), LabStatus.over); // 28,8 W
  });
}
