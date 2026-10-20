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

  static const List<Quiz> quizzes = [
    leiDeOhm,
    codigoDeCores,
    associacaoDeResistores,
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
      requiresTrailId: 'eletronica-digital',
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
      glyph: 'Ω',
    ),
    Medal(
      id: 'potencia-total',
      name: 'Potência Total',
      description: 'Concluiu o módulo de Potência e energia com 3 estrelas',
      glyph: 'W',
    ),
    Medal(
      id: 'streak-7',
      name: '7 dias seguidos',
      description: 'Estudou 7 dias sem interrupção',
      glyph: '7',
    ),
    Medal(
      id: 'mestre-cores',
      name: 'Olho de Resistor',
      description: 'Desafio de código de cores com 80% ou mais de acerto',
      glyph: 'R',
    ),
    Medal(
      id: 'rei-paralelo',
      name: 'Rei do Paralelo',
      description: 'Desafio de associação de resistores com 80% ou mais',
      glyph: '∥',
    ),
    Medal(
      id: 'streak-30',
      name: '30 dias seguidos',
      description: 'Estudou 30 dias sem interrupção',
      glyph: '30',
    ),
    Medal(
      id: 'primeira-trilha',
      name: 'Eletricista de Base',
      description: 'Concluiu a trilha de Eletricidade Básica',
      glyph: '★',
    ),
    Medal(
      id: 'kirchhoff',
      name: 'Kirchhoff',
      description: 'Concluiu o módulo de Leis de Kirchhoff',
      glyph: 'K',
    ),
    Medal(
      id: 'streak-100',
      name: '100 dias seguidos',
      description: 'Estudou 100 dias sem interrupção',
      glyph: '100',
    ),
  ];
}
