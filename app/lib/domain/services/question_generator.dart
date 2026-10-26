import '../models/content.dart';

enum TechnicalCourse {
  electronics('Técnico em Eletrônica'),
  electrotechnics('Técnico em Eletrotécnica'),
  automation('Técnico em Automação Industrial'),
  mechatronics('Técnico em Mecatrônica');

  const TechnicalCourse(this.label);
  final String label;
}

class CurriculumTopic {
  const CurriculumTopic(this.label, this.objective);

  final String label;
  final String objective;
}

/// Gera questões a partir de modelos pedagógicos revisáveis.
class QuestionGenerator {
  QuestionGenerator._();

  static const topics = [
    'Eletricidade básica',
    'Circuitos CC',
    'Circuitos CA',
    'Eletrônica analógica',
    'Eletrônica digital',
    'Eletrônica de potência',
    'Segurança e normas',
    'Máquinas elétricas',
    'Instalações elétricas',
    'CLP',
    'Robótica',
    'Supervisórios e controle de processos',
    'Telecomunicações',
    'Programação',
    'Matemática e física aplicadas',
    'Desenho técnico e CAD',
    'Metrologia',
    'Materiais e processos de fabricação',
    'Mecânica e elementos de máquinas',
    'Pneumática e hidráulica',
    'Sensores e instrumentação',
    'Microcontroladores e sistemas embarcados',
    'Redes industriais',
    'CNC e manufatura',
    'Projetos e manutenção',
    'Qualidade, gestão e meio ambiente',
  ];

  static const Map<TechnicalCourse, List<String>> curriculum = {
    TechnicalCourse.electronics: [
      'Eletricidade básica',
      'Circuitos CC',
      'Circuitos CA',
      'Eletrônica analógica',
      'Eletrônica digital',
      'Eletrônica de potência',
      'Segurança e normas',
      'Telecomunicações',
      'Programação',
      'Matemática e física aplicadas',
      'Desenho técnico e CAD',
      'Metrologia',
      'Sensores e instrumentação',
      'Microcontroladores e sistemas embarcados',
      'Projetos e manutenção',
      'Qualidade, gestão e meio ambiente',
    ],
    TechnicalCourse.electrotechnics: [
      'Eletricidade básica',
      'Circuitos CC',
      'Circuitos CA',
      'Eletrônica de potência',
      'Segurança e normas',
      'Máquinas elétricas',
      'Instalações elétricas',
      'Matemática e física aplicadas',
      'Desenho técnico e CAD',
      'Metrologia',
      'Sensores e instrumentação',
      'Projetos e manutenção',
      'Qualidade, gestão e meio ambiente',
    ],
    TechnicalCourse.automation: [
      'Eletricidade básica',
      'Eletrônica digital',
      'Eletrônica de potência',
      'Segurança e normas',
      'CLP',
      'Robótica',
      'Supervisórios e controle de processos',
      'Programação',
      'Matemática e física aplicadas',
      'Desenho técnico e CAD',
      'Metrologia',
      'Pneumática e hidráulica',
      'Sensores e instrumentação',
      'Microcontroladores e sistemas embarcados',
      'Redes industriais',
      'Projetos e manutenção',
      'Qualidade, gestão e meio ambiente',
    ],
    TechnicalCourse.mechatronics: [
      'Eletricidade básica',
      'Circuitos CC',
      'Eletrônica analógica',
      'Eletrônica digital',
      'Eletrônica de potência',
      'Segurança e normas',
      'Máquinas elétricas',
      'CLP',
      'Robótica',
      'Supervisórios e controle de processos',
      'Programação',
      'Matemática e física aplicadas',
      'Desenho técnico e CAD',
      'Metrologia',
      'Materiais e processos de fabricação',
      'Mecânica e elementos de máquinas',
      'Pneumática e hidráulica',
      'Sensores e instrumentação',
      'Microcontroladores e sistemas embarcados',
      'Redes industriais',
      'CNC e manufatura',
      'Projetos e manutenção',
      'Qualidade, gestão e meio ambiente',
    ],
  };

  static const Map<String, List<CurriculumTopic>> syllabus = {
    'Eletricidade básica': [
      CurriculumTopic('Grandezas elétricas',
          'relaciona tensão, corrente, resistência e potência'),
      CurriculumTopic('Lei de Ohm', 'calcula grandezas usando V = R · I'),
      CurriculumTopic(
          'Energia e potência', 'calcula consumo, potência e energia elétrica'),
    ],
    'Circuitos CC': [
      CurriculumTopic('Série e paralelo',
          'determina resistência, tensão e corrente equivalentes'),
      CurriculumTopic(
          'Leis de Kirchhoff', 'analisa correntes em nós e tensões em malhas'),
      CurriculumTopic('Transitórios RC e RL',
          'avalia carga, descarga e constantes de tempo'),
    ],
    'Circuitos CA': [
      CurriculumTopic('Senoides e fasores',
          'representa amplitude, frequência, fase e valores eficazes'),
      CurriculumTopic('Impedância RLC',
          'analisa resistência e reatâncias em corrente alternada'),
      CurriculumTopic('Potência e fator de potência',
          'distingue potência ativa, reativa e aparente'),
    ],
    'Eletrônica analógica': [
      CurriculumTopic('Diodos e retificadores',
          'analisa condução, retificação e filtragem'),
      CurriculumTopic(
          'Transistores', 'aplica BJT e MOSFET em chaveamento e amplificação'),
      CurriculumTopic(
          'Amplificadores operacionais', 'projeta circuitos com realimentação'),
      CurriculumTopic('Filtros e osciladores',
          'seleciona frequências e gera sinais periódicos'),
    ],
    'Eletrônica digital': [
      CurriculumTopic('Sistemas de numeração',
          'converte valores binários, decimais e hexadecimais'),
      CurriculumTopic('Lógica combinacional',
          'projeta circuitos com portas e mapas de Karnaugh'),
      CurriculumTopic('Lógica sequencial',
          'utiliza flip-flops, contadores e registradores'),
    ],
    'Eletrônica de potência': [
      CurriculumTopic('Retificadores controlados',
          'controla conversão CA-CC com semicondutores'),
      CurriculumTopic('Conversores CC-CC', 'regula tensão por chaveamento'),
      CurriculumTopic(
          'Inversores e acionamentos', 'converte CC em CA e controla motores'),
    ],
    'Segurança e normas': [
      CurriculumTopic('NR-10', 'aplica medidas de controle do risco elétrico'),
      CurriculumTopic('Desenergização e bloqueio',
          'executa seccionamento, impedimento e constatação'),
      CurriculumTopic('Proteção e aterramento',
          'seleciona dispositivos e esquemas de proteção'),
    ],
    'Máquinas elétricas': [
      CurriculumTopic('Transformadores',
          'relaciona tensões, correntes, perdas e rendimento'),
      CurriculumTopic('Motores de indução',
          'analisa campo girante, escorregamento e torque'),
      CurriculumTopic('Máquinas CC e síncronas',
          'avalia princípios, excitação e aplicações'),
    ],
    'Instalações elétricas': [
      CurriculumTopic('Plantas e simbologia',
          'interpreta pontos, circuitos e diagramas elétricos'),
      CurriculumTopic('Dimensionamento',
          'dimensiona condutores, proteção e queda de tensão'),
      CurriculumTopic(
          'Luminotécnica', 'distribui iluminação conforme uso e desempenho'),
      CurriculumTopic('Comandos elétricos',
          'projeta partida, proteção e intertravamento de motores'),
    ],
    'CLP': [
      CurriculumTopic('Ciclo de varredura',
          'relaciona leitura, execução e atualização de saídas'),
      CurriculumTopic('Linguagem Ladder',
          'programa contatos, bobinas, temporizadores e contadores'),
      CurriculumTopic('Entradas e saídas',
          'integra sinais digitais e analógicos ao controlador'),
    ],
    'Robótica': [
      CurriculumTopic(
          'Cinemática', 'relaciona juntas, posições e trajetórias do robô'),
      CurriculumTopic('Sensores e atuadores',
          'integra percepção e movimento ao controlador'),
      CurriculumTopic('Programação de robôs',
          'define coordenadas, movimentos e segurança operacional'),
    ],
    'Supervisórios e controle de processos': [
      CurriculumTopic(
          'Controle PID', 'ajusta ações proporcional, integral e derivativa'),
      CurriculumTopic('IHM e supervisório',
          'monitora variáveis, alarmes, tendências e comandos'),
      CurriculumTopic('Malhas de processo',
          'integra sensor, controlador, atuador e planta'),
    ],
    'Telecomunicações': [
      CurriculumTopic(
          'Modulação', 'compara técnicas analógicas e digitais de transmissão'),
      CurriculumTopic(
          'Meios de transmissão', 'avalia cabos, fibras e enlaces sem fio'),
      CurriculumTopic(
          'Redes e sinais', 'analisa largura de banda, ruído e protocolos'),
    ],
    'Programação': [
      CurriculumTopic(
          'Lógica e algoritmos', 'constrói sequências, decisões e repetições'),
      CurriculumTopic(
          'Estruturas de dados', 'organiza coleções e registros de informação'),
      CurriculumTopic('Programação aplicada',
          'integra software, dispositivos e comunicação'),
    ],
    'Matemática e física aplicadas': [
      CurriculumTopic('Álgebra e trigonometria',
          'resolve equações, vetores e relações geométricas'),
      CurriculumTopic(
          'Mecânica e energia', 'aplica força, movimento, trabalho e potência'),
      CurriculumTopic(
          'Ondas e eletromagnetismo', 'relaciona campos, indução e propagação'),
    ],
    'Desenho técnico e CAD': [
      CurriculumTopic(
          'Vistas e cortes', 'representa objetos por projeções e seções'),
      CurriculumTopic(
          'Cotagem e escalas', 'documenta dimensões e proporções de projeto'),
      CurriculumTopic('CAD elétrico e mecânico',
          'produz esquemas e desenhos assistidos por computador'),
    ],
    'Metrologia': [
      CurriculumTopic('Instrumentos de medição',
          'seleciona instrumentos e realiza leituras'),
      CurriculumTopic(
          'Erros e incerteza', 'avalia precisão, resolução e rastreabilidade'),
      CurriculumTopic(
          'Calibração', 'compara instrumentos com padrões de referência'),
    ],
    'Materiais e processos de fabricação': [
      CurriculumTopic('Materiais de engenharia',
          'seleciona metais, polímeros e compósitos'),
      CurriculumTopic('Usinagem e conformação',
          'relaciona processos, ferramentas e parâmetros'),
      CurriculumTopic(
          'Soldagem e montagem', 'define processos de união e inspeção'),
    ],
    'Mecânica e elementos de máquinas': [
      CurriculumTopic('Estática e resistência',
          'avalia esforços, equilíbrio e deformações'),
      CurriculumTopic('Transmissão mecânica',
          'dimensiona engrenagens, correias e acoplamentos'),
      CurriculumTopic('Rolamentos e eixos',
          'seleciona componentes e condições de montagem'),
    ],
    'Pneumática e hidráulica': [
      CurriculumTopic('Geração e preparação',
          'condiciona ar comprimido e fluido hidráulico'),
      CurriculumTopic('Válvulas e atuadores',
          'comanda cilindros e motores fluidomecânicos'),
      CurriculumTopic('Circuitos eletropneumáticos',
          'integra comandos elétricos e pneumáticos'),
    ],
    'Sensores e instrumentação': [
      CurriculumTopic('Sensores industriais',
          'seleciona sensores de posição, temperatura, pressão e vazão'),
      CurriculumTopic('Sinais e condicionamento',
          'trata sinais analógicos e digitais de medição'),
      CurriculumTopic('Transmissores e calibração',
          'configura faixas e verifica instrumentos de processo'),
    ],
    'Microcontroladores e sistemas embarcados': [
      CurriculumTopic('Arquitetura e periféricos',
          'utiliza memória, GPIO, timers e conversores'),
      CurriculumTopic(
          'Firmware', 'programa leitura, controle e temporização embarcada'),
      CurriculumTopic('Comunicação embarcada', 'integra UART, SPI, I²C e CAN'),
    ],
    'Redes industriais': [
      CurriculumTopic('Topologias e camadas',
          'organiza dispositivos e fluxo de dados industrial'),
      CurriculumTopic('Protocolos industriais',
          'compara Modbus, Profibus, Profinet e Ethernet/IP'),
      CurriculumTopic('Diagnóstico de rede',
          'identifica falhas de comunicação e configuração'),
    ],
    'CNC e manufatura': [
      CurriculumTopic('Coordenadas e referência',
          'define origem, eixos e sistemas de trabalho'),
      CurriculumTopic('Programação CNC', 'interpreta e cria comandos G e M'),
      CurriculumTopic('Automação da produção',
          'integra máquinas, robôs e controle de qualidade'),
    ],
    'Projetos e manutenção': [
      CurriculumTopic('Documentação de projeto',
          'elabora requisitos, diagramas e listas de materiais'),
      CurriculumTopic('Manutenção preventiva e preditiva',
          'planeja intervenções por tempo e condição'),
      CurriculumTopic(
          'Diagnóstico de falhas', 'testa hipóteses e identifica causas raiz'),
    ],
    'Qualidade, gestão e meio ambiente': [
      CurriculumTopic('Ferramentas da qualidade',
          'aplica indicadores, PDCA e análise de causa'),
      CurriculumTopic(
          'Gestão de projetos', 'planeja escopo, prazo, custo e riscos'),
      CurriculumTopic(
          'Sustentabilidade', 'reduz impactos, resíduos e consumo de recursos'),
    ],
  };

  static List<String> topicsFor(TechnicalCourse course) => curriculum[course]!;

  static List<CurriculumTopic> unitsFor(String discipline) =>
      syllabus[discipline] ?? const [];

  static Question generate({
    required String topic,
    required int sequence,
    String? unit,
  }) {
    if (unit != null) {
      final selected = unitsFor(topic).firstWhere(
        (item) => item.label == unit,
        orElse: () => unitsFor(topic).first,
      );
      final installations =
          topic == _installations ? _installationUnits[selected.label] : null;
      if (installations != null) {
        return _installationQuestion(selected.label, installations, sequence);
      }
      return _unitQuestion(topic, selected, sequence);
    }
    return switch (topic) {
      'Eletricidade básica' => _ohm(sequence),
      'Circuitos CC' => _parallel(sequence),
      'Circuitos CA' => _concept(
          sequence,
          topic,
          'Em um circuito CA senoidal de 60 Hz, qual é o período de um ciclo?',
          const ['16,7 ms', '60 ms', '8,3 ms', '1 s'],
          0,
          'O período é T = 1/f = 1/60 s ≈ 16,7 ms.',
          'Use T = 1/f.',
          null,
        ),
      'Eletrônica analógica' => _concept(
          sequence,
          topic,
          'Em um amplificador operacional ideal com realimentação negativa, a diferença de tensão entre as entradas é aproximadamente:',
          const [
            'Zero',
            'A tensão de alimentação',
            'Metade da saída',
            'Infinita'
          ],
          0,
          'A realimentação negativa força as entradas ao chamado curto virtual.',
          'Considere o comportamento do amplificador operacional ideal.',
          null,
        ),
      'Eletrônica digital' => _concept(
          sequence,
          topic,
          'Qual é a saída de uma porta AND quando suas duas entradas são nível lógico 1?',
          const ['0', '1', 'Alta impedância', 'Indefinida'],
          1,
          'A porta AND produz 1 somente quando todas as entradas são 1.',
          'Consulte a tabela-verdade da porta AND.',
          null,
        ),
      'Eletrônica de potência' => _concept(
          sequence,
          topic,
          'Qual dispositivo é frequentemente usado para controlar potência em cargas CA?',
          const ['TRIAC', 'LED', 'Amplificador operacional', 'Relé térmico'],
          0,
          'O TRIAC conduz nos dois semiciclos e é usado no controle de potência CA.',
          'Pense em um semicondutor bidirecional.',
          null,
        ),
      'Segurança e normas' => _concept(
          sequence,
          topic,
          'Antes de intervir em uma instalação desenergizada, qual ação confirma a ausência de risco elétrico?',
          const [
            'Constatação da ausência de tensão',
            'Somente desligar a carga',
            'Usar luvas comuns',
            'Retirar a sinalização'
          ],
          0,
          'A ausência de tensão deve ser constatada com instrumento adequado, dentro do procedimento de desenergização.',
          'Desligar não basta; é necessário verificar.',
          QuestionVisual.electricalPlan,
        ),
      'Máquinas elétricas' => _concept(
          sequence,
          topic,
          'Em um motor de indução, o rotor gira normalmente:',
          const [
            'Abaixo da velocidade síncrona',
            'Acima da velocidade síncrona',
            'Sempre parado',
            'Exatamente na velocidade síncrona'
          ],
          0,
          'É necessário escorregamento para induzir corrente e produzir torque no rotor.',
          'Lembre-se do conceito de escorregamento.',
          null,
        ),
      _installations => _bedroomPlan(sequence),
      'CLP' => _concept(
          sequence,
          topic,
          'No ciclo de varredura de um CLP, qual etapa ocorre antes da atualização das saídas?',
          const [
            'Execução do programa',
            'Desligamento da CPU',
            'Formatação da memória',
            'Troca do protocolo'
          ],
          0,
          'O CLP lê entradas, executa o programa e então atualiza as saídas.',
          'Pense na sequência entrada → lógica → saída.',
          QuestionVisual.processControl,
        ),
      'Robótica' => _concept(
          sequence,
          topic,
          'Qual componente informa a posição de uma junta em um robô industrial?',
          const ['Encoder', 'Contator', 'Fusível', 'Transformador'],
          0,
          'O encoder fornece realimentação de posição e velocidade ao controlador.',
          'É um sensor de movimento angular.',
          null,
        ),
      'Supervisórios e controle de processos' => _processControl(sequence),
      'Telecomunicações' => _concept(
          sequence,
          topic,
          'Na modulação, qual grandeza de uma portadora é alterada no sistema AM?',
          const [
            'Amplitude',
            'Frequência',
            'Fase exclusivamente',
            'Velocidade de propagação'
          ],
          0,
          'Em AM, a amplitude da portadora varia conforme o sinal de informação.',
          'AM significa modulação em amplitude.',
          null,
        ),
      'Programação' => _concept(
          sequence,
          topic,
          'Qual estrutura repete um bloco enquanto uma condição permanece verdadeira?',
          const ['Laço while', 'Constante', 'Comentário', 'Importação'],
          0,
          'O laço while avalia a condição antes de cada repetição.',
          'Procure uma estrutura de repetição condicional.',
          null,
        ),
      _ => _unitQuestion(topic, unitsFor(topic).first, sequence),
    };
  }

  static Question _unitQuestion(
    String discipline,
    CurriculumTopic selected,
    int sequence,
  ) {
    final distractors = syllabus.values
        .expand((items) => items)
        .where((item) => item.label != selected.label)
        .map((item) => item.objective)
        .take(3)
        .toList();
    return Question(
      id: 'generated-unit-${discipline.hashCode}-${selected.label.hashCode}-$sequence',
      topic: discipline,
      prompt:
          'Qual alternativa descreve corretamente o assunto “${selected.label}” em $discipline?',
      options: [selected.objective, ...distractors],
      correctIndex: 0,
      explanation: '${selected.label}: ${selected.objective}.',
      hint: 'Relacione o nome do assunto à sua aplicação técnica principal.',
      visual: _visualFor(discipline),
    );
  }

  /// Desenho das questões por assunto. Só entra quando ele tem relação com a
  /// disciplina; no resto, sem visual (um circuito em série numa questão de
  /// Metrologia só confunde). Instalações elétricas não passa por aqui: os
  /// assuntos dela têm visual próprio em [_installationUnits].
  static QuestionVisual? _visualFor(String discipline) => switch (discipline) {
        'Segurança e normas' ||
        'Desenho técnico e CAD' =>
          QuestionVisual.electricalPlan,
        // Laço sensor → CLP → atuador: é o assunto destas duas disciplinas.
        // Robótica, redes, pneumática e programação não aparecem no desenho.
        'CLP' ||
        'Supervisórios e controle de processos' =>
          QuestionVisual.processControl,
        // Eletrônica analógica fica sem visual: diodos, transistores,
        // amplificadores e filtros não têm relação com o código de cores.
        _ => null,
      };

  static Question _concept(
    int sequence,
    String topic,
    String prompt,
    List<String> options,
    int correctIndex,
    String explanation,
    String hint,
    QuestionVisual? visual,
  ) =>
      Question(
        id: 'generated-concept-${topic.hashCode}-$sequence',
        topic: topic,
        prompt: prompt,
        options: options,
        correctIndex: correctIndex,
        explanation: explanation,
        hint: hint,
        visual: visual,
      );

  /// Distratores vêm de erros comuns: fórmula invertida (R / V), resultado em
  /// amperes rotulado como mA e o valor certo com a unidade errada (A).
  static Question _ohm(int sequence) {
    const resistances = [100, 220, 470, 1000];
    const voltage = 12;
    final resistance = resistances[sequence.abs() % resistances.length];
    final amperes = voltage / resistance;
    final milliamps = amperes * 1000;
    final value = _decimal(milliamps.toStringAsFixed(1));
    final answer = '$value mA';
    final distractors = [
      '${_decimal((resistance / voltage).toStringAsFixed(1))} mA',
      '${_decimal(amperes.toStringAsPrecision(2))} mA',
      '$value A',
    ];
    // A posição da correta muda com a sequência, sem acompanhar o resistor.
    final correctIndex = (sequence.abs() ~/ resistances.length) % 4;
    final options = [...distractors]..insert(correctIndex, answer);
    final relation = milliamps % 1 == 0 ? '=' : '≈';
    return Question(
      id: 'generated-ohm-$sequence',
      topic: 'Eletricidade básica',
      prompt:
          'Uma fonte de $voltage V alimenta um resistor de $resistance Ω. Qual é a corrente aproximada?',
      options: options,
      correctIndex: correctIndex,
      explanation:
          'Pela Lei de Ohm, I = V / R = $voltage / $resistance $relation $answer.',
      hint: 'Use I = V / R e converta amperes para miliamperes.',
      // O desenho em série mostra 12 V e 220 Ω; só combina com esse caso.
      visual: resistance == 220 ? QuestionVisual.circuitSeries : null,
    );
  }

  /// Troca o ponto decimal pela vírgula e tira o ",0" final.
  static String _decimal(String value) {
    final text =
        value.endsWith('.0') ? value.substring(0, value.length - 2) : value;
    return text.replaceAll('.', ',');
  }

  static Question _parallel(int sequence) => Question(
        id: 'generated-parallel-$sequence',
        topic: 'Circuitos CC',
        prompt:
            'No circuito em paralelo ilustrado, dois resistores de 100 Ω têm resistência equivalente de:',
        options: const ['200 Ω', '100 Ω', '50 Ω', '25 Ω'],
        correctIndex: 2,
        explanation: 'Para resistores iguais em paralelo, Req = R / 2: 50 Ω.',
        hint: 'A resistência equivalente é menor que o menor resistor.',
        visual: QuestionVisual.circuitParallel,
      );

  static const _installations = 'Instalações elétricas';

  /// Sem assunto escolhido, percorre todas as questões da planta do quarto.
  static Question _bedroomPlan(int sequence) {
    final pool = [
      for (final unit in _installationUnits.values)
        if (unit.visual == QuestionVisual.bedroomPlan) ...unit.items,
    ];
    final item = pool[sequence.abs() % pool.length];
    return Question(
      id: 'generated-plan-$sequence',
      topic: _installations,
      prompt: '${item.prompt[0].toUpperCase()}${item.prompt.substring(1)}',
      options: item.options,
      correctIndex: item.correctIndex,
      explanation: item.explanation,
      hint: item.hint,
      visual: QuestionVisual.bedroomPlan,
    );
  }

  /// O assunto abre o enunciado ("Dimensionamento: considere…"), para o
  /// professor reconhecer de onde veio a questão no banco.
  static Question _installationQuestion(
    String unit,
    _InstallationUnit pool,
    int sequence,
  ) {
    final item = pool.items[sequence.abs() % pool.items.length];
    return Question(
      id: 'generated-installations-${pool.slug}-$sequence',
      topic: _installations,
      prompt: '$unit: ${item.prompt}',
      options: item.options,
      correctIndex: item.correctIndex,
      explanation: item.explanation,
      hint: item.hint,
      visual: pool.visual,
    );
  }

  /// Questões de Instalações elétricas por assunto. As de planta só usam o
  /// que o desenho [QuestionVisual.bedroomPlan] mostra: quarto de
  /// 3,50 m × 3,00 m (10,50 m², 13,00 m de perímetro), ponto de luz de
  /// 160 VA (circuito 1, comando "a"), interruptor "a", 3 TUGs baixas de
  /// 100 VA (circuito 2), TUE alta de 1.500 W do ar-condicionado
  /// (circuito 3) e alimentação vinda do QD. A tensão não está no desenho:
  /// quando a conta precisa dela, o enunciado informa. Os enunciados começam
  /// em minúscula porque recebem o assunto (ou a maiúscula) na frente.
  static const Map<String, _InstallationUnit> _installationUnits = {
    'Plantas e simbologia': (
      slug: 'simbologia',
      visual: QuestionVisual.bedroomPlan,
      items: [
        _Template(
          prompt: 'na planta do quarto, de onde saem os circuitos terminais '
              '1, 2 e 3?',
          options: [
            'Do medidor de energia',
            'Do interruptor "a"',
            'Do quadro de distribuição (QD)',
            'Da TUE do ar-condicionado',
          ],
          correctIndex: 2,
          explanation: 'Os circuitos terminais partem do QD, indicado pela '
              'seta "do QD". O medidor alimenta o QD, e o interruptor só '
              'comanda o ponto de luz.',
          hint: 'Siga os eletrodutos até a seta que entra no quarto.',
        ),
        _Template(
          prompt: 'quantos pontos de tomada o quarto da planta tem?',
          options: ['3', '4', '5', '6'],
          correctIndex: 1,
          explanation: 'São 3 TUGs (circuito 2) e 1 TUE do ar-condicionado '
              '(circuito 3): 4 pontos de tomada. Ponto de luz e interruptor '
              'não são tomadas.',
          hint: 'TUG e TUE são os dois tipos de ponto de tomada.',
        ),
        _Template(
          prompt: 'na legenda da planta do quarto, o que diferencia a TUE '
              'das TUGs?',
          options: [
            'A TUE é trifásica, e as TUGs, monofásicas',
            'A TUE fica no teto, e as TUGs, na parede',
            'A TUE tem 100 VA, e as TUGs, 1.500 W',
            'A TUE atende um equipamento definido; as TUGs, aparelhos '
                'quaisquer',
          ],
          correctIndex: 3,
          explanation: 'TUE é tomada de uso específico: atende um equipamento '
              'definido (aqui, o ar-condicionado de 1.500 W) e recebe a '
              'potência dele. TUG é de uso geral, para aparelhos quaisquer.',
          hint: 'Leia o nome completo das siglas: uso geral e uso específico.',
        ),
        _Template(
          prompt: 'na legenda da planta do quarto, o que indica a palavra '
              '"baixa" nas TUGs?',
          options: [
            'A altura de instalação, perto do piso',
            'A potência das tomadas, de 100 VA',
            'Que são tomadas de 10 A, e não de 20 A',
            'Que recebem a tensão mais baixa do quadro',
          ],
          correctIndex: 0,
          explanation: 'Tomada baixa, média ou alta indica a altura de '
              'instalação na parede: as TUGs ficam perto do piso, e a TUE do '
              'ar-condicionado, no alto. Potência e circuito vêm anotados à '
              'parte.',
          hint: 'Compare com a TUE do ar-condicionado, marcada como "alta".',
        ),
        _Template(
          prompt: 'na planta do quarto, o que o interruptor "a" comanda?',
          options: [
            'O ponto de luz e as TUGs',
            'Só o ponto de luz do teto',
            'Todo o circuito 1, desde o QD',
            'A TUE do ar-condicionado',
          ],
          correctIndex: 1,
          explanation: 'O interruptor e o ponto de luz do teto têm a mesma '
              'letra "a", que liga comando e carga. As tomadas dos circuitos '
              '2 e 3 não passam pelo interruptor.',
          hint: 'Procure no desenho outro ponto com a mesma letra do '
              'interruptor.',
        ),
      ],
    ),
    'Dimensionamento': (
      slug: 'dimensionamento',
      visual: QuestionVisual.bedroomPlan,
      items: [
        _Template(
          prompt: 'qual é a potência total prevista na planta do quarto para '
              'o circuito 2, das TUGs?',
          options: ['100 VA', '300 VA', '460 VA', '1.800 VA'],
          correctIndex: 1,
          explanation: 'O circuito 2 tem 3 TUGs de 100 VA, o mínimo da '
              'NBR 5410 por TUG fora de cozinhas, áreas de serviço e '
              'banheiros: 3 × 100 = 300 VA. O ponto de luz (160 VA) é do '
              'circuito 1.',
          hint: 'Some só os pontos marcados com o circuito 2.',
        ),
        _Template(
          prompt: 'considere 127 V. Qual é a corrente do circuito 1, que '
              'alimenta o ponto de luz de 160 VA da planta?',
          options: ['0,73 A', '0,79 A', '3,62 A', '1,26 A'],
          correctIndex: 3,
          explanation: 'I = S / V = 160 / 127 ≈ 1,26 A (S é a potência '
              'aparente, em VA). O interruptor não consome potência, e as '
              'TUGs são do circuito 2.',
          hint: 'Use I = S / V com a potência anotada no ponto de luz.',
        ),
        _Template(
          prompt: 'considere 127 V e fator de potência 1. Qual é a corrente '
              'do circuito 3, da TUE do ar-condicionado de 1.500 W?',
          options: ['11,8 A', '6,8 A', '0,08 A', '11,8 mA'],
          correctIndex: 0,
          explanation: 'I = P / V = 1.500 / 127 ≈ 11,8 A. Como passa de 10 A, '
              'a NBR 5410 pede circuito independente: por isso o circuito 3 '
              'é só da TUE.',
          hint: 'Use I = P / V; em 1.500 W, o ponto separa os milhares.',
        ),
        _Template(
          prompt: 'pela NBR 5410, qual é a seção mínima do condutor de cobre '
              'do circuito 2, das TUGs da planta do quarto?',
          options: ['0,5 mm²', '1,5 mm²', '2,5 mm²', '4 mm²'],
          correctIndex: 2,
          explanation: 'Seções mínimas de cobre na NBR 5410: 1,5 mm² para '
              'iluminação, 2,5 mm² para circuitos de força (como os de '
              'tomadas) e 0,5 mm² para sinalização e controle. O circuito 2 '
              'é de tomadas: 2,5 mm².',
          hint: 'O mínimo depende da função do circuito: iluminação ou força.',
        ),
      ],
    ),
    'Luminotécnica': (
      slug: 'luminotecnica',
      visual: QuestionVisual.bedroomPlan,
      items: [
        _Template(
          prompt: 'o que representam os 160 VA anotados no ponto de luz da '
              'planta do quarto?',
          options: [
            'A potência exata da lâmpada a comprar',
            'O consumo mensal do ponto de luz',
            'A carga prevista para dimensionar o circuito',
            'O fluxo luminoso da lâmpada',
          ],
          correctIndex: 2,
          explanation: 'Pela NBR 5410, os 160 VA são a carga mínima de '
              'iluminação usada para dimensionar o circuito, não '
              'necessariamente a potência da lâmpada. Consumo se mede em kWh, '
              'e fluxo luminoso, em lúmens (lm).',
          hint: 'Observe a unidade: VA não mede energia nem luz.',
        ),
        _Template(
          prompt: 'para ter iluminância média de 150 lx em todo o piso do '
              'quarto da planta, quantos lúmens precisam chegar ao piso? '
              'Desconsidere perdas.',
          options: ['1.950 lm', '1.575 lm', '525 lm', '14,3 lm'],
          correctIndex: 1,
          explanation: 'Iluminância é fluxo por área: E = Φ / A. Então '
              'Φ = E × A = 150 × (3,50 × 3,00) = 150 × 10,50 = 1.575 lm.',
          hint: 'Lux é lúmen por metro quadrado.',
        ),
        _Template(
          prompt: 'a planta prevê 160 VA de iluminação para o quarto de '
              '10,50 m². Pelo mesmo critério de área da NBR 5410, a partir de '
              'que área a carga mínima subiria para 220 VA?',
          options: ['14,00 m²', '10,00 m²', '14,50 m²', '12,00 m²'],
          correctIndex: 0,
          explanation: '220 VA = 100 VA + 2 × 60 VA: são dois blocos de 4 m² '
              'inteiros além dos primeiros 6 m², ou seja, 6 + 2 × 4 = '
              '14,00 m². O quarto da planta, com 10,50 m², tem um só bloco.',
          hint: 'Descubra quantos acréscimos de 60 VA cabem em 220 VA e '
              'converta cada um em 4 m².',
        ),
      ],
    ),
    // Partida de motores não cabe na planta de um quarto, e nenhum desenho
    // atual mostra um comando; fica sem visual.
    'Comandos elétricos': (
      slug: 'comandos',
      visual: null,
      items: [
        _Template(
          prompt: 'na partida direta de um motor com o contator K1, qual '
              'contato mantém a bobina de K1 energizada depois que o botão '
              'liga é solto?',
          options: [
            'O contato NF do relé térmico',
            'Um contato auxiliar NA de K1, em paralelo com o botão liga',
            'Um contato principal de K1, em série com o motor',
            'O contato NF do botão desliga',
          ],
          correctIndex: 1,
          explanation: 'É o contato de selo (retenção): um auxiliar NA do '
              'próprio K1, em paralelo com o botão liga. Os NF do relé '
              'térmico e do botão desliga ficam em série para interromper o '
              'comando; os contatos principais estão no circuito de força.',
          hint: 'Pense no contato que faz o papel do botão depois que K1 '
              'fecha.',
        ),
        _Template(
          prompt: 'qual é a função do relé térmico (relé de sobrecarga) na '
              'partida de um motor?',
          options: [
            'Proteger contra curto-circuito',
            'Inverter o sentido de rotação',
            'Reduzir a corrente de partida',
            'Desligar o motor em sobrecarga prolongada',
          ],
          correctIndex: 3,
          explanation: 'O relé térmico atua quando a corrente fica acima do '
              'ajuste por tempo prolongado (sobrecarga) e abre o comando do '
              'contator. Curto-circuito é papel de fusíveis ou disjuntores.',
          hint: 'Ele aquece com a corrente e reage devagar.',
        ),
        _Template(
          prompt: 'na partida com reversão, para que serve o intertravamento '
              'entre os contatores K1 e K2?',
          options: [
            'Impedir que K1 e K2 liguem juntos, o que causaria curto entre '
                'fases',
            'Manter K1 ligado depois que o botão é solto',
            'Reduzir a corrente de partida do motor',
            'Proteger o motor contra sobrecarga',
          ],
          correctIndex: 0,
          explanation: 'Na reversão, K1 e K2 trocam duas fases do motor. Se '
              'ligassem juntos, haveria curto entre fases; por isso um '
              'contato NF de cada contator fica em série com a bobina do '
              'outro.',
          hint: 'Pense no que aconteceria se as duas sequências de fase '
              'fossem ligadas ao mesmo tempo.',
        ),
      ],
    ),
  };

  static Question _processControl(int sequence) => Question(
        id: 'generated-control-$sequence',
        topic: 'Supervisórios e controle de processos',
        prompt:
            'No laço de controle mostrado, qual componente decide a ação a partir da leitura do sensor?',
        options: const ['Tanque', 'Válvula', 'CLP', 'Sensor'],
        correctIndex: 2,
        explanation: 'O CLP processa a medição e envia o comando ao atuador.',
        hint: 'Busque o elemento entre a medição e o atuador.',
        visual: QuestionVisual.processControl,
      );
}

/// Questões de um assunto e o visual que todas compartilham.
typedef _InstallationUnit = ({
  String slug,
  QuestionVisual? visual,
  List<_Template> items,
});

/// Questão pronta, sem id: o gerador acrescenta o id e o assunto.
class _Template {
  const _Template({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.hint,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String hint;
}
