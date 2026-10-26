/// Conteúdo de exemplo da Eletroeletrônica (DEE) para o protótipo.
///
/// Estes dados só existem para a base funcionar sem servidor. No futuro,
/// o conteúdo virá do banco de questões cadastrado pelos professores.
library;

import '../../domain/models/content.dart';
import '../../domain/models/gamification.dart';

class SampleContent {
  SampleContent._();

  // ---------------------------------------------------------------------------
  // Desafios
  // ---------------------------------------------------------------------------

  static const Quiz leiDeOhm = Quiz(
    id: 'q-ohm',
    title: 'Lei de Ohm',
    topic: 'Lei de Ohm',
    rewardXp: 50,
    timeLimitSeconds: 120,
    badgeId: 'mestre-ohm',
    questions: [
      Question(
        id: 'ohm-1',
        topic: 'Lei de Ohm',
        prompt: 'Um resistor de 220 Ω é ligado a uma fonte de 12 V. '
            'Qual é a corrente aproximada no circuito?',
        options: ['2,64 A', '54,5 mA', '18,3 mA', '0,54 A'],
        correctIndex: 1,
        explanation: 'I = V / R = 12 / 220 ≈ 0,0545 A, ou seja, 54,5 mA.',
        hint: 'Use I = V / R e converta o resultado para mA.',
        visual: QuestionVisual.circuitSeries,
      ),
      Question(
        id: 'ohm-2',
        topic: 'Lei de Ohm',
        prompt: 'Um resistor é percorrido por 2 A quando submetido a 10 V. '
            'Qual é a sua resistência?',
        options: ['20 Ω', '0,2 Ω', '5 Ω', '12 Ω'],
        correctIndex: 2,
        explanation: 'R = V / I = 10 / 2 = 5 Ω.',
        hint: 'Isole R na equação V = R · I.',
      ),
      Question(
        id: 'ohm-3',
        topic: 'Lei de Ohm',
        prompt: 'Qual é a tensão sobre um resistor de 1 kΩ percorrido '
            'por uma corrente de 5 mA?',
        options: ['5 V', '0,5 V', '50 V', '200 V'],
        correctIndex: 0,
        explanation: 'V = R · I = 1000 × 0,005 = 5 V.',
      ),
      Question(
        id: 'ohm-4',
        topic: 'Lei de Ohm',
        prompt: 'Se a tensão aplicada a um resistor ôhmico dobra, '
            'o que acontece com a corrente?',
        options: [
          'Cai pela metade',
          'Não muda',
          'Quadruplica',
          'Dobra',
        ],
        correctIndex: 3,
        explanation: 'Num resistor ôhmico, R é constante: I = V / R. '
            'Dobrando V, a corrente também dobra.',
      ),
      Question(
        id: 'ohm-5',
        topic: 'Potência elétrica',
        prompt: 'Uma lâmpada de 60 W ligada em 127 V consome uma corrente '
            'de aproximadamente:',
        options: ['0,47 A', '2,1 A', '0,12 A', '7,6 A'],
        correctIndex: 0,
        explanation: 'P = V · I, então I = P / V = 60 / 127 ≈ 0,47 A.',
        hint: 'Relacione potência, tensão e corrente: P = V · I.',
      ),
    ],
  );

  static const Quiz codigoDeCores = Quiz(
    id: 'q-cores',
    title: 'Código de cores de resistores',
    topic: 'Código de cores',
    rewardXp: 80,
    timeLimitSeconds: 120,
    badgeId: 'mestre-cores',
    questions: [
      Question(
        id: 'cores-1',
        topic: 'Código de cores',
        prompt: 'Faixas marrom, preto e vermelho (seguidas de dourado). '
            'Qual é o valor do resistor?',
        options: ['100 Ω', '1 kΩ', '10 kΩ', '102 Ω'],
        correctIndex: 1,
        explanation: 'Marrom = 1, preto = 0, vermelho = ×100: '
            '10 × 100 = 1000 Ω = 1 kΩ.',
        hint: 'A terceira faixa é o multiplicador.',
        visual: QuestionVisual.resistorBands,
      ),
      Question(
        id: 'cores-2',
        topic: 'Código de cores',
        prompt: 'Faixas vermelho, vermelho e marrom. Qual é o valor?',
        options: ['220 Ω', '22 Ω', '2,2 kΩ', '221 Ω'],
        correctIndex: 0,
        explanation:
            'Vermelho = 2, vermelho = 2, marrom = ×10: 22 × 10 = 220 Ω.',
      ),
      Question(
        id: 'cores-3',
        topic: 'Código de cores',
        prompt: 'Faixas amarelo, violeta e laranja. Qual é o valor?',
        options: ['4,7 kΩ', '470 Ω', '473 Ω', '47 kΩ'],
        correctIndex: 3,
        explanation: 'Amarelo = 4, violeta = 7, laranja = ×1000: '
            '47 × 1000 = 47 kΩ.',
      ),
      Question(
        id: 'cores-4',
        topic: 'Código de cores',
        prompt: 'Uma faixa dourada na posição de tolerância indica:',
        options: ['±1%', '±10%', '±5%', '±20%'],
        correctIndex: 2,
        explanation: 'Dourado na faixa de tolerância = ±5%; prateado = ±10%.',
      ),
      Question(
        id: 'cores-5',
        topic: 'Código de cores',
        prompt: 'Qual cor representa o dígito 5?',
        options: ['Azul', 'Verde', 'Amarelo', 'Laranja'],
        correctIndex: 1,
        explanation: 'Sequência: preto 0, marrom 1, vermelho 2, laranja 3, '
            'amarelo 4, verde 5, azul 6, violeta 7, cinza 8, branco 9.',
      ),
    ],
  );

  static const Quiz associacaoDeResistores = Quiz(
    id: 'q-assoc',
    title: 'Associação de resistores',
    topic: 'Associação de resistores',
    rewardXp: 40,
    badgeId: 'rei-paralelo',
    questions: [
      Question(
        id: 'assoc-1',
        topic: 'Associação em série',
        prompt: 'Dois resistores de 100 Ω ligados em série têm resistência '
            'equivalente de:',
        options: ['50 Ω', '200 Ω', '100 Ω', '10 kΩ'],
        correctIndex: 1,
        explanation: 'Em série, as resistências se somam: 100 + 100 = 200 Ω.',
      ),
      Question(
        id: 'assoc-2',
        topic: 'Associação em paralelo',
        prompt: 'Dois resistores de 100 Ω ligados em paralelo têm resistência '
            'equivalente de:',
        options: ['200 Ω', '100 Ω', '50 Ω', '25 Ω'],
        correctIndex: 2,
        explanation:
            'Em paralelo, somam-se os inversos: 1/Req = 1/100 + 1/100, '
            'então Req = 50 Ω.',
        hint: 'Resistores iguais em paralelo: divida o valor pela quantidade.',
        visual: QuestionVisual.circuitParallel,
      ),
      Question(
        id: 'assoc-3',
        topic: 'Associação em paralelo',
        prompt: 'Resistores de 6 Ω e 3 Ω em paralelo resultam em:',
        options: ['2 Ω', '9 Ω', '4,5 Ω', '18 Ω'],
        correctIndex: 0,
        explanation: 'Req = (6 × 3) / (6 + 3) = 18 / 9 = 2 Ω.',
        hint: 'Para dois resistores: produto dividido pela soma.',
      ),
      Question(
        id: 'assoc-4',
        topic: 'Associação em série',
        prompt: 'Numa associação em série, a corrente elétrica:',
        options: [
          'Divide-se entre os resistores',
          'É maior no resistor de menor valor',
          'É a mesma em todos os resistores',
          'É nula no último resistor',
        ],
        correctIndex: 2,
        explanation: 'Em série há um único caminho: a mesma corrente '
            'atravessa todos os resistores.',
      ),
    ],
  );

  /// Lido sobre [QuestionVisual.bedroomPlan]: quarto de 3,50 m × 3,00 m,
  /// ponto de luz de 160 VA (circuito 1, comando "a"), interruptor "a",
  /// 3 TUGs de 100 VA (circuito 2) e TUE de 1.500 W do ar-condicionado
  /// (circuito 3). A tensão não está no desenho; quem precisa dela a informa.
  static const Quiz plantaDoQuarto = Quiz(
    id: 'q-planta-quarto',
    title: 'Planta elétrica do quarto',
    topic: 'Instalações elétricas',
    rewardXp: 50,
    // Sem cronômetro: ler a planta toma mais tempo que uma conta direta.
    questions: [
      Question(
        id: 'planta-1',
        topic: 'Instalações elétricas',
        prompt: 'Pela planta, quantos circuitos terminais atendem o quarto?',
        options: ['1 circuito', '2 circuitos', '3 circuitos', '4 circuitos'],
        correctIndex: 2,
        explanation: 'Cada ponto traz o número do seu circuito: 1 (ponto de '
            'luz e interruptor "a"), 2 (as três TUGs) e 3 (a TUE do '
            'ar-condicionado). São 3 circuitos.',
        hint: 'Conte os números de circuito diferentes, não a quantidade '
            'de pontos.',
        visual: QuestionVisual.bedroomPlan,
      ),
      Question(
        id: 'planta-2',
        topic: 'Instalações elétricas',
        prompt: 'O ponto de luz do teto e o interruptor ao lado da porta '
            'têm a mesma letra "a". O que ela indica?',
        options: [
          'Que o interruptor "a" acende e apaga o ponto de luz "a"',
          'O número do circuito que alimenta os dois pontos',
          'A potência do ponto de luz, em VA',
          'Que o interruptor é do tipo paralelo (three-way)',
        ],
        correctIndex: 0,
        explanation: 'Na planta, a letra minúscula liga o comando à carga: o '
            'interruptor "a" comanda o ponto de luz "a". O circuito vem em '
            'número (aqui, 1) e a potência, em VA (160 VA).',
        hint: 'Na planta, letras e números têm papéis diferentes: um indica '
            'o circuito; o outro, o comando.',
        visual: QuestionVisual.bedroomPlan,
      ),
      Question(
        id: 'planta-3',
        topic: 'Instalações elétricas',
        prompt: 'A planta prevê 160 VA de iluminação para o quarto de '
            '3,50 m × 3,00 m. Pelo critério de área da NBR 5410, esse é o '
            'mínimo correto?',
        options: [
          'Não: os 4,50 m² além dos 6 m² contam como 2 blocos de 4 m², '
              'então 220 VA',
          'Sim: 100 VA pelos primeiros 6 m² e 60 VA pelo único bloco de '
              '4 m² inteiro',
          'Não: o acréscimo é proporcional, 100 + 60 × 4,50 / 4 = 167,5 VA',
          'Sim: a norma fixa 160 VA para qualquer dormitório',
        ],
        correctIndex: 1,
        explanation: 'Área = 3,50 × 3,00 = 10,50 m². Os primeiros 6 m² valem '
            '100 VA; sobram 4,50 m², com um só bloco de 4 m² inteiro '
            '(+60 VA). Total: 160 VA.',
        hint: 'Calcule a área e conte só os blocos de 4 m² completos depois '
            'dos primeiros 6 m².',
        visual: QuestionVisual.bedroomPlan,
      ),
      Question(
        id: 'planta-4',
        topic: 'Instalações elétricas',
        prompt: 'Pela NBR 5410, qual conta dá o número mínimo de TUGs do '
            'dormitório da planta?',
        options: [
          'Área: 10,50 m² ÷ 5 = 2,1 → 3 TUGs',
          'Perímetro: 13,00 m ÷ 5 m = 2,6 → 2 TUGs',
          'Perímetro: 13,00 m ÷ 3,5 m = 3,7 → 4 TUGs',
          'Perímetro: 13,00 m ÷ 5 m = 2,6 → 3 TUGs',
        ],
        correctIndex: 3,
        explanation: 'Em dormitórios, a NBR 5410 pede 1 ponto de tomada a '
            'cada 5 m, ou fração, de perímetro. Perímetro = 2 × (3,50 + '
            '3,00) = 13,00 m; 13,00 ÷ 5 = 2,6, e a fração conta: 3 TUGs.',
        hint: 'Em dormitórios, a regra das TUGs usa o contorno do cômodo, '
            'não a área.',
        visual: QuestionVisual.bedroomPlan,
      ),
      Question(
        id: 'planta-5',
        topic: 'Instalações elétricas',
        prompt: 'Considere 127 V e fator de potência 1. Por que a TUE do '
            'ar-condicionado (1.500 W) tem o circuito 3 só para ela?',
        options: [
          'Toda tomada alta precisa de circuito próprio',
          'O circuito 2 já tem 3 TUGs, o máximo de tomadas por circuito',
          'Corrente de cerca de 11,8 A, acima de 10 A: a NBR 5410 pede '
              'circuito independente',
          'Corrente de cerca de 0,08 A, baixa demais para dividir circuito',
        ],
        correctIndex: 2,
        explanation: 'I = P / V = 1.500 / 127 ≈ 11,8 A. Pela NBR 5410, '
            'equipamento com corrente nominal acima de 10 A tem circuito '
            'independente. A altura da tomada não decide isso, e a norma não '
            'fixa um máximo de tomadas por circuito.',
        hint: 'Calcule a corrente do ar-condicionado com P = V · I.',
        visual: QuestionVisual.bedroomPlan,
      ),
    ],
  );

  static const List<Quiz> quizzes = [
    leiDeOhm,
    codigoDeCores,
    associacaoDeResistores,
    plantaDoQuarto,
  ];

  // ---------------------------------------------------------------------------
  // Trilhas
  // ---------------------------------------------------------------------------

  static const List<Trail> trails = [
    Trail(
      id: 'eletricidade-basica',
      title: 'Eletricidade Básica',
      modules: [
        TrailModule(
          id: 'eb-1',
          order: 1,
          title: 'Grandezas elétricas',
          subtitle: 'Tensão, corrente e resistência',
          status: ModuleStatus.done,
          stars: 3,
        ),
        TrailModule(
          id: 'eb-2',
          order: 2,
          title: 'Lei de Ohm',
          subtitle: 'V = R · I na prática',
          status: ModuleStatus.done,
          stars: 2,
          quizId: 'q-ohm',
        ),
        TrailModule(
          id: 'eb-3',
          order: 3,
          title: 'Potência e energia',
          subtitle: 'Watts, kWh e consumo',
          status: ModuleStatus.done,
          stars: 3,
        ),
        TrailModule(
          id: 'eb-4',
          order: 4,
          title: 'Associação de resistores',
          subtitle: 'Série, paralelo e misto',
          status: ModuleStatus.current,
          lessonsDone: 2,
          lessonsTotal: 4,
          quizId: 'q-assoc',
        ),
        TrailModule(
          id: 'eb-5',
          order: 5,
          title: 'Leis de Kirchhoff',
          subtitle: 'Malhas e nós',
          status: ModuleStatus.locked,
        ),
        TrailModule(
          id: 'eb-6',
          order: 6,
          title: 'Divisores de tensão e corrente',
          subtitle: 'Aplicações em circuitos',
          status: ModuleStatus.locked,
        ),
        TrailModule(
          id: 'eb-final',
          order: 7,
          title: 'Prova final da trilha',
          subtitle: 'Vale a medalha "Eletricista de Base" · +300 XP',
          status: ModuleStatus.locked,
          isFinalExam: true,
        ),
      ],
    ),
    Trail(
      id: 'eletronica-analogica',
      title: 'Eletrônica Analógica',
      modules: [
        TrailModule(
          id: 'ea-1',
          order: 1,
          title: 'Semicondutores',
          subtitle: 'Materiais tipo P e N',
          status: ModuleStatus.current,
          lessonsDone: 1,
          lessonsTotal: 3,
        ),
        TrailModule(
          id: 'ea-2',
          order: 2,
          title: 'Diodos',
          subtitle: 'Retificação e polarização',
          status: ModuleStatus.locked,
        ),
        TrailModule(
          id: 'ea-3',
          order: 3,
          title: 'Transistores',
          subtitle: 'Chave e amplificador',
          status: ModuleStatus.locked,
        ),
      ],
    ),
    Trail(
      id: 'instalacoes-eletricas',
      title: 'Instalações Elétricas',
      modules: [
        TrailModule(
          id: 'ie-1',
          order: 1,
          title: 'Simbologia e diagramas',
          subtitle: 'Planta baixa e unifilar',
          status: ModuleStatus.current,
          lessonsTotal: 3,
          quizId: 'q-planta-quarto',
        ),
        TrailModule(
          id: 'ie-2',
          order: 2,
          title: 'Dimensionamento de condutores',
          subtitle: 'Seção, queda de tensão e proteção',
          status: ModuleStatus.locked,
        ),
      ],
    ),
    Trail(
      id: 'clp-automacao',
      title: 'CLP e Automação',
      unlocked: false,
      requiresTrailId: 'eletricidade-basica',
      modules: [
        TrailModule(
          id: 'clp-1',
          order: 1,
          title: 'Lógica Ladder',
          subtitle: 'Contatos, bobinas e selos',
          status: ModuleStatus.locked,
        ),
      ],
    ),
  ];

  // ---------------------------------------------------------------------------
  // Missões e medalhas
  // ---------------------------------------------------------------------------

  static const List<Mission> dailyMissions = [
    Mission(
      id: 'm-ohm',
      title: 'Resolver 5 questões de Lei de Ohm',
      rewardXp: 50,
      progress: 3,
      goal: 5,
      quizId: 'q-ohm',
    ),
    Mission(
      id: 'm-video',
      title: 'Videoaula: circuitos em série',
      rewardXp: 30,
      progress: 1,
      goal: 1,
    ),
    Mission(
      id: 'm-cores',
      title: 'Código de cores de resistores',
      rewardXp: 80,
      progress: 0,
      goal: 1,
      quizId: 'q-cores',
      isFlash: true,
    ),
  ];

  static const List<Medal> medals = [
    Medal(
      id: 'mestre-ohm',
      name: 'Mestre de Ohm',
      description: 'Desafio de Lei de Ohm com 80% ou mais de acerto',
      icon: MedalIcon.ohm,
    ),
    Medal(
      id: 'potencia-total',
      name: 'Potência Total',
      description: 'Módulo de Potência e energia com 3 estrelas',
      icon: MedalIcon.bolt,
    ),
    Medal(
      id: 'streak-7',
      name: '7 dias seguidos',
      description: '7 dias seguidos de estudo',
      icon: MedalIcon.streak,
      iconLabel: '7',
    ),
    Medal(
      id: 'mestre-cores',
      name: 'Olho de Resistor',
      description: 'Desafio de código de cores com 80% ou mais de acerto',
      icon: MedalIcon.resistor,
    ),
    Medal(
      id: 'rei-paralelo',
      name: 'Rei do Paralelo',
      description: 'Desafio de associação de resistores com 80% ou mais',
      icon: MedalIcon.parallel,
    ),
    Medal(
      id: 'streak-30',
      name: '30 dias seguidos',
      description: '30 dias seguidos de estudo',
      icon: MedalIcon.streak,
      iconLabel: '30',
    ),
    Medal(
      id: 'primeira-trilha',
      name: 'Eletricista de Base',
      description: 'Trilha de Eletricidade Básica concluída',
      icon: MedalIcon.electrician,
    ),
    Medal(
      id: 'kirchhoff',
      name: 'Kirchhoff',
      description: 'Módulo de Leis de Kirchhoff concluído',
      icon: MedalIcon.kirchhoff,
    ),
    Medal(
      id: 'streak-100',
      name: '100 dias seguidos',
      description: '100 dias seguidos de estudo',
      icon: MedalIcon.streak,
      iconLabel: '100',
    ),
  ];
}
