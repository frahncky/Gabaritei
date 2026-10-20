import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/features/lab/color_code.dart';

void main() {
  test('marrom, preto, vermelho = 1 kΩ', () {
    const bands = ResistorBands();
    expect(bands.ohms, 1000);
    expect(formatOhms(bands.ohms), '1 kΩ');
  });

  test('amarelo, violeta, vermelho, dourado = 4,7 kΩ ±5%', () {
    const bands = ResistorBands(
      first: BandColor.amarelo,
      second: BandColor.violeta,
      multiplier: BandColor.vermelho,
      tolerance: BandColor.dourado,
    );
    expect(formatOhms(bands.ohms), '4,7 kΩ');
    expect(bands.matches(4700), isTrue);
    expect(bands.minOhms, closeTo(4465, 1e-6));
    expect(bands.maxOhms, closeTo(4935, 1e-6));
  });

  test('multiplicadores dourado e prata dividem', () {
    const bands = ResistorBands(
      first: BandColor.amarelo,
      second: BandColor.violeta,
      multiplier: BandColor.prata,
    );
    expect(formatOhms(bands.ohms), '0,47 Ω');
  });

  test('formatação com prefixos', () {
    expect(formatOhms(220), '220 Ω');
    expect(formatOhms(2200), '2,2 kΩ');
    expect(formatOhms(1000000), '1 MΩ');
  });

  test('o primeiro dígito nunca é preto', () {
    expect(BandColor.firstDigits, isNot(contains(BandColor.preto)));
  });
}
