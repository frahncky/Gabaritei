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
          QuestionVisual.circuitSeries,
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
          QuestionVisual.circuitSeries,
        ),
      'Eletrônica digital' => _concept(
          sequence,
          topic,
          'Qual é a saída de uma porta AND quando suas duas entradas são nível lógico 1?',
          const ['0', '1', 'Alta impedância', 'Indefinida'],
          1,
          'A porta AND produz 1 somente quando todas as entradas são 1.',
          'Consulte a tabela-verdade da porta AND.',
          QuestionVisual.processControl,
        ),
      'Eletrônica de potência' => _concept(
          sequence,
          topic,
          'Qual dispositivo é frequentemente usado para controlar potência em cargas CA?',
          const ['TRIAC', 'LED', 'Amplificador operacional', 'Relé térmico'],
          0,
          'O TRIAC conduz nos dois semiciclos e é usado no controle de potência CA.',
          'Pense em um semicondutor bidirecional.',
          QuestionVisual.circuitSeries,
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
          QuestionVisual.circuitSeries,
        ),
      'Instalações elétricas' => _electricalPlan(sequence),
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
          QuestionVisual.processControl,
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
          QuestionVisual.processControl,
        ),
      'Programação' => _concept(
          sequence,
          topic,
          'Qual estrutura repete um bloco enquanto uma condição permanece verdadeira?',
          const ['Laço while', 'Constante', 'Comentário', 'Importação'],
          0,
          'O laço while avalia a condição antes de cada repetição.',
          'Procure uma estrutura de repetição condicional.',
          QuestionVisual.processControl,
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

  static QuestionVisual _visualFor(String discipline) {
    if (discipline == 'Instalações elétricas' ||
        discipline == 'Desenho técnico e CAD' ||
        discipline == 'Segurança e normas') {
      return QuestionVisual.electricalPlan;
    }
    if (discipline == 'CLP' ||
        discipline == 'Robótica' ||
        discipline == 'Supervisórios e controle de processos' ||
        discipline == 'Redes industriais' ||
        discipline == 'Pneumática e hidráulica' ||
        discipline == 'Programação') {
      return QuestionVisual.processControl;
    }
    if (discipline == 'Eletrônica analógica') {
      return QuestionVisual.resistorBands;
    }
    return QuestionVisual.circuitSeries;
  }

  static Question _concept(
    int sequence,
    String topic,
    String prompt,
    List<String> options,
    int correctIndex,
    String explanation,
    String hint,
    QuestionVisual visual,
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
      topic: 'Eletricidade básica',
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
        topic: 'Circuitos CC',
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
