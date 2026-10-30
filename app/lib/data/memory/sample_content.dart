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
        visual: QuestionVisual.electricalPlan,
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
        visual: QuestionVisual.processControl,
      ),
    ],
  );

  /// Atividades iniciais por módulo, sem progresso fictício.
  static const List<Quiz> lessons = [
    leiDeOhm,
    codigoDeCores,
    associacaoDeResistores,
    Quiz(id: 'q-eb-1', title: 'Grandezas elétricas', topic: 'Eletricidade Básica', rewardXp: 30, questions: [
      Question(id: 'eb-1-q1', topic: 'Grandezas elétricas', prompt: 'Qual grandeza é medida em ampères?', options: ['Corrente elétrica', 'Tensão elétrica', 'Resistência elétrica', 'Energia elétrica'], correctIndex: 0, explanation: 'O ampère (A) é a unidade de corrente elétrica.'),
      Question(id: 'eb-1-q2', topic: 'Grandezas elétricas', prompt: 'Uma resistência de 2 kΩ equivale a:', options: ['2 Ω', '200 Ω', '2000 Ω', '20000 Ω'], correctIndex: 2, explanation: 'O prefixo quilo representa mil: 2 kΩ = 2000 Ω.'),
    ]),
    Quiz(id: 'q-eb-3', badgeId: 'potencia-total', title: 'Potência e energia', topic: 'Eletricidade Básica', rewardXp: 30, questions: [
      Question(id: 'eb-3-q1', topic: 'Potência e energia', prompt: 'Uma carga resistiva recebe 12 V e conduz 2 A. Qual é a potência?', options: ['6 W', '14 W', '24 W', '144 W'], correctIndex: 2, explanation: 'P = V × I = 12 × 2 = 24 W.'),
      Question(id: 'eb-3-q2', topic: 'Potência e energia', prompt: 'Um aparelho de 1000 W funciona por 2 h. Qual energia consome?', options: ['0,5 kWh', '2 kWh', '2000 kWh', '1002 kWh'], correctIndex: 1, explanation: '1000 W = 1 kW; E = P × t = 1 × 2 = 2 kWh.'),
    ]),
    Quiz(id: 'q-eb-5', badgeId: 'kirchhoff', title: 'Leis de Kirchhoff', topic: 'Eletricidade Básica', rewardXp: 30, questions: [
      Question(id: 'eb-5-q1', topic: 'Leis de Kirchhoff', prompt: 'Em um nó entram 5 A e saem 2 A por um ramo. Quanto sai pelo outro?', options: ['7 A', '10 A', '2,5 A', '3 A'], correctIndex: 3, explanation: 'A soma das correntes que entram é igual à das que saem: 5 − 2 = 3 A.'),
      Question(id: 'eb-5-q2', topic: 'Leis de Kirchhoff', prompt: 'Uma fonte de 12 V alimenta duas quedas de tensão em série. Se uma é 5 V, qual é a outra?', options: ['7 V', '17 V', '60 V', '2,4 V'], correctIndex: 0, explanation: 'Pela lei das malhas, 12 − 5 − V = 0; logo V = 7 V.'),
    ]),
    Quiz(id: 'q-eb-6', title: 'Divisores de tensão e corrente', topic: 'Eletricidade Básica', rewardXp: 30, questions: [
      Question(id: 'eb-6-q1', topic: 'Divisores de tensão e corrente', prompt: 'Dois resistores de 1 kΩ em série recebem 10 V. Qual a tensão em cada um?', options: ['10 V', '5 V', '1 V', '20 V'], correctIndex: 1, explanation: 'Resistores iguais em série dividem igualmente a tensão: 10/2 = 5 V.'),
      Question(id: 'eb-6-q2', topic: 'Divisores de tensão e corrente', prompt: 'Uma corrente total de 6 A se divide entre dois resistores iguais em paralelo. Qual a corrente por resistor?', options: ['12 A', '6 A', '3 A', '1 A'], correctIndex: 2, explanation: 'Ramos com resistências iguais têm correntes iguais: 6/2 = 3 A.'),
    ]),
    Quiz(id: 'q-ea-1', title: 'Semicondutores', topic: 'Eletrônica Analógica', rewardXp: 30, questions: [
      Question(id: 'ea-1-q1', topic: 'Semicondutores', prompt: 'Em um semicondutor tipo N, os portadores majoritários são:', options: ['Lacunas', 'Prótons', 'Nêutrons', 'Elétrons'], correctIndex: 3, explanation: 'A dopagem do tipo N disponibiliza elétrons como portadores majoritários.'),
      Question(id: 'ea-1-q2', topic: 'Semicondutores', prompt: 'Em um semicondutor tipo P, os portadores majoritários são:', options: ['Lacunas', 'Elétrons', 'Fótons', 'Íons livres'], correctIndex: 0, explanation: 'No material tipo P, as lacunas são os portadores majoritários.'),
    ]),
    Quiz(id: 'q-ea-2', title: 'Diodos e retificadores', topic: 'Eletrônica Analógica', rewardXp: 30, questions: [
      Question(id: 'ea-2-q1', topic: 'Diodos e retificadores', prompt: 'Um diodo ideal diretamente polarizado se comporta como:', options: ['Circuito aberto', 'Curto-circuito', 'Capacitor', 'Fonte de corrente'], correctIndex: 1, explanation: 'No modelo ideal, o diodo conduz sem queda de tensão em polarização direta.'),
      Question(id: 'ea-2-q2', topic: 'Diodos e retificadores', prompt: 'Uma ponte retificadora monofásica convencional utiliza quantos diodos?', options: ['1', '2', '4', '6'], correctIndex: 2, explanation: 'A ponte monofásica de onda completa utiliza quatro diodos, dois conduzindo em cada semiciclo.'),
    ]),
    Quiz(id: 'q-ea-3', title: 'Transistores', topic: 'Eletrônica Analógica', rewardXp: 30, questions: [
      Question(id: 'ea-3-q1', topic: 'Transistores', prompt: 'Em um BJT, quais são os três terminais?', options: ['Dreno, porta e fonte', 'Ânodo, cátodo e porta', 'Fase, neutro e terra', 'Base, coletor e emissor'], correctIndex: 3, explanation: 'Os terminais do transistor bipolar são base, coletor e emissor.'),
      Question(id: 'ea-3-q2', topic: 'Transistores', prompt: 'Em um MOSFET ideal em regime estático, a corrente na porta é aproximadamente:', options: ['Zero', 'Igual à corrente do dreno', 'Infinita', 'Sempre 1 A'], correctIndex: 0, explanation: 'A porta é isolada; o modelo ideal não apresenta corrente estática de porta.'),
    ]),
    Quiz(id: 'q-ea-4', title: 'Amplificadores operacionais', topic: 'Eletrônica Analógica', rewardXp: 30, questions: [
      Question(id: 'ea-4-q1', topic: 'Amplificadores operacionais', prompt: 'Um amplificador inversor ideal usa Rin = 10 kΩ e Rf = 20 kΩ. Qual é o ganho?', options: ['2', '−2', '0,5', '−0,5'], correctIndex: 1, explanation: 'O ganho inversor é −Rf/Rin = −20/10 = −2.'),
      Question(id: 'ea-4-q2', topic: 'Amplificadores operacionais', prompt: 'Um seguidor de tensão ideal tem ganho de tensão igual a:', options: ['0', '−1', '1', 'Infinito'], correctIndex: 2, explanation: 'O seguidor realimenta a saída à entrada inversora, obtendo ganho unitário.'),
    ]),
    Quiz(id: 'q-ea-5', title: 'Filtros RC', topic: 'Eletrônica Analógica', rewardXp: 30, questions: [
      Question(id: 'ea-5-q1', topic: 'Filtros RC', prompt: 'Em um filtro RC passa-baixas, com saída no capacitor, frequências muito altas são:', options: ['Amplificadas sem limite', 'Convertidas em CC', 'Mantidas sem atenuação', 'Atenuadas'], correctIndex: 3, explanation: 'A reatância capacitiva diminui com a frequência, reduzindo a tensão de saída no capacitor.'),
      Question(id: 'ea-5-q2', topic: 'Filtros RC', prompt: 'Qual é a frequência de corte de um filtro RC de primeira ordem?', options: ['1/(2πRC)', '2πRC', 'R/C', 'RC'], correctIndex: 0, explanation: 'Na frequência de corte, o módulo da reatância capacitiva é igual a R: fc = 1/(2πRC).'),
    ]),
    Quiz(id: 'q-ed-1', title: 'Sistemas de numeração', topic: 'Eletrônica Digital', rewardXp: 30, questions: [
      Question(id: 'ed-1-q1', topic: 'Sistemas de numeração', prompt: 'O número binário 1010 corresponde a qual decimal?', options: ['8', '10', '12', '14'], correctIndex: 1, explanation: '1010₂ = 8 + 2 = 10₁₀.'),
      Question(id: 'ed-1-q2', topic: 'Sistemas de numeração', prompt: 'O algarismo hexadecimal F representa qual valor decimal?', options: ['10', '14', '15', '16'], correctIndex: 2, explanation: 'A sequência hexadecimal usa A = 10 até F = 15.'),
    ]),
    Quiz(id: 'q-ed-2', title: 'Portas lógicas', topic: 'Eletrônica Digital', rewardXp: 30, questions: [
      Question(id: 'ed-2-q1', topic: 'Portas lógicas', prompt: 'Uma porta AND com entradas 1 e 0 produz:', options: ['1', 'Alta impedância', 'Indefinido', '0'], correctIndex: 3, explanation: 'A porta AND só produz 1 quando todas as entradas são 1.'),
      Question(id: 'ed-2-q2', topic: 'Portas lógicas', prompt: 'Uma porta XOR com entradas 1 e 1 produz:', options: ['0', '1', '2', 'Alta impedância'], correctIndex: 0, explanation: 'A XOR de duas entradas vale 1 quando as entradas são diferentes; com 1 e 1, vale 0.'),
    ]),
    Quiz(id: 'q-ed-3', title: 'Lógica combinacional', topic: 'Eletrônica Digital', rewardXp: 30, questions: [
      Question(id: 'ed-3-q1', topic: 'Lógica combinacional', prompt: 'Pela lei de De Morgan, NÃO(A E B) equivale a:', options: ['NÃO A E NÃO B', 'NÃO A OU NÃO B', 'A OU B', 'A E NÃO B'], correctIndex: 1, explanation: 'A negação de uma conjunção equivale à disjunção das negações.'),
      Question(id: 'ed-3-q2', topic: 'Lógica combinacional', prompt: 'Um multiplexador 4 para 1 necessita de quantas linhas de seleção?', options: ['1', '4', '2', '8'], correctIndex: 2, explanation: 'Duas linhas permitem 2² = 4 combinações, uma para cada entrada.'),
    ]),
    Quiz(id: 'q-ed-4', title: 'Lógica sequencial', topic: 'Eletrônica Digital', rewardXp: 30, questions: [
      Question(id: 'ed-4-q1', topic: 'Lógica sequencial', prompt: 'Um flip-flop armazena normalmente:', options: ['Um byte', 'Uma palavra de 16 bits', 'Dez bits', 'Um bit'], correctIndex: 3, explanation: 'Um flip-flop possui dois estados estáveis e armazena um bit.'),
      Question(id: 'ed-4-q2', topic: 'Lógica sequencial', prompt: 'Quantos estados distintos pode ter um contador binário de 3 bits?', options: ['8', '3', '6', '9'], correctIndex: 0, explanation: 'Um contador de n bits possui até 2ⁿ estados; 2³ = 8.'),
    ]),
    Quiz(id: 'q-ie-1', title: 'Simbologia e diagramas', topic: 'Instalações Elétricas', rewardXp: 30, questions: [
      Question(id: 'ie-1-q1', topic: 'Simbologia e diagramas', prompt: 'Qual é a finalidade principal de um diagrama unifilar?', options: ['Mostrar somente cores de paredes', 'Representar de forma simplificada os circuitos elétricos', 'Medir corrente diretamente', 'Substituir todos os cálculos de projeto'], correctIndex: 1, explanation: 'O unifilar simplifica a representação de circuitos e seus componentes.'),
      Question(id: 'ie-1-q2', topic: 'Simbologia e diagramas', prompt: 'Em uma planta elétrica, a legenda serve para:', options: ['Definir apenas a escala', 'Eliminar os circuitos', 'Identificar os símbolos utilizados', 'Indicar o consumo mensal medido'], correctIndex: 2, explanation: 'A legenda associa símbolos aos elementos representados na planta.'),
    ]),
    Quiz(id: 'q-ie-2', title: 'Dimensionamento de condutores', topic: 'Instalações Elétricas', rewardXp: 30, questions: [
      Question(id: 'ie-2-q1', topic: 'Dimensionamento de condutores', prompt: 'Para mesmo material e comprimento, aumentar a seção de um condutor faz sua resistência:', options: ['Aumentar', 'Permanecer sempre igual', 'Tornar-se negativa', 'Diminuir'], correctIndex: 3, explanation: 'R = ρL/A: aumentando a área A, a resistência diminui.'),
      Question(id: 'ie-2-q2', topic: 'Dimensionamento de condutores', prompt: 'Uma corrente de 10 A percorre um circuito cuja resistência total dos condutores é 0,5 Ω. Qual é a queda de tensão?', options: ['5 V', '20 V', '0,05 V', '50 V'], correctIndex: 0, explanation: 'A queda é ΔV = R × I = 0,5 × 10 = 5 V; a resistência informada já inclui todo o percurso.'),
    ]),
    Quiz(id: 'q-ie-3', title: 'Proteção elétrica', topic: 'Instalações Elétricas', rewardXp: 30, questions: [
      Question(id: 'ie-3-q1', topic: 'Proteção elétrica', prompt: 'Um fusível é destinado principalmente a interromper:', options: ['Baixa luminosidade', 'Sobrecorrentes', 'Ruído acústico', 'Falta de conexão com a internet'], correctIndex: 1, explanation: 'O fusível interrompe o circuito quando a corrente e sua duração provocam a fusão do elemento.'),
      Question(id: 'ie-3-q2', topic: 'Proteção elétrica', prompt: 'Um dispositivo diferencial residual identifica principalmente:', options: ['A temperatura ambiente', 'A potência mecânica', 'Desequilíbrio entre correntes de ida e retorno', 'A frequência de rotação'], correctIndex: 2, explanation: 'O dispositivo compara as correntes; uma diferença pode indicar corrente de fuga.'),
    ]),
    Quiz(id: 'q-ie-4', title: 'Comandos elétricos', topic: 'Instalações Elétricas', rewardXp: 30, questions: [
      Question(id: 'ie-4-q1', topic: 'Comandos elétricos', prompt: 'Em um circuito de selo convencional, o contato auxiliar de retenção é ligado:', options: ['Em série com a alimentação geral', 'No lugar da proteção', 'Diretamente entre fases', 'Em paralelo ao botão de partida'], correctIndex: 3, explanation: 'O contato auxiliar mantém a bobina energizada após soltar o botão de partida.'),
      Question(id: 'ie-4-q2', topic: 'Comandos elétricos', prompt: 'O intertravamento entre contatores de reversão busca impedir:', options: ['Acionamento simultâneo dos contatores opostos', 'Parada pelo botão de desligamento', 'Atuação da proteção', 'Leitura do estado das bobinas'], correctIndex: 0, explanation: 'O intertravamento impede comandos simultâneos incompatíveis, que podem provocar curto-circuito.'),
    ]),
    Quiz(id: 'q-clp-1', title: 'Lógica Ladder', topic: 'CLP e Automação', rewardXp: 30, questions: [
      Question(id: 'clp-1-q1', topic: 'Lógica Ladder', prompt: 'Em Ladder, dois contatos em série representam qual operação lógica?', options: ['OU', 'E', 'NÃO', 'XOR'], correctIndex: 1, explanation: 'A continuidade lógica exige que as duas condições sejam verdadeiras, correspondendo à operação E.'),
      Question(id: 'clp-1-q2', topic: 'Lógica Ladder', prompt: 'Dois contatos em paralelo representam qual operação lógica?', options: ['E', 'NÃO', 'OU', 'Contagem'], correctIndex: 2, explanation: 'A continuidade ocorre se pelo menos um dos caminhos estiver verdadeiro: operação OU.'),
    ]),
    Quiz(id: 'q-clp-2', title: 'Ciclo de varredura', topic: 'CLP e Automação', rewardXp: 30, questions: [
      Question(id: 'clp-2-q1', topic: 'Ciclo de varredura', prompt: 'Qual sequência descreve o ciclo básico de um CLP?', options: ['Atualiza saídas, desliga CPU, lê entradas', 'Executa programa, apaga memória, reinicia', 'Lê saídas, remove programa, lê entradas', 'Lê entradas, executa programa, atualiza saídas'], correctIndex: 3, explanation: 'O ciclo básico considera leitura de entradas, execução da lógica e atualização das saídas.'),
      Question(id: 'clp-2-q2', topic: 'Ciclo de varredura', prompt: 'Uma entrada digital representa tipicamente:', options: ['Dois estados lógicos', 'Qualquer valor real sem limite', 'Apenas temperatura', 'Sempre uma tensão negativa'], correctIndex: 0, explanation: 'Entradas digitais representam estados discretos como ligado/desligado.'),
    ]),
    Quiz(id: 'q-clp-3', title: 'Temporizadores e contadores', topic: 'CLP e Automação', rewardXp: 30, questions: [
      Question(id: 'clp-3-q1', topic: 'Temporizadores e contadores', prompt: 'Um temporizador TON é normalmente usado para:', options: ['Gerar tensão analógica', 'Retardar a ativação após a condição de entrada', 'Armazenar um programa externo', 'Medir resistência diretamente'], correctIndex: 1, explanation: 'O TON ativa sua saída após a entrada permanecer verdadeira pelo tempo configurado.'),
      Question(id: 'clp-3-q2', topic: 'Temporizadores e contadores', prompt: 'Um contador crescente deve incrementar normalmente a cada:', options: ['Varredura, mesmo sem evento', 'Segundo obrigatório', 'Evento de contagem, como uma borda de subida', 'Mudança de cor na IHM'], correctIndex: 2, explanation: 'Contadores de eventos incrementam na transição configurada da entrada, evitando contar continuamente um sinal mantido.'),
    ]),
    Quiz(id: 'q-clp-4', title: 'Sinais analógicos', topic: 'CLP e Automação', rewardXp: 30, questions: [
      Question(id: 'clp-4-q1', topic: 'Sinais analógicos', prompt: 'Um transmissor linear de 4–20 mA mede 0–100 °C. Qual temperatura corresponde a 12 mA?', options: ['12 °C', '25 °C', '75 °C', '50 °C'], correctIndex: 3, explanation: '(12 − 4)/(20 − 4) = 0,5 da faixa; 0,5 × 100 = 50 °C.'),
      Question(id: 'clp-4-q2', topic: 'Sinais analógicos', prompt: 'Um conversor ideal de 12 bits pode representar quantos códigos distintos?', options: ['4096', '12', '1024', '2048'], correctIndex: 0, explanation: 'Um conversor de n bits representa 2ⁿ códigos: 2¹² = 4096.'),
    ]),
  ];

  static final List<Quiz> quizzes = [
    ...lessons,
    Quiz(id: 'q-eb-final', title: 'Prova final — Eletricidade Básica', topic: 'Eletricidade Básica', rewardXp: 300, badgeId: 'primeira-trilha', questions: [for (final quiz in lessons) if (const ['q-eb-1', 'q-ohm', 'q-eb-3', 'q-assoc', 'q-eb-5', 'q-eb-6'].contains(quiz.id)) ...quiz.questions]),
    Quiz(id: 'q-ea-final', title: 'Prova final — Eletrônica Analógica', topic: 'Eletrônica Analógica', rewardXp: 300, badgeId: 'dominio-analogica', questions: [for (final quiz in lessons) if (const ['q-ea-1', 'q-ea-2', 'q-ea-3', 'q-ea-4', 'q-ea-5'].contains(quiz.id)) ...quiz.questions]),
    Quiz(id: 'q-ed-final', title: 'Prova final — Eletrônica Digital', topic: 'Eletrônica Digital', rewardXp: 300, badgeId: 'dominio-digital', questions: [for (final quiz in lessons) if (const ['q-ed-1', 'q-ed-2', 'q-ed-3', 'q-ed-4'].contains(quiz.id)) ...quiz.questions]),
    Quiz(id: 'q-ie-final', title: 'Prova final — Instalações Elétricas', topic: 'Instalações Elétricas', rewardXp: 300, badgeId: 'dominio-instalacoes', questions: [for (final quiz in lessons) if (const ['q-ie-1', 'q-ie-2', 'q-ie-3', 'q-ie-4'].contains(quiz.id)) ...quiz.questions]),
    Quiz(id: 'q-clp-final', title: 'Prova final — CLP e Automação', topic: 'CLP e Automação', rewardXp: 300, badgeId: 'dominio-automacao', questions: [for (final quiz in lessons) if (const ['q-clp-1', 'q-clp-2', 'q-clp-3', 'q-clp-4'].contains(quiz.id)) ...quiz.questions]),
  ];

  static const List<Trail> trails = [
    Trail(id: 'eletricidade-basica', title: 'Eletricidade Básica', modules: [
        TrailModule(id: 'eb-1', order: 1, title: 'Grandezas elétricas', subtitle: 'Tensão, corrente e resistência', status: ModuleStatus.current, quizId: 'q-eb-1'),
        TrailModule(id: 'eb-2', order: 2, title: 'Lei de Ohm', subtitle: 'Relacionar tensão, resistência e corrente', status: ModuleStatus.locked, quizId: 'q-ohm'),
        TrailModule(id: 'eb-3', order: 3, title: 'Potência e energia', subtitle: 'Watts, kWh e consumo', status: ModuleStatus.locked, quizId: 'q-eb-3'),
        TrailModule(id: 'eb-4', order: 4, title: 'Associação de resistores', subtitle: 'Série e paralelo', status: ModuleStatus.locked, quizId: 'q-assoc'),
        TrailModule(id: 'eb-5', order: 5, title: 'Leis de Kirchhoff', subtitle: 'Conservação de carga e energia', status: ModuleStatus.locked, quizId: 'q-eb-5'),
        TrailModule(id: 'eb-6', order: 6, title: 'Divisores de tensão e corrente', subtitle: 'Distribuição de grandezas', status: ModuleStatus.locked, quizId: 'q-eb-6'),
        TrailModule(id: 'eb-final', order: 7, title: 'Prova final da trilha', subtitle: 'Revisão dos módulos · mínimo de 70% para concluir', status: ModuleStatus.locked, quizId: 'q-eb-final', isFinalExam: true),
    ]),
    Trail(id: 'eletronica-analogica', title: 'Eletrônica Analógica', modules: [
        TrailModule(id: 'ea-1', order: 1, title: 'Semicondutores', subtitle: 'Materiais tipo P e N', status: ModuleStatus.current, quizId: 'q-ea-1'),
        TrailModule(id: 'ea-2', order: 2, title: 'Diodos e retificadores', subtitle: 'Condução e conversão CA-CC', status: ModuleStatus.locked, quizId: 'q-ea-2'),
        TrailModule(id: 'ea-3', order: 3, title: 'Transistores', subtitle: 'Chaveamento e amplificação', status: ModuleStatus.locked, quizId: 'q-ea-3'),
        TrailModule(id: 'ea-4', order: 4, title: 'Amplificadores operacionais', subtitle: 'Realimentação negativa', status: ModuleStatus.locked, quizId: 'q-ea-4'),
        TrailModule(id: 'ea-5', order: 5, title: 'Filtros RC', subtitle: 'Resposta em frequência', status: ModuleStatus.locked, quizId: 'q-ea-5'),
        TrailModule(id: 'ea-final', order: 6, title: 'Prova final da trilha', subtitle: 'Revisão dos módulos · mínimo de 70% para concluir', status: ModuleStatus.locked, quizId: 'q-ea-final', isFinalExam: true),
    ]),
    Trail(id: 'eletronica-digital', title: 'Eletrônica Digital', modules: [
        TrailModule(id: 'ed-1', order: 1, title: 'Sistemas de numeração', subtitle: 'Binário, decimal e hexadecimal', status: ModuleStatus.current, quizId: 'q-ed-1'),
        TrailModule(id: 'ed-2', order: 2, title: 'Portas lógicas', subtitle: 'Tabelas-verdade', status: ModuleStatus.locked, quizId: 'q-ed-2'),
        TrailModule(id: 'ed-3', order: 3, title: 'Lógica combinacional', subtitle: 'Expressões booleanas', status: ModuleStatus.locked, quizId: 'q-ed-3'),
        TrailModule(id: 'ed-4', order: 4, title: 'Lógica sequencial', subtitle: 'Memória e contadores', status: ModuleStatus.locked, quizId: 'q-ed-4'),
        TrailModule(id: 'ed-final', order: 5, title: 'Prova final da trilha', subtitle: 'Revisão dos módulos · mínimo de 70% para concluir', status: ModuleStatus.locked, quizId: 'q-ed-final', isFinalExam: true),
    ]),
    Trail(id: 'instalacoes-eletricas', title: 'Instalações Elétricas', modules: [
        TrailModule(id: 'ie-1', order: 1, title: 'Simbologia e diagramas', subtitle: 'Plantas e representação', status: ModuleStatus.current, quizId: 'q-ie-1'),
        TrailModule(id: 'ie-2', order: 2, title: 'Dimensionamento de condutores', subtitle: 'Resistência e queda de tensão', status: ModuleStatus.locked, quizId: 'q-ie-2'),
        TrailModule(id: 'ie-3', order: 3, title: 'Proteção elétrica', subtitle: 'Função dos dispositivos', status: ModuleStatus.locked, quizId: 'q-ie-3'),
        TrailModule(id: 'ie-4', order: 4, title: 'Comandos elétricos', subtitle: 'Contator e intertravamento', status: ModuleStatus.locked, quizId: 'q-ie-4'),
        TrailModule(id: 'ie-final', order: 5, title: 'Prova final da trilha', subtitle: 'Revisão dos módulos · mínimo de 70% para concluir', status: ModuleStatus.locked, quizId: 'q-ie-final', isFinalExam: true),
    ]),
    Trail(id: 'clp-automacao', title: 'CLP e Automação', unlocked: false, requiresTrailId: 'eletronica-digital', modules: [
        TrailModule(id: 'clp-1', order: 1, title: 'Lógica Ladder', subtitle: 'Contatos, bobinas e selos', status: ModuleStatus.locked, quizId: 'q-clp-1'),
        TrailModule(id: 'clp-2', order: 2, title: 'Ciclo de varredura', subtitle: 'Entradas, programa e saídas', status: ModuleStatus.locked, quizId: 'q-clp-2'),
        TrailModule(id: 'clp-3', order: 3, title: 'Temporizadores e contadores', subtitle: 'Tempo e eventos', status: ModuleStatus.locked, quizId: 'q-clp-3'),
        TrailModule(id: 'clp-4', order: 4, title: 'Sinais analógicos', subtitle: 'Escala e instrumentação', status: ModuleStatus.locked, quizId: 'q-clp-4'),
        TrailModule(id: 'clp-final', order: 5, title: 'Prova final da trilha', subtitle: 'Revisão dos módulos · mínimo de 70% para concluir', status: ModuleStatus.locked, quizId: 'q-clp-final', isFinalExam: true),
    ]),
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
      id: 'dominio-automacao',
      name: 'Domínio em CLP e Automação',
      discipline: 'CLP e Automação',
      description: 'Todos os módulos e a prova final de CLP e Automação com pelo menos 70% de acerto',
      icon: MedalIcon.automation,
    ),

    Medal(
      id: 'dominio-instalacoes',
      name: 'Domínio em Instalações Elétricas',
      discipline: 'Instalações Elétricas',
      description: 'Todos os módulos e a prova final de Instalações Elétricas com pelo menos 70% de acerto',
      icon: MedalIcon.installation,
    ),

    Medal(
      id: 'dominio-digital',
      name: 'Domínio em Eletrônica Digital',
      discipline: 'Eletrônica Digital',
      description: 'Todos os módulos e a prova final de Eletrônica Digital com pelo menos 70% de acerto',
      icon: MedalIcon.digital,
    ),

    Medal(
      id: 'dominio-analogica',
      name: 'Domínio em Eletrônica Analógica',
      discipline: 'Eletrônica Analógica',
      description: 'Todos os módulos e a prova final de Eletrônica Analógica com pelo menos 70% de acerto',
      icon: MedalIcon.analog,
    ),

    Medal(
      id: 'mestre-ohm',
      name: 'Eletricidade Básica · Lei de Ohm',
      discipline: 'Eletricidade Básica',
      description: 'Desafio de Lei de Ohm com 80% ou mais de acerto',
      icon: MedalIcon.ohm,
    ),
    Medal(
      id: 'potencia-total',
      name: 'Eletricidade Básica · Potência',
      discipline: 'Eletricidade Básica',
      description: 'Atividade de Potência e energia com 80% ou mais de acerto',
      icon: MedalIcon.bolt,
    ),
    Medal(
      id: 'streak-7',
      name: '7 dias seguidos',
      description: 'Estudou 7 dias sem interrupção',
      icon: MedalIcon.streak,
      iconLabel: '7',
    ),
    Medal(
      id: 'mestre-cores',
      name: 'Eletrônica Analógica · Resistores',
      discipline: 'Eletrônica Analógica',
      description: 'Desafio de código de cores com 80% ou mais de acerto',
      icon: MedalIcon.resistor,
    ),
    Medal(
      id: 'rei-paralelo',
      name: 'Eletricidade Básica · Associações',
      discipline: 'Eletricidade Básica',
      description: 'Desafio de associação de resistores com 80% ou mais',
      icon: MedalIcon.parallel,
    ),
    Medal(
      id: 'streak-30',
      name: '30 dias seguidos',
      description: 'Estudou 30 dias sem interrupção',
      icon: MedalIcon.streak,
      iconLabel: '30',
    ),
    Medal(
      id: 'primeira-trilha',
      name: 'Domínio em Eletricidade Básica',
      discipline: 'Eletricidade Básica',
      description: 'Todos os módulos e a prova final de Eletricidade Básica com pelo menos 70% de acerto',
      icon: MedalIcon.electrician,
    ),
    Medal(
      id: 'kirchhoff',
      name: 'Eletricidade Básica · Kirchhoff',
      discipline: 'Eletricidade Básica',
      description: 'Atividade de Leis de Kirchhoff com 80% ou mais de acerto',
      icon: MedalIcon.kirchhoff,
    ),
    Medal(
      id: 'streak-100',
      name: '100 dias seguidos',
      description: 'Estudou 100 dias sem interrupção',
      icon: MedalIcon.streak,
      iconLabel: '100',
    ),
  ];
}
