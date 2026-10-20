import '../models/content.dart';

/// Gera questões a partir de modelos pedagógicos revisáveis.
class QuestionGenerator {
  QuestionGenerator._();

  static const topics = [
    'Lei de Ohm',
    'Associação de resistores',
    'Instalações elétricas',
    'Automação e controle',
  ];

  static Question generate({required String topic, required int sequence}) {
    return switch (topic) {
      'Lei de Ohm' => _ohm(sequence),
      'Associação de resistores' => _parallel(sequence),
      'Instalações elétricas' => _electricalPlan(sequence),
      'Automação e controle' => _processControl(sequence),
      _ => _ohm(sequence),
    };
  }

  static Question _ohm(int sequence) {
    const resistances = [100, 220, 470, 1000];
    const voltage = 12;
    final resistance = resistances[sequence.abs() % resistances.length];
    final current = voltage * 1000 / resistance;
    final answer = current % 1 == 0
        ? '${current.toInt()} mA'
        : '${current.toStringAsFixed(1).replaceAll('.', ',')} mA';
    return Question(
      id: 'generated-ohm-$sequence',
      topic: 'Lei de Ohm',
      prompt:
          'Uma fonte de $voltage V alimenta um resistor de $resistance Ω. Qual é a corrente aproximada?',
      options: [
        answer,
        '${resistance ~/ 10} mA',
        '${voltage * 10} mA',
        '$resistance mA'
      ],
      correctIndex: 0,
      explanation:
          'Pela Lei de Ohm, I = V / R. A corrente calculada é $answer.',
      hint: 'Use I = V / R e converta amperes para miliamperes.',
      visual: QuestionVisual.circuitSeries,
    );
  }

  static Question _parallel(int sequence) => Question(
        id: 'generated-parallel-$sequence',
        topic: 'Associação de resistores',
        prompt:
            'No circuito em paralelo ilustrado, dois resistores de 100 Ω têm resistência equivalente de:',
        options: const ['200 Ω', '100 Ω', '50 Ω', '25 Ω'],
        correctIndex: 2,
        explanation: 'Para resistores iguais em paralelo, Req = R / 2: 50 Ω.',
        hint: 'A resistência equivalente é menor que o menor resistor.',
        visual: QuestionVisual.circuitParallel,
      );

  static Question _electricalPlan(int sequence) => Question(
        id: 'generated-plan-$sequence',
        topic: 'Instalações elétricas',
        prompt:
            'Na planta elétrica, qual elemento recebe energia diretamente do quadro de distribuição?',
        options: const [
          'Interruptor',
          'Tomada',
          'Luminária',
          'Todos os pontos do circuito'
        ],
        correctIndex: 3,
        explanation:
            'O quadro alimenta os circuitos que atendem tomadas, interruptores e luminárias.',
        hint: 'Siga o condutor destacado a partir do QD.',
        visual: QuestionVisual.electricalPlan,
      );

  static Question _processControl(int sequence) => Question(
        id: 'generated-control-$sequence',
        topic: 'Automação e controle',
        prompt:
            'No laço de controle mostrado, qual componente decide a ação a partir da leitura do sensor?',
        options: const ['Tanque', 'Válvula', 'CLP', 'Sensor'],
        correctIndex: 2,
        explanation: 'O CLP processa a medição e envia o comando ao atuador.',
        hint: 'Busque o elemento entre a medição e o atuador.',
        visual: QuestionVisual.processControl,
      );
}
