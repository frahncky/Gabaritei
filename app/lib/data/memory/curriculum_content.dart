import '../../domain/models/content.dart';
import '../../domain/models/gamification.dart';

/// Conteúdo introdutório das disciplinas complementares.
/// Cada unidade tem resumo, duas questões próprias e explicações.
class CurriculumLesson {
  const CurriculumLesson(this.title, this.summary, this.questions);
  final String title;
  final String summary;
  final List<Question> questions;
}

class CurriculumDiscipline {
  const CurriculumDiscipline(this.id, this.title, this.icon, this.lessons);
  final String id;
  final String title;
  final MedalIcon icon;
  final List<CurriculumLesson> lessons;
}

class ExtendedContent {
  ExtendedContent._();

  static const disciplines = <CurriculumDiscipline>[
    CurriculumDiscipline(
      'circuitos-cc', 'Circuitos CC', MedalIcon.parallel, [
        CurriculumLesson(
          'Série e paralelo',
          'Em série, a corrente é comum e as resistências se somam. Em paralelo, a tensão é comum e somam-se as condutâncias; para dois resistores, Req = R1·R2/(R1+R2).',
          [
            Question(
              id: 'circuitos-cc-1-1',
              topic: 'Série e paralelo',
              prompt: 'Resistores de 4 Ω e 8 Ω em série conduzem 2 A. Qual a tensão total?',
              options: ['24 V', '12 V', '6 V', '16 V'],
              correctIndex: 0,
              explanation: 'Req = 4 + 8 = 12 Ω; V = Req·I = 12·2 = 24 V.',
            ),
            Question(
              id: 'circuitos-cc-1-2',
              topic: 'Série e paralelo',
              prompt: 'Resistores de 6 Ω e 3 Ω estão em paralelo sob 12 V. Qual a corrente total?',
              options: ['9 A', '6 A', '2 A', '4 A'],
              correctIndex: 1,
              explanation: 'As correntes são 12/6 = 2 A e 12/3 = 4 A. A corrente total é 6 A.',
            ),
          ],
        ),
        CurriculumLesson(
          'Leis de Kirchhoff',
          'A lei dos nós expressa conservação de carga: a soma das correntes que entram iguala a das que saem. Na lei das malhas, a soma algébrica das tensões em um percurso fechado é zero.',
          [
            Question(
              id: 'circuitos-cc-2-1',
              topic: 'Leis de Kirchhoff',
              prompt: 'Em um nó entram 2 A e 3 A. Se saem 4 A por um ramo, quanto sai pelo outro?',
              options: ['9 A', '2 A', '1 A', '5 A'],
              correctIndex: 2,
              explanation: 'Pela conservação de carga: 2 + 3 = 4 + I; I = 1 A.',
            ),
            Question(
              id: 'circuitos-cc-2-2',
              topic: 'Leis de Kirchhoff',
              prompt: 'Uma malha tem fonte de 20 V e quedas de 8 V e 5 V. Qual a terceira queda?',
              options: ['13 V', '33 V', '3 V', '7 V'],
              correctIndex: 3,
              explanation: '20 − 8 − 5 − V = 0; V = 7 V.',
            ),
          ],
        ),
        CurriculumLesson(
          'Transitórios RC e RL',
          'A constante de tempo é τ = RC em circuitos RC e τ = L/R em circuitos RL de primeira ordem. Após uma constante de tempo, a resposta crescente alcança aproximadamente 63,2% da variação total.',
          [
            Question(
              id: 'circuitos-cc-3-1',
              topic: 'Transitórios RC e RL',
              prompt: 'Um circuito RC possui R = 10 kΩ e C = 100 µF. Qual sua constante de tempo?',
              options: ['1 s', '0,1 s', '10 s', '100 s'],
              correctIndex: 0,
              explanation: 'τ = RC = 10000·100·10⁻⁶ = 1 s.',
            ),
            Question(
              id: 'circuitos-cc-3-2',
              topic: 'Transitórios RC e RL',
              prompt: 'Um circuito RL possui L = 0,2 H e R = 10 Ω. Qual sua constante de tempo?',
              options: ['2 s', '20 ms', '2 ms', '200 ms'],
              correctIndex: 1,
              explanation: 'τ = L/R = 0,2/10 = 0,02 s = 20 ms.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'circuitos-ca', 'Circuitos CA', MedalIcon.ohm, [
        CurriculumLesson(
          'Senoides e fasores',
          'Para uma senoide, Vrms = Vp/√2 e T = 1/f. Fasores representam amplitude e fase em regime senoidal de frequência comum; adiantamento e atraso devem ser comparados usando a mesma referência.',
          [
            Question(
              id: 'circuitos-ca-1-1',
              topic: 'Senoides e fasores',
              prompt: 'Uma tensão senoidal tem pico de 100√2 V. Qual seu valor eficaz?',
              options: ['100 V', '50 V', '200 V', '100√2 V'],
              correctIndex: 0,
              explanation: 'Vrms = Vp/√2 = 100 V.',
            ),
            Question(
              id: 'circuitos-ca-1-2',
              topic: 'Senoides e fasores',
              prompt: 'Uma senoide completa um ciclo a cada 20 ms. Qual é sua frequência?',
              options: ['100 Hz', '50 Hz', '20 Hz', '60 Hz'],
              correctIndex: 1,
              explanation: 'f = 1/T = 1/0,020 = 50 Hz.',
            ),
          ],
        ),
        CurriculumLesson(
          'Impedância RLC',
          'Em regime senoidal, ZR = R, ZL = jωL e ZC = −j/(ωC). Em série, as impedâncias se somam. O sinal da parte imaginária identifica predominância indutiva ou capacitiva.',
          [
            Question(
              id: 'circuitos-ca-2-1',
              topic: 'Impedância RLC',
              prompt: 'Um circuito em série tem R = 3 Ω e XL = 4 Ω. Qual o módulo da impedância?',
              options: ['1 Ω', '12 Ω', '5 Ω', '7 Ω'],
              correctIndex: 2,
              explanation: '|Z| = √(3² + 4²) = 5 Ω.',
            ),
            Question(
              id: 'circuitos-ca-2-2',
              topic: 'Impedância RLC',
              prompt: 'Em um circuito RLC série, XL = 20 Ω e XC = 30 Ω. A reatância resultante é:',
              options: ['50 Ω', '10 Ω', '−50 Ω', '−10 Ω'],
              correctIndex: 3,
              explanation: 'X = XL − XC = 20 − 30 = −10 Ω, com predominância capacitiva.',
            ),
          ],
        ),
        CurriculumLesson(
          'Potência e fator de potência',
          'Usando valores eficazes em uma carga senoidal monofásica, S = VI, P = VI·cosφ e Q = VI·senφ. O fator de potência é P/S; sua interpretação depende do regime e das formas de onda.',
          [
            Question(
              id: 'circuitos-ca-3-1',
              topic: 'Potência e fator de potência',
              prompt: 'Uma carga senoidal recebe 100 V, conduz 2 A e tem fator de potência 0,8. Qual é a potência ativa?',
              options: ['160 W', '200 W', '80 W', '250 W'],
              correctIndex: 0,
              explanation: 'P = VI·fp = 100·2·0,8 = 160 W.',
            ),
            Question(
              id: 'circuitos-ca-3-2',
              topic: 'Potência e fator de potência',
              prompt: 'Uma carga apresenta P = 300 W e S = 500 VA. Qual o fator de potência?',
              options: ['0,2', '0,6', '0,8', '1,67'],
              correctIndex: 1,
              explanation: 'fp = P/S = 300/500 = 0,6.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'eletronica-potencia', 'Eletrônica de potência', MedalIcon.bolt, [
        CurriculumLesson(
          'Retificadores controlados',
          'Um SCR conduz após disparo adequado e permanece conduzindo enquanto a corrente superar sua condição de manutenção. Em um retificador controlado, o ângulo de disparo influencia o valor médio de saída.',
          [
            Question(
              id: 'eletronica-potencia-1-1',
              topic: 'Retificadores controlados',
              prompt: 'Em um SCR convencional, o disparo controlado é aplicado em qual terminal?',
              options: ['Gate', 'Cátodo apenas', 'Carcaça', 'Dissipador'],
              correctIndex: 0,
              explanation: 'O gate é o terminal de comando de disparo do SCR.',
            ),
            Question(
              id: 'eletronica-potencia-1-2',
              topic: 'Retificadores controlados',
              prompt: 'Um retificador converte principalmente:',
              options: ['Frequência em resistência', 'CA em CC', 'CC em CA', 'Energia elétrica em mecânica'],
              correctIndex: 1,
              explanation: 'A retificação produz saída unidirecional a partir de uma entrada alternada.',
            ),
          ],
        ),
        CurriculumLesson(
          'Conversores CC-CC',
          'Em um buck ideal em condução contínua, Vout = D·Vin, sendo D a razão cíclica. O indutor armazena energia, enquanto o capacitor reduz a ondulação de tensão na saída.',
          [
            Question(
              id: 'eletronica-potencia-2-1',
              topic: 'Conversores CC-CC',
              prompt: 'Um buck ideal recebe 24 V com razão cíclica de 50%. Qual a saída em condução contínua?',
              options: ['24 V', '6 V', '12 V', '48 V'],
              correctIndex: 2,
              explanation: 'Vout = D·Vin = 0,5·24 = 12 V.',
            ),
            Question(
              id: 'eletronica-potencia-2-2',
              topic: 'Conversores CC-CC',
              prompt: 'Qual conversor CC-CC eleva a tensão no modelo ideal usual?',
              options: ['Buck', 'Ponte de diodos', 'Transformador isolado sem chaveamento', 'Boost'],
              correctIndex: 3,
              explanation: 'O boost é o conversor elevador de tensão.',
            ),
          ],
        ),
        CurriculumLesson(
          'Inversores e acionamentos',
          'Um inversor produz tensão alternada a partir de um barramento CC. A modulação PWM controla o chaveamento; em acionamentos, a frequência elétrica influencia a velocidade síncrona do motor.',
          [
            Question(
              id: 'eletronica-potencia-3-1',
              topic: 'Inversores e acionamentos',
              prompt: 'Um inversor realiza qual conversão principal?',
              options: ['CC em CA', 'CA em CC apenas', 'Resistência em corrente', 'Pressão em vazão'],
              correctIndex: 0,
              explanation: 'O inversor utiliza chaves eletrônicas para sintetizar uma saída alternada a partir de CC.',
            ),
            Question(
              id: 'eletronica-potencia-3-2',
              topic: 'Inversores e acionamentos',
              prompt: 'Em PWM, aumentar a razão cíclica significa:',
              options: ['Eliminar todas as perdas', 'Aumentar a fração do período em que o sinal fica ativo', 'Aumentar obrigatoriamente a frequência', 'Reduzir o período a zero'],
              correctIndex: 1,
              explanation: 'D = ton/T. Maior D corresponde a uma fração ativa maior do período.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'seguranca-normas', 'Segurança e normas', MedalIcon.electrician, [
        CurriculumLesson(
          'NR-10',
          'O estudo de segurança elétrica envolve análise de riscos, medidas de controle e atuação por pessoal autorizado. Questões conceituais não substituem capacitação, procedimento de trabalho nem consulta à norma vigente.',
          [
            Question(
              id: 'seguranca-normas-1-1',
              topic: 'NR-10',
              prompt: 'Antes de uma atividade elétrica, a análise de riscos serve principalmente para:',
              options: ['Identificar perigos e definir medidas de controle', 'Dispensar planejamento', 'Aumentar a potência da instalação', 'Substituir todas as proteções'],
              correctIndex: 0,
              explanation: 'A análise de riscos identifica perigos e orienta controles antes da execução.',
            ),
            Question(
              id: 'seguranca-normas-1-2',
              topic: 'NR-10',
              prompt: 'Usar um equipamento de proteção individual significa que:',
              options: ['O circuito deixou de ter energia', 'Os demais controles e procedimentos continuam necessários', 'Qualquer tarefa está automaticamente autorizada', 'Não é preciso avaliar riscos'],
              correctIndex: 1,
              explanation: 'EPI integra medidas de proteção e não elimina a necessidade de planejamento e controles.',
            ),
          ],
        ),
        CurriculumLesson(
          'Desenergização e bloqueio',
          'Desligar um comando não demonstra ausência de tensão. A intervenção deve seguir procedimento específico, com controle das fontes de energia e prevenção de reenergização, executado por pessoal autorizado.',
          [
            Question(
              id: 'seguranca-normas-2-1',
              topic: 'Desenergização e bloqueio',
              prompt: 'Por que o simples comando de desligar não comprova ausência de tensão?',
              options: ['O botão mede a tensão', 'A resistência sempre se torna infinita', 'Podem existir falhas ou outras fontes de alimentação', 'Toda corrente sempre se anula em qualquer circuito'],
              correctIndex: 2,
              explanation: 'Falhas, retornos e fontes alternativas podem manter energia; o comando não é uma medição.',
            ),
            Question(
              id: 'seguranca-normas-2-2',
              topic: 'Desenergização e bloqueio',
              prompt: 'Qual é a finalidade do bloqueio contra reenergização?',
              options: ['Elevar o fator de potência', 'Substituir o aterramento', 'Aumentar a corrente de curto-circuito', 'Evitar energização indevida durante a intervenção'],
              correctIndex: 3,
              explanation: 'O bloqueio controla a possibilidade de restabelecimento indevido da energia.',
            ),
          ],
        ),
        CurriculumLesson(
          'Proteção e aterramento',
          'Proteções devem ser selecionadas para os riscos e características do circuito. Aterramento de proteção e equipotencialização contribuem para a proteção contra choques, mas não tornam intervenções energizadas automaticamente seguras.',
          [
            Question(
              id: 'seguranca-normas-3-1',
              topic: 'Proteção e aterramento',
              prompt: 'O condutor de proteção tem como função principal:',
              options: ['Integrar a proteção contra choques em massas acessíveis', 'Alimentar normalmente todas as cargas', 'Substituir qualquer fusível', 'Aumentar o consumo de energia'],
              correctIndex: 0,
              explanation: 'O condutor de proteção conecta massas ao sistema de proteção previsto no projeto.',
            ),
            Question(
              id: 'seguranca-normas-3-2',
              topic: 'Proteção e aterramento',
              prompt: 'Um fusível é escolhido principalmente considerando:',
              options: ['A quantidade de tomadas sem analisar o circuito', 'Características elétricas e coordenação da proteção', 'Somente a cor externa', 'A maior corrente disponível sem limite'],
              correctIndex: 1,
              explanation: 'A seleção deve considerar circuito, corrente, tensão, capacidade de interrupção e coordenação.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'maquinas-eletricas', 'Máquinas elétricas', MedalIcon.bolt, [
        CurriculumLesson(
          'Transformadores',
          'No transformador ideal, V1/V2 = N1/N2 e as potências de entrada e saída são iguais. Transformadores reais apresentam perdas, que reduzem o rendimento.',
          [
            Question(
              id: 'maquinas-eletricas-1-1',
              topic: 'Transformadores',
              prompt: 'Um transformador ideal tem N1/N2 = 10 e recebe 220 V no primário. Qual a tensão secundária?',
              options: ['22 V', '2200 V', '110 V', '10 V'],
              correctIndex: 0,
              explanation: 'V2 = V1·N2/N1 = 220/10 = 22 V.',
            ),
            Question(
              id: 'maquinas-eletricas-1-2',
              topic: 'Transformadores',
              prompt: 'Um transformador entrega 900 W e recebe 1000 W. Qual é o rendimento?',
              options: ['111%', '90%', '10%', '100%'],
              correctIndex: 1,
              explanation: 'η = Pout/Pin = 900/1000 = 0,9 = 90%.',
            ),
          ],
        ),
        CurriculumLesson(
          'Motores de indução',
          'A velocidade síncrona é ns = 120f/p, com p em polos. Em operação motora usual, o rotor gira abaixo de ns; o escorregamento é s = (ns − n)/ns.',
          [
            Question(
              id: 'maquinas-eletricas-2-1',
              topic: 'Motores de indução',
              prompt: 'Qual a velocidade síncrona de um motor de 4 polos alimentado a 60 Hz?',
              options: ['1200 rpm', '900 rpm', '1800 rpm', '3600 rpm'],
              correctIndex: 2,
              explanation: 'ns = 120·60/4 = 1800 rpm.',
            ),
            Question(
              id: 'maquinas-eletricas-2-2',
              topic: 'Motores de indução',
              prompt: 'Um motor tem ns = 1800 rpm e n = 1710 rpm. Qual seu escorregamento?',
              options: ['10%', '95%', '0,5%', '5%'],
              correctIndex: 3,
              explanation: 's = (1800 − 1710)/1800 = 0,05 = 5%.',
            ),
          ],
        ),
        CurriculumLesson(
          'Máquinas CC e síncronas',
          'Nas máquinas CC, interação entre campo e corrente produz torque. Nas máquinas síncronas em regime estável, a rotação acompanha a velocidade síncrona do campo girante.',
          [
            Question(
              id: 'maquinas-eletricas-3-1',
              topic: 'Máquinas CC e síncronas',
              prompt: 'Em regime estável, o rotor de um motor síncrono gira:',
              options: ['Na velocidade síncrona', 'Sempre a metade da velocidade síncrona', 'Sempre parado', 'A uma velocidade independente da frequência'],
              correctIndex: 0,
              explanation: 'Em sincronismo, a velocidade do rotor coincide com a velocidade do campo girante.',
            ),
            Question(
              id: 'maquinas-eletricas-3-2',
              topic: 'Máquinas CC e síncronas',
              prompt: 'Num motor CC com fluxo aproximadamente constante, o torque é proporcional principalmente à:',
              options: ['Temperatura ambiente apenas', 'Corrente de armadura', 'Cor da carcaça', 'Resistência de isolamento apenas'],
              correctIndex: 1,
              explanation: 'No modelo básico, T = k·Φ·Ia. Mantendo Φ constante, T é proporcional a Ia.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'robotica', 'Robótica', MedalIcon.automation, [
        CurriculumLesson(
          'Cinemática',
          'A cinemática relaciona configurações das juntas e posições do efetuador, sem estudar as forças que causam o movimento. A cinemática direta parte das juntas; a inversa procura configurações para uma pose desejada.',
          [
            Question(
              id: 'robotica-1-1',
              topic: 'Cinemática',
              prompt: 'A cinemática direta calcula:',
              options: ['A pose do efetuador a partir das variáveis das juntas', 'Somente o consumo elétrico', 'A massa de cada cabo', 'A temperatura do controlador'],
              correctIndex: 0,
              explanation: 'A cinemática direta transforma posições articulares em posição e orientação do efetuador.',
            ),
            Question(
              id: 'robotica-1-2',
              topic: 'Cinemática',
              prompt: 'Quantos graus de liberdade possui uma junta rotativa ideal de um único eixo?',
              options: ['Seis', 'Um', 'Dois', 'Três'],
              correctIndex: 1,
              explanation: 'Uma junta rotativa de eixo único permite uma variável angular independente.',
            ),
          ],
        ),
        CurriculumLesson(
          'Sensores e atuadores',
          'Sensores fornecem medidas do ambiente ou do próprio robô. Atuadores convertem energia em ação; um encoder pode fornecer realimentação de posição para o controle de movimento.',
          [
            Question(
              id: 'robotica-2-1',
              topic: 'Sensores e atuadores',
              prompt: 'Qual componente mede posição angular de uma junta?',
              options: ['Contator', 'Dissipador', 'Encoder', 'Fusível'],
              correctIndex: 2,
              explanation: 'O encoder converte movimento angular em sinais associados à posição.',
            ),
            Question(
              id: 'robotica-2-2',
              topic: 'Sensores e atuadores',
              prompt: 'Qual componente atua diretamente na produção de movimento?',
              options: ['Sensor de proximidade', 'Encoder isolado', 'Termistor', 'Motor'],
              correctIndex: 3,
              explanation: 'O motor converte energia elétrica em ação mecânica.',
            ),
          ],
        ),
        CurriculumLesson(
          'Programação de robôs',
          'Um programa de movimento usa referenciais, poses e trajetórias. Uma mesma coordenada pode representar posições físicas distintas quando o referencial muda; trajetórias devem ser verificadas antes da execução.',
          [
            Question(
              id: 'robotica-3-1',
              topic: 'Programação de robôs',
              prompt: 'Por que definir o referencial de coordenadas é necessário?',
              options: ['Porque as coordenadas são interpretadas em relação a uma origem e eixos', 'Porque elimina todos os obstáculos', 'Porque dispensa sensores', 'Porque torna toda posição absoluta no universo'],
              correctIndex: 0,
              explanation: 'A origem e a orientação dos eixos determinam o significado das coordenadas.',
            ),
            Question(
              id: 'robotica-3-2',
              topic: 'Programação de robôs',
              prompt: 'A interpolação de trajetória serve para:',
              options: ['Apagar limites mecânicos', 'Definir pontos intermediários entre posições', 'Aumentar a massa do robô', 'Substituir a alimentação'],
              correctIndex: 1,
              explanation: 'A interpolação determina como o movimento percorre posições intermediárias.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'supervisorios-processos', 'Supervisórios e controle de processos', MedalIcon.automation, [
        CurriculumLesson(
          'Controle PID',
          'No PID, a ação proporcional responde ao erro atual, a integral acumula erro e a derivativa responde à taxa de variação. Os ganhos precisam ser ajustados às características e limitações do processo.',
          [
            Question(
              id: 'supervisorios-processos-1-1',
              topic: 'Controle PID',
              prompt: 'Qual ação do PID acumula o erro ao longo do tempo?',
              options: ['Integral', 'Proporcional', 'Derivativa', 'Manual'],
              correctIndex: 0,
              explanation: 'A ação integral é proporcional à integral temporal do erro.',
            ),
            Question(
              id: 'supervisorios-processos-1-2',
              topic: 'Controle PID',
              prompt: 'Com SP = 60 °C e PV = 55 °C, usando erro e = SP − PV, qual o erro?',
              options: ['0 °C', '5 °C', '−5 °C', '115 °C'],
              correctIndex: 1,
              explanation: 'e = 60 − 55 = 5 °C.',
            ),
          ],
        ),
        CurriculumLesson(
          'IHM e supervisório',
          'A IHM permite visualizar variáveis e interagir com o processo. Alarmes indicam condições que demandam atenção; tendências mostram o comportamento das variáveis ao longo do tempo.',
          [
            Question(
              id: 'supervisorios-processos-2-1',
              topic: 'IHM e supervisório',
              prompt: 'Uma tendência histórica mostra principalmente:',
              options: ['Somente o endereço IP', 'O peso do controlador', 'A evolução de uma variável no tempo', 'Apenas a cor dos equipamentos'],
              correctIndex: 2,
              explanation: 'Gráficos de tendência relacionam valores medidos a instantes de tempo.',
            ),
            Question(
              id: 'supervisorios-processos-2-2',
              topic: 'IHM e supervisório',
              prompt: 'O reconhecimento de um alarme significa necessariamente que sua causa desapareceu?',
              options: ['Sim, sempre', 'Sim, se o botão estiver verde', 'Sim, sem verificar o processo', 'Não; reconhecer e eliminar a causa são ações diferentes'],
              correctIndex: 3,
              explanation: 'Reconhecer informa ciência do evento; a condição de processo pode persistir.',
            ),
          ],
        ),
        CurriculumLesson(
          'Malhas de processo',
          'Uma malha fechada mede a variável, compara-a à referência e ajusta um atuador. Sensor, controlador, elemento final e planta têm funções diferentes e influenciam o resultado do controle.',
          [
            Question(
              id: 'supervisorios-processos-3-1',
              topic: 'Malhas de processo',
              prompt: 'Em uma malha de nível, qual elemento mede a variável controlada?',
              options: ['Sensor de nível', 'Válvula de controle', 'Botão de partida', 'Contator do painel'],
              correctIndex: 0,
              explanation: 'O sensor fornece a medição do nível para o controlador.',
            ),
            Question(
              id: 'supervisorios-processos-3-2',
              topic: 'Malhas de processo',
              prompt: 'O que caracteriza uma malha fechada?',
              options: ['Apenas operação manual sem medição', 'Realimentação da variável medida', 'Ausência de qualquer sensor', 'Comando fixo sem comparação'],
              correctIndex: 1,
              explanation: 'A realimentação permite comparar o resultado medido com a referência.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'telecomunicacoes', 'Telecomunicações', MedalIcon.analog, [
        CurriculumLesson(
          'Modulação',
          'A modulação altera uma característica da portadora de acordo com a informação. Em AM varia-se a amplitude; em FM, a frequência instantânea.',
          [
            Question(
              id: 'telecomunicacoes-1-1',
              topic: 'Modulação',
              prompt: 'Na modulação AM convencional, qual característica da portadora varia com a informação?',
              options: ['Amplitude', 'Velocidade no vácuo', 'Resistência do cabo', 'Comprimento do transmissor'],
              correctIndex: 0,
              explanation: 'AM significa modulação em amplitude.',
            ),
            Question(
              id: 'telecomunicacoes-1-2',
              topic: 'Modulação',
              prompt: 'Na modulação FM, a informação modifica principalmente a:',
              options: ['Massa do receptor', 'Frequência instantânea da portadora', 'Resistência da antena', 'Tensão de aterramento'],
              correctIndex: 1,
              explanation: 'Em FM, a frequência instantânea varia conforme o sinal modulante.',
            ),
          ],
        ),
        CurriculumLesson(
          'Meios de transmissão',
          'Cobre, fibra óptica e enlaces sem fio usam mecanismos físicos diferentes. A escolha depende de distância, taxa de dados, ambiente e necessidade de imunidade a interferências.',
          [
            Question(
              id: 'telecomunicacoes-2-1',
              topic: 'Meios de transmissão',
              prompt: 'Qual meio transmite informação usando luz?',
              options: ['Cabo coaxial', 'Barramento metálico', 'Fibra óptica', 'Par trançado de cobre'],
              correctIndex: 2,
              explanation: 'A fibra guia sinais ópticos ao longo de um núcleo dielétrico.',
            ),
            Question(
              id: 'telecomunicacoes-2-2',
              topic: 'Meios de transmissão',
              prompt: 'Qual meio de transmissão é imune à interferência eletromagnética ao longo da fibra?',
              options: ['Cabo metálico sem blindagem', 'Fio de cobre simples', 'Par de alimentação elétrica', 'Fibra óptica'],
              correctIndex: 3,
              explanation: 'O sinal óptico não depende de correntes elétricas no meio de transmissão.',
            ),
          ],
        ),
        CurriculumLesson(
          'Redes e sinais',
          'A taxa de bits indica bits transmitidos por segundo; bytes agrupam oito bits. Ruído e atenuação limitam a transmissão e devem ser considerados junto da largura de banda.',
          [
            Question(
              id: 'telecomunicacoes-3-1',
              topic: 'Redes e sinais',
              prompt: 'Sem considerar cabeçalhos, quanto tempo leva transmitir 8000 bits a 1000 bit/s?',
              options: ['8 s', '1 s', '80 s', '0,125 s'],
              correctIndex: 0,
              explanation: 't = quantidade/taxa = 8000/1000 = 8 s.',
            ),
            Question(
              id: 'telecomunicacoes-3-2',
              topic: 'Redes e sinais',
              prompt: 'Uma mensagem tem 10 bytes. Quantos bits de dados contém?',
              options: ['100 bits', '80 bits', '10 bits', '8 bits'],
              correctIndex: 1,
              explanation: 'Cada byte contém 8 bits: 10·8 = 80.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'programacao', 'Programação', MedalIcon.digital, [
        CurriculumLesson(
          'Lógica e algoritmos',
          'Algoritmos organizam passos para resolver um problema. Decisões selecionam caminhos e laços repetem operações enquanto uma condição ou contagem permitir.',
          [
            Question(
              id: 'programacao-1-1',
              topic: 'Lógica e algoritmos',
              prompt: 'Uma variável começa em 0 e é incrementada uma vez em cada uma de 5 repetições. Qual o valor final?',
              options: ['5', '0', '4', '10'],
              correctIndex: 0,
              explanation: 'Cinco incrementos de uma unidade levam de 0 a 5.',
            ),
            Question(
              id: 'programacao-1-2',
              topic: 'Lógica e algoritmos',
              prompt: 'Um laço while com condição inicialmente falsa executa seu corpo quantas vezes?',
              options: ['Infinitas', 'Zero', 'Uma', 'Duas'],
              correctIndex: 1,
              explanation: 'O while verifica a condição antes da execução do corpo.',
            ),
          ],
        ),
        CurriculumLesson(
          'Estruturas de dados',
          'Listas organizam sequências e dicionários associam chaves a valores. Ao acessar elementos, é necessário respeitar os limites e a regra de indexação da linguagem.',
          [
            Question(
              id: 'programacao-2-1',
              topic: 'Estruturas de dados',
              prompt: 'Em uma lista indexada a partir de zero, qual índice identifica o terceiro elemento?',
              options: ['1', '3', '2', '0'],
              correctIndex: 2,
              explanation: 'Os índices do primeiro ao terceiro elemento são 0, 1 e 2.',
            ),
            Question(
              id: 'programacao-2-2',
              topic: 'Estruturas de dados',
              prompt: 'Qual estrutura associa uma chave a um valor?',
              options: ['Comentário', 'Operador de soma', 'Laço infinito', 'Dicionário ou mapa'],
              correctIndex: 3,
              explanation: 'Um mapa permite recuperar valores por suas chaves.',
            ),
          ],
        ),
        CurriculumLesson(
          'Programação aplicada',
          'Software conectado a dispositivos precisa tratar entradas inválidas, falhas e limites de tempo. Separar leitura, processamento e saída facilita testes e manutenção.',
          [
            Question(
              id: 'programacao-3-1',
              topic: 'Programação aplicada',
              prompt: 'Uma leitura de sensor retorna erro. Qual comportamento de software é mais adequado?',
              options: ['Tratar o erro e aplicar a política de falha definida', 'Usar o erro como medição válida', 'Ignorar todos os limites', 'Repetir sem limite bloqueando o sistema'],
              correctIndex: 0,
              explanation: 'O tratamento explícito evita confundir falha de comunicação com valor medido.',
            ),
            Question(
              id: 'programacao-3-2',
              topic: 'Programação aplicada',
              prompt: 'Um teste unitário busca verificar principalmente:',
              options: ['Somente a velocidade do processador', 'O comportamento de uma unidade de código em condições definidas', 'A cor do gabinete', 'Toda a rede mundial'],
              correctIndex: 1,
              explanation: 'Testes unitários exercitam funções ou componentes com entradas e resultados esperados.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'matematica-fisica', 'Matemática e física aplicadas', MedalIcon.ohm, [
        CurriculumLesson(
          'Álgebra e trigonometria',
          'Equações relacionam grandezas desconhecidas e conhecidas. Em triângulos retângulos, seno, cosseno e tangente relacionam ângulos e razões entre lados.',
          [
            Question(
              id: 'matematica-fisica-1-1',
              topic: 'Álgebra e trigonometria',
              prompt: 'Qual o valor de x em 3x + 6 = 18?',
              options: ['4', '6', '8', '12'],
              correctIndex: 0,
              explanation: '3x = 12; dividindo ambos os lados por 3, x = 4.',
            ),
            Question(
              id: 'matematica-fisica-1-2',
              topic: 'Álgebra e trigonometria',
              prompt: 'Em um triângulo retângulo, cateto oposto = 3 e hipotenusa = 5. Qual é o seno do ângulo?',
              options: ['0,3', '0,6', '0,8', '1,67'],
              correctIndex: 1,
              explanation: 'senθ = cateto oposto/hipotenusa = 3/5 = 0,6.',
            ),
          ],
        ),
        CurriculumLesson(
          'Mecânica e energia',
          'A segunda lei de Newton relaciona força resultante, massa e aceleração: F = ma. Trabalho é transferência de energia associada à força ao longo de um deslocamento.',
          [
            Question(
              id: 'matematica-fisica-2-1',
              topic: 'Mecânica e energia',
              prompt: 'Uma massa de 2 kg tem aceleração de 3 m/s². Qual a força resultante?',
              options: ['5 N', '9 N', '6 N', '1,5 N'],
              correctIndex: 2,
              explanation: 'F = ma = 2·3 = 6 N.',
            ),
            Question(
              id: 'matematica-fisica-2-2',
              topic: 'Mecânica e energia',
              prompt: 'Uma força constante de 10 N atua na direção de um deslocamento de 4 m. Qual o trabalho?',
              options: ['2,5 J', '14 J', '400 J', '40 J'],
              correctIndex: 3,
              explanation: 'W = Fd·cos0° = 10·4 = 40 J.',
            ),
          ],
        ),
        CurriculumLesson(
          'Ondas e eletromagnetismo',
          'Ondas relacionam velocidade, frequência e comprimento de onda por v = fλ. A indução eletromagnética depende da variação do fluxo magnético concatenado ao circuito.',
          [
            Question(
              id: 'matematica-fisica-3-1',
              topic: 'Ondas e eletromagnetismo',
              prompt: 'Uma onda tem velocidade de 300 m/s e frequência de 100 Hz. Qual seu comprimento de onda?',
              options: ['3 m', '30 m', '0,3 m', '30000 m'],
              correctIndex: 0,
              explanation: 'λ = v/f = 300/100 = 3 m.',
            ),
            Question(
              id: 'matematica-fisica-3-2',
              topic: 'Ondas e eletromagnetismo',
              prompt: 'A indução de tensão em uma espira está relacionada à:',
              options: ['Resistência sempre nula', 'Variação do fluxo magnético concatenado', 'Cor do isolante', 'Massa da bancada apenas'],
              correctIndex: 1,
              explanation: 'A lei de Faraday relaciona a tensão induzida à taxa de variação do fluxo.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'desenho-cad', 'Desenho técnico e CAD', MedalIcon.installation, [
        CurriculumLesson(
          'Vistas e cortes',
          'Vistas ortográficas representam um objeto segundo direções de observação. Cortes usam planos de seção para evidenciar detalhes internos que seriam difíceis de interpretar apenas por linhas ocultas.',
          [
            Question(
              id: 'desenho-cad-1-1',
              topic: 'Vistas e cortes',
              prompt: 'Qual recurso evidencia detalhes internos de uma peça por um plano de seção?',
              options: ['Vista em corte', 'Tabela de materiais apenas', 'Legenda de cores apenas', 'Carimbo sem desenho'],
              correctIndex: 0,
              explanation: 'A vista em corte representa o objeto seccionado e revela detalhes internos.',
            ),
            Question(
              id: 'desenho-cad-1-2',
              topic: 'Vistas e cortes',
              prompt: 'Vistas frontal, superior e lateral são exemplos de:',
              options: ['Curvas de calibração', 'Vistas ortográficas', 'Sinais analógicos', 'Laços de controle'],
              correctIndex: 1,
              explanation: 'As vistas ortográficas representam projeções segundo direções de observação definidas.',
            ),
          ],
        ),
        CurriculumLesson(
          'Cotagem e escalas',
          'Cotas informam as dimensões do objeto. A escala é a razão entre medida desenhada e medida real; uma escala de redução não altera o valor real indicado pela cota.',
          [
            Question(
              id: 'desenho-cad-2-1',
              topic: 'Cotagem e escalas',
              prompt: 'Em escala 1:10, um comprimento real de 500 mm ocupa quanto no desenho?',
              options: ['5 mm', '500 mm', '50 mm', '5000 mm'],
              correctIndex: 2,
              explanation: 'Medida desenhada = medida real/10 = 50 mm.',
            ),
            Question(
              id: 'desenho-cad-2-2',
              topic: 'Cotagem e escalas',
              prompt: 'Um desenho foi ampliado para escala 2:1. Uma cota de 20 mm representa qual tamanho real?',
              options: ['10 mm', '40 mm', '2 mm', '20 mm'],
              correctIndex: 3,
              explanation: 'A cota indica a dimensão real; a escala modifica apenas a representação gráfica.',
            ),
          ],
        ),
        CurriculumLesson(
          'CAD elétrico e mecânico',
          'Ferramentas CAD organizam geometria, camadas, símbolos e documentação. Restrições e referências consistentes ajudam a manter o desenho correto durante alterações.',
          [
            Question(
              id: 'desenho-cad-3-1',
              topic: 'CAD elétrico e mecânico',
              prompt: 'Qual a finalidade de usar camadas em um desenho CAD?',
              options: ['Organizar conjuntos de elementos e sua exibição', 'Eliminar automaticamente todas as cotas', 'Converter toda geometria em texto', 'Substituir a escala por cor'],
              correctIndex: 0,
              explanation: 'Camadas permitem agrupar e controlar visibilidade e propriedades de elementos.',
            ),
            Question(
              id: 'desenho-cad-3-2',
              topic: 'CAD elétrico e mecânico',
              prompt: 'Uma restrição de perpendicularidade entre duas linhas estabelece:',
              options: ['Ausência de qualquer relação geométrica', 'Um ângulo de 90°', 'Comprimentos iguais obrigatoriamente', 'Um ângulo de 0°'],
              correctIndex: 1,
              explanation: 'Linhas perpendiculares formam um ângulo reto.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'metrologia', 'Metrologia', MedalIcon.analog, [
        CurriculumLesson(
          'Instrumentos de medição',
          'O instrumento deve ser adequado à grandeza, à faixa e à resolução desejada. A ligação e o método de medição influenciam o resultado e a segurança.',
          [
            Question(
              id: 'metrologia-1-1',
              topic: 'Instrumentos de medição',
              prompt: 'Um voltímetro mede tensão entre dois pontos e é ligado:',
              options: ['Em paralelo ao elemento medido', 'Sempre em curto na fonte', 'Somente em série com a carga', 'Sem contato ou sensor em todos os casos'],
              correctIndex: 0,
              explanation: 'A tensão é uma diferença de potencial entre pontos; o voltímetro é conectado entre eles.',
            ),
            Question(
              id: 'metrologia-1-2',
              topic: 'Instrumentos de medição',
              prompt: 'Qual instrumento é usualmente empregado para medir diâmetro externo com leitura direta?',
              options: ['Osciloscópio', 'Paquímetro', 'Frequencímetro', 'Megômetro'],
              correctIndex: 1,
              explanation: 'O paquímetro possui faces para medições externas e outros recursos dimensionais.',
            ),
          ],
        ),
        CurriculumLesson(
          'Erros e incerteza',
          'Resolução é a menor variação indicada pelo instrumento. Erro e incerteza são conceitos diferentes: o erro envolve uma diferença em relação a um valor de referência, enquanto a incerteza caracteriza a dispersão atribuída ao resultado.',
          [
            Question(
              id: 'metrologia-2-1',
              topic: 'Erros e incerteza',
              prompt: 'Um instrumento indica 10,2 V para uma referência de 10,0 V. Qual o erro de indicação?',
              options: ['10,0 V', '20,2 V', '0,2 V', '−0,2 V'],
              correctIndex: 2,
              explanation: 'Erro = indicação − referência = 10,2 − 10,0 = 0,2 V.',
            ),
            Question(
              id: 'metrologia-2-2',
              topic: 'Erros e incerteza',
              prompt: 'Uma balança muda a indicação de 0,1 g em 0,1 g. Essa informação descreve sua:',
              options: ['Massa máxima necessariamente', 'Exatidão garantida', 'Rastreabilidade completa', 'Resolução'],
              correctIndex: 3,
              explanation: 'A resolução é a menor mudança discernível na indicação; não garante exatidão.',
            ),
          ],
        ),
        CurriculumLesson(
          'Calibração',
          'Calibração estabelece relações entre indicações e valores de referência sob condições definidas. Ajuste altera o instrumento; calibrar e ajustar não são sinônimos.',
          [
            Question(
              id: 'metrologia-3-1',
              topic: 'Calibração',
              prompt: 'Calibrar um instrumento significa obrigatoriamente ajustá-lo?',
              options: ['Não; calibração e ajuste são operações distintas', 'Sim, sempre', 'Sim, se for digital', 'Sim, apenas quando usa bateria'],
              correctIndex: 0,
              explanation: 'A calibração caracteriza a relação com referências; o ajuste modifica o instrumento.',
            ),
            Question(
              id: 'metrologia-3-2',
              topic: 'Calibração',
              prompt: 'A rastreabilidade metrológica envolve:',
              options: ['A ausência de qualquer incerteza', 'Uma cadeia documentada de calibrações a referências', 'Somente a marca do aparelho', 'A cor do certificado'],
              correctIndex: 1,
              explanation: 'Rastreabilidade relaciona resultados a referências por uma cadeia documentada, com contribuições de incerteza.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'materiais-fabricacao', 'Materiais e processos de fabricação', MedalIcon.installation, [
        CurriculumLesson(
          'Materiais de engenharia',
          'A seleção de materiais considera propriedades mecânicas, térmicas, elétricas e condições de uso. Nenhuma família de materiais é a melhor para todas as aplicações.',
          [
            Question(
              id: 'materiais-fabricacao-1-1',
              topic: 'Materiais de engenharia',
              prompt: 'Qual propriedade descreve a oposição de um material à passagem de corrente elétrica?',
              options: ['Resistividade', 'Densidade', 'Dureza', 'Tenacidade'],
              correctIndex: 0,
              explanation: 'A resistividade é uma propriedade elétrica do material relacionada à resistência.',
            ),
            Question(
              id: 'materiais-fabricacao-1-2',
              topic: 'Materiais de engenharia',
              prompt: 'Na escolha de um material para uma peça, deve-se considerar:',
              options: ['A maior massa em todos os casos', 'Solicitações e ambiente de operação', 'Somente a cor', 'Somente o nome comercial'],
              correctIndex: 1,
              explanation: 'Resistência, temperatura, corrosão, custo e processo dependem da aplicação.',
            ),
          ],
        ),
        CurriculumLesson(
          'Usinagem e conformação',
          'Usinagem remove material para obter forma e dimensões. Conformação modifica a forma por deformação; os parâmetros de processo afetam acabamento, esforço e produtividade.',
          [
            Question(
              id: 'materiais-fabricacao-2-1',
              topic: 'Usinagem e conformação',
              prompt: 'Qual processo remove cavacos para fabricar uma peça?',
              options: ['Dobramento apenas', 'Extrusão apenas', 'Usinagem', 'Laminação a frio apenas'],
              correctIndex: 2,
              explanation: 'A usinagem remove material na forma de cavacos.',
            ),
            Question(
              id: 'materiais-fabricacao-2-2',
              topic: 'Usinagem e conformação',
              prompt: 'O dobramento de uma chapa é um exemplo de:',
              options: ['Retificação elétrica', 'Fundição obrigatoriamente', 'Medição de dureza', 'Conformação'],
              correctIndex: 3,
              explanation: 'No dobramento, a forma é alterada por deformação do material.',
            ),
          ],
        ),
        CurriculumLesson(
          'Soldagem e montagem',
          'Processos de união e montagem devem atender aos requisitos da peça e aos materiais. Inspeção verifica características especificadas; a escolha do método depende do tipo de defeito e de acesso.',
          [
            Question(
              id: 'materiais-fabricacao-3-1',
              topic: 'Soldagem e montagem',
              prompt: 'Uma união por parafusos tem como característica usual:',
              options: ['Possibilidade de desmontagem', 'Fusão obrigatória das peças', 'Ausência de torque de aperto', 'Impossibilidade de manutenção'],
              correctIndex: 0,
              explanation: 'Uniões parafusadas podem ser desmontadas, respeitadas as condições dos componentes.',
            ),
            Question(
              id: 'materiais-fabricacao-3-2',
              topic: 'Soldagem e montagem',
              prompt: 'A inspeção visual de uma solda é capaz de identificar diretamente:',
              options: ['A vida infinita da união', 'Descontinuidades visíveis na superfície', 'Todos os defeitos internos sem exceção', 'A composição química exata'],
              correctIndex: 1,
              explanation: 'A inspeção visual avalia aspectos acessíveis à observação; não revela todo defeito interno.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'mecanica-maquinas', 'Mecânica e elementos de máquinas', MedalIcon.automation, [
        CurriculumLesson(
          'Estática e resistência',
          'Em equilíbrio estático, a soma das forças e a soma dos momentos são nulas. A tensão normal média em uma seção solicitada axialmente pode ser estimada por σ = F/A.',
          [
            Question(
              id: 'mecanica-maquinas-1-1',
              topic: 'Estática e resistência',
              prompt: 'Uma força de 1000 N atua axialmente numa seção de 100 mm². Qual a tensão média?',
              options: ['10 MPa', '100 MPa', '0,1 MPa', '1000 MPa'],
              correctIndex: 0,
              explanation: 'σ = 1000/100 = 10 N/mm² = 10 MPa.',
            ),
            Question(
              id: 'mecanica-maquinas-1-2',
              topic: 'Estática e resistência',
              prompt: 'Para equilíbrio estático de um corpo rígido, devem ser nulas:',
              options: ['Todas as forças individualmente', 'A resultante de forças e a resultante de momentos', 'Apenas a massa', 'Apenas as dimensões'],
              correctIndex: 1,
              explanation: 'Forças e momentos podem existir, mas suas somas vetoriais devem ser nulas.',
            ),
          ],
        ),
        CurriculumLesson(
          'Transmissão mecânica',
          'Engrenagens, correias e acoplamentos transmitem movimento e torque. Em um par simples de engrenagens, a velocidade é inversamente proporcional ao número de dentes.',
          [
            Question(
              id: 'mecanica-maquinas-2-1',
              topic: 'Transmissão mecânica',
              prompt: 'Uma engrenagem motora de 20 dentes gira a 600 rpm e aciona outra de 40 dentes. Qual o módulo da rotação da movida?',
              options: ['600 rpm', '150 rpm', '300 rpm', '1200 rpm'],
              correctIndex: 2,
              explanation: 'n2 = n1·Z1/Z2 = 600·20/40 = 300 rpm.',
            ),
            Question(
              id: 'mecanica-maquinas-2-2',
              topic: 'Transmissão mecânica',
              prompt: 'Um acoplamento entre eixos serve principalmente para:',
              options: ['Medir pressão', 'Armazenar dados', 'Gerar sinal de temperatura', 'Transmitir torque entre os eixos'],
              correctIndex: 3,
              explanation: 'O acoplamento conecta eixos para transmitir movimento e torque.',
            ),
          ],
        ),
        CurriculumLesson(
          'Rolamentos e eixos',
          'Rolamentos suportam movimentos relativos e cargas, segundo sua geometria e montagem. Lubrificação, alinhamento e condições de carga influenciam desgaste e vida útil.',
          [
            Question(
              id: 'mecanica-maquinas-3-1',
              topic: 'Rolamentos e eixos',
              prompt: 'Qual condição pode reduzir a vida útil de um rolamento?',
              options: ['Lubrificação inadequada', 'Montagem conforme especificação', 'Alinhamento correto', 'Carga dentro da capacidade'],
              correctIndex: 0,
              explanation: 'Lubrificação inadequada aumenta atrito, aquecimento e desgaste.',
            ),
            Question(
              id: 'mecanica-maquinas-3-2',
              topic: 'Rolamentos e eixos',
              prompt: 'Um eixo em transmissão rotativa é frequentemente solicitado por:',
              options: ['Nenhum esforço mecânico', 'Torção', 'Somente pressão atmosférica', 'Somente carga eletrostática'],
              correctIndex: 1,
              explanation: 'A transmissão de torque produz solicitação de torção no eixo.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'pneumatica-hidraulica', 'Pneumática e hidráulica', MedalIcon.automation, [
        CurriculumLesson(
          'Geração e preparação',
          'Sistemas pneumáticos usam ar comprimido; hidráulicos usam líquido pressurizado. Preparação e controle do fluido ajudam a reduzir contaminação, desgaste e irregularidades de funcionamento.',
          [
            Question(
              id: 'pneumatica-hidraulica-1-1',
              topic: 'Geração e preparação',
              prompt: 'Qual fluido é usado tipicamente em um sistema pneumático?',
              options: ['Ar comprimido', 'Água em todos os casos', 'Óleo exclusivamente', 'Vapor obrigatório'],
              correctIndex: 0,
              explanation: 'A pneumática utiliza gases, usualmente ar comprimido.',
            ),
            Question(
              id: 'pneumatica-hidraulica-1-2',
              topic: 'Geração e preparação',
              prompt: 'Qual componente remove partículas do ar em uma unidade de preparação?',
              options: ['Sensor de posição', 'Filtro', 'Cilindro', 'Bobina de saída'],
              correctIndex: 1,
              explanation: 'O filtro retém contaminantes segundo sua capacidade e especificação.',
            ),
          ],
        ),
        CurriculumLesson(
          'Válvulas e atuadores',
          'Válvulas controlam direção, pressão ou vazão. Em um cilindro ideal, a força disponível pode ser estimada por F = pA, sem considerar atrito e outras perdas.',
          [
            Question(
              id: 'pneumatica-hidraulica-2-1',
              topic: 'Válvulas e atuadores',
              prompt: 'Um cilindro ideal recebe pressão de 100 kPa sobre área de 0,01 m². Qual a força?',
              options: ['100 N', '10000 N', '1000 N', '10 N'],
              correctIndex: 2,
              explanation: 'F = pA = 100000·0,01 = 1000 N.',
            ),
            Question(
              id: 'pneumatica-hidraulica-2-2',
              topic: 'Válvulas e atuadores',
              prompt: 'Qual componente direciona o fluido para avançar ou recuar um cilindro?',
              options: ['Manômetro isolado', 'Filtro de linha', 'Reservatório sem conexões', 'Válvula direcional'],
              correctIndex: 3,
              explanation: 'A válvula direcional comuta os caminhos do fluido para o atuador.',
            ),
          ],
        ),
        CurriculumLesson(
          'Circuitos eletropneumáticos',
          'Circuitos eletropneumáticos combinam lógica elétrica e acionamento pneumático. Solenoides comandam válvulas; sensores informam estados como fim de curso.',
          [
            Question(
              id: 'pneumatica-hidraulica-3-1',
              topic: 'Circuitos eletropneumáticos',
              prompt: 'Em uma válvula eletropneumática, o solenoide recebe:',
              options: ['Um comando elétrico', 'Uma leitura óptica obrigatória', 'Somente força manual', 'Um arquivo CAD diretamente'],
              correctIndex: 0,
              explanation: 'A bobina transforma o comando elétrico em ação eletromagnética sobre a válvula.',
            ),
            Question(
              id: 'pneumatica-hidraulica-3-2',
              topic: 'Circuitos eletropneumáticos',
              prompt: 'Um sensor de fim de curso em um cilindro pode indicar:',
              options: ['A tensão de rede sem medição', 'Que determinada posição foi atingida', 'A massa exata da carga em todos os casos', 'A qualidade do ar automaticamente'],
              correctIndex: 1,
              explanation: 'O sensor detecta uma posição definida do atuador.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'sensores-instrumentacao', 'Sensores e instrumentação', MedalIcon.analog, [
        CurriculumLesson(
          'Sensores industriais',
          'A escolha de sensor considera grandeza, faixa, ambiente e interface. Sensores indutivos detectam alvos metálicos; sensores de temperatura e pressão usam princípios específicos de conversão.',
          [
            Question(
              id: 'sensores-instrumentacao-1-1',
              topic: 'Sensores industriais',
              prompt: 'Qual alvo é detectado tipicamente por um sensor de proximidade indutivo?',
              options: ['Objeto metálico', 'Qualquer objeto sem restrição', 'Somente madeira seca', 'Somente luz visível'],
              correctIndex: 0,
              explanation: 'O sensor indutivo interage com materiais metálicos por campos eletromagnéticos.',
            ),
            Question(
              id: 'sensores-instrumentacao-1-2',
              topic: 'Sensores industriais',
              prompt: 'Um termopar é empregado principalmente para medir:',
              options: ['Nível lógico de programa', 'Temperatura', 'Velocidade de rede', 'Resistência mecânica'],
              correctIndex: 1,
              explanation: 'O termopar relaciona diferença de temperatura a uma tensão termoelétrica.',
            ),
          ],
        ),
        CurriculumLesson(
          'Sinais e condicionamento',
          'Condicionamento adapta sinais à medição: amplificação, filtragem e conversão de nível são exemplos. Um sinal de 4–20 mA possui faixa útil de 16 mA.',
          [
            Question(
              id: 'sensores-instrumentacao-2-1',
              topic: 'Sinais e condicionamento',
              prompt: 'Um transmissor linear de 4–20 mA representa 0–200 kPa. Qual pressão corresponde a 8 mA?',
              options: ['80 kPa', '160 kPa', '50 kPa', '100 kPa'],
              correctIndex: 2,
              explanation: '(8 − 4)/16 = 0,25; 0,25·200 = 50 kPa.',
            ),
            Question(
              id: 'sensores-instrumentacao-2-2',
              topic: 'Sinais e condicionamento',
              prompt: 'Um filtro passa-baixas é usado para atenuar principalmente:',
              options: ['Somente a componente contínua', 'Todas as frequências igualmente', 'Apenas valores negativos', 'Componentes de alta frequência'],
              correctIndex: 3,
              explanation: 'Um passa-baixas preserva frequências baixas relativamente às altas.',
            ),
          ],
        ),
        CurriculumLesson(
          'Transmissores e calibração',
          'Transmissores convertem medidas em sinais padronizados. A calibração compara indicações e referências; a faixa configurada determina a correspondência entre sinal e grandeza.',
          [
            Question(
              id: 'sensores-instrumentacao-3-1',
              topic: 'Transmissores e calibração',
              prompt: 'Um transmissor linear de 4–20 mA mede 0–100 °C. Qual sinal corresponde a 75 °C?',
              options: ['16 mA', '12 mA', '15 mA', '20 mA'],
              correctIndex: 0,
              explanation: 'I = 4 + 16·75/100 = 16 mA.',
            ),
            Question(
              id: 'sensores-instrumentacao-3-2',
              topic: 'Transmissores e calibração',
              prompt: 'Qual valor é o limite inferior do sinal nominal de uma interface 4–20 mA?',
              options: ['20 mA', '4 mA', '0 mA', '1 mA'],
              correctIndex: 1,
              explanation: 'Na faixa nominal 4–20 mA, 4 mA representa o início da escala configurada.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'microcontroladores-embarcados', 'Microcontroladores e sistemas embarcados', MedalIcon.digital, [
        CurriculumLesson(
          'Arquitetura e periféricos',
          'Microcontroladores integram CPU, memória e periféricos. GPIO trata sinais digitais; ADC converte tensão analógica em código; temporizadores medem ou geram intervalos.',
          [
            Question(
              id: 'microcontroladores-embarcados-1-1',
              topic: 'Arquitetura e periféricos',
              prompt: 'Qual periférico converte uma entrada analógica em código digital?',
              options: ['ADC', 'DAC', 'UART', 'GPIO configurado somente como saída'],
              correctIndex: 0,
              explanation: 'O ADC é o conversor analógico-digital.',
            ),
            Question(
              id: 'microcontroladores-embarcados-1-2',
              topic: 'Arquitetura e periféricos',
              prompt: 'Um ADC ideal de 10 bits possui quantos códigos distintos?',
              options: ['2048', '1024', '10', '100'],
              correctIndex: 1,
              explanation: 'O número de códigos é 2¹⁰ = 1024.',
            ),
          ],
        ),
        CurriculumLesson(
          'Firmware',
          'Firmware implementa o comportamento do dispositivo. Rotinas não bloqueantes e uso adequado de temporizadores permitem atender múltiplas tarefas e entradas sem longas esperas.',
          [
            Question(
              id: 'microcontroladores-embarcados-2-1',
              topic: 'Firmware',
              prompt: 'Um watchdog ajuda a detectar:',
              options: ['Qualquer erro de medição automaticamente', 'A posição mecânica sem sensor', 'Ausência de atendimento periódico pelo software', 'A cor da placa'],
              correctIndex: 2,
              explanation: 'O watchdog monitora se o programa o atende dentro do intervalo configurado.',
            ),
            Question(
              id: 'microcontroladores-embarcados-2-2',
              topic: 'Firmware',
              prompt: 'Por que evitar longas esperas bloqueantes em um laço de controle?',
              options: ['Para eliminar a necessidade de memória', 'Para aumentar a tensão da fonte', 'Para dispensar todos os temporizadores', 'Para manter capacidade de responder a outras tarefas e eventos'],
              correctIndex: 3,
              explanation: 'Espera bloqueante impede o fluxo principal de executar outras tarefas durante o intervalo.',
            ),
          ],
        ),
        CurriculumLesson(
          'Comunicação embarcada',
          'UART, SPI e I²C são interfaces com características distintas. I²C usa linhas de dados e clock compartilhadas; SPI costuma usar clock, seleção e linhas de dados.',
          [
            Question(
              id: 'microcontroladores-embarcados-3-1',
              topic: 'Comunicação embarcada',
              prompt: 'No barramento I²C, quais são as linhas de sinal básicas?',
              options: ['SDA e SCL', 'TX e RX exclusivamente', 'Fase e neutro', 'Dreno e fonte'],
              correctIndex: 0,
              explanation: 'SDA transporta dados; SCL é a linha de clock.',
            ),
            Question(
              id: 'microcontroladores-embarcados-3-2',
              topic: 'Comunicação embarcada',
              prompt: 'Na interface SPI, o sinal de seleção de dispositivo é usualmente chamado:',
              options: ['GND apenas', 'CS ou SS', 'ADC', 'PWM'],
              correctIndex: 1,
              explanation: 'Chip Select ou Slave Select habilita o dispositivo selecionado no barramento.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'redes-industriais', 'Redes industriais', MedalIcon.digital, [
        CurriculumLesson(
          'Topologias e camadas',
          'Topologias descrevem como dispositivos e enlaces se organizam. Camadas separam responsabilidades de comunicação, facilitando diagnóstico e integração.',
          [
            Question(
              id: 'redes-industriais-1-1',
              topic: 'Topologias e camadas',
              prompt: 'Em uma topologia estrela, os dispositivos se conectam tipicamente:',
              options: ['A um ponto central', 'Todos em um único anel obrigatório', 'Sem nenhum enlace', 'Somente por ligação mecânica'],
              correctIndex: 0,
              explanation: 'Na estrela, os enlaces convergem para um equipamento central.',
            ),
            Question(
              id: 'redes-industriais-1-2',
              topic: 'Topologias e camadas',
              prompt: 'Qual é a função principal de uma camada física?',
              options: ['Executar a manutenção mecânica', 'Definir características da transmissão de sinais', 'Definir toda a lógica do processo', 'Substituir a aplicação'],
              correctIndex: 1,
              explanation: 'A camada física trata da sinalização e do meio de transmissão.',
            ),
          ],
        ),
        CurriculumLesson(
          'Protocolos industriais',
          'Protocolos estabelecem regras de troca de dados. Um mesmo modelo de dados pode usar transportes diferentes; endereçamento e parâmetros precisam ser compatíveis entre os participantes.',
          [
            Question(
              id: 'redes-industriais-2-1',
              topic: 'Protocolos industriais',
              prompt: 'Modbus RTU e Modbus TCP utilizam necessariamente o mesmo transporte físico?',
              options: ['Sim, ambos dispensam endereços', 'Sim, ambos são somente sinais analógicos', 'Não; RTU é usado em comunicação serial e TCP sobre redes TCP/IP', 'Sim, ambos exigem fibra óptica'],
              correctIndex: 2,
              explanation: 'As variantes compartilham conceitos de aplicação, mas usam enquadramentos e transportes diferentes.',
            ),
            Question(
              id: 'redes-industriais-2-2',
              topic: 'Protocolos industriais',
              prompt: 'Para que serve o endereço de um dispositivo em uma rede?',
              options: ['Aumentar sua potência nominal', 'Definir a cor do painel', 'Substituir a taxa de transmissão', 'Identificá-lo no contexto de comunicação'],
              correctIndex: 3,
              explanation: 'O endereço permite direcionar ou identificar participantes conforme o protocolo.',
            ),
          ],
        ),
        CurriculumLesson(
          'Diagnóstico de rede',
          'Diagnóstico deve separar problemas físicos, parâmetros e aplicação. Verificar alimentação, conectores e configuração é um caminho inicial; capturas de tráfego ajudam a identificar solicitações e respostas.',
          [
            Question(
              id: 'redes-industriais-3-1',
              topic: 'Diagnóstico de rede',
              prompt: 'Dois dispositivos seriais usam taxas de transmissão diferentes. Qual efeito é esperado?',
              options: ['Falha ou interpretação incorreta da comunicação', 'Comunicação necessariamente mais rápida', 'Dobro de precisão do sensor', 'Aumento automático da tensão'],
              correctIndex: 0,
              explanation: 'Os participantes precisam usar parâmetros compatíveis para interpretar os bits transmitidos.',
            ),
            Question(
              id: 'redes-industriais-3-2',
              topic: 'Diagnóstico de rede',
              prompt: 'Uma captura de tráfego permite examinar principalmente:',
              options: ['A composição química do cabo', 'Mensagens trocadas e seus tempos', 'O torque do motor sem sensores', 'A espessura dos condutores diretamente'],
              correctIndex: 1,
              explanation: 'A captura registra quadros ou pacotes para análise da comunicação.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'cnc-manufatura', 'CNC e manufatura', MedalIcon.automation, [
        CurriculumLesson(
          'Coordenadas e referência',
          'Sistemas CNC utilizam coordenadas para posicionamento. Origem de máquina e origem da peça têm funções diferentes; movimentos absolutos e incrementais interpretam destinos de modos distintos.',
          [
            Question(
              id: 'cnc-manufatura-1-1',
              topic: 'Coordenadas e referência',
              prompt: 'Em programação absoluta, a posição de destino é definida em relação:',
              options: ['À origem do sistema de coordenadas ativo', 'Sempre à posição imediatamente anterior', 'Somente ao diâmetro da ferramenta', 'À temperatura ambiente'],
              correctIndex: 0,
              explanation: 'No modo absoluto, os valores indicam coordenadas em relação à origem ativa.',
            ),
            Question(
              id: 'cnc-manufatura-1-2',
              topic: 'Coordenadas e referência',
              prompt: 'Em modo incremental, um deslocamento de +5 mm a partir de X = 10 mm leva a qual posição?',
              options: ['X = 50 mm', 'X = 15 mm', 'X = 5 mm', 'X = 10 mm'],
              correctIndex: 1,
              explanation: 'No modo incremental, soma-se o deslocamento à posição atual: 10 + 5 = 15 mm.',
            ),
          ],
        ),
        CurriculumLesson(
          'Programação CNC',
          'Códigos de preparação e comandos auxiliares organizam operações. A interpretação depende do controlador e da configuração; programas devem ser simulados e verificados para a máquina utilizada.',
          [
            Question(
              id: 'cnc-manufatura-2-1',
              topic: 'Programação CNC',
              prompt: 'Na convenção usual de códigos G, G01 indica:',
              options: ['Troca obrigatória de todas as ferramentas', 'Medição de resistência', 'Interpolação linear com avanço programado', 'Parada de emergência universal'],
              correctIndex: 2,
              explanation: 'G01 é usualmente utilizado para movimento linear com avanço; deve-se confirmar a sintaxe do controlador.',
            ),
            Question(
              id: 'cnc-manufatura-2-2',
              topic: 'Programação CNC',
              prompt: 'Por que simular um programa CNC antes da execução?',
              options: ['Para dispensar a fixação da peça', 'Para eliminar todo desgaste', 'Para substituir todas as proteções da máquina', 'Para identificar erros de trajetória e possíveis colisões'],
              correctIndex: 3,
              explanation: 'A simulação ajuda a verificar o percurso, mas não substitui os demais controles operacionais.',
            ),
          ],
        ),
        CurriculumLesson(
          'Automação da produção',
          'Células de produção integram máquinas, transporte e controle. Tempo de ciclo, disponibilidade e qualidade influenciam a capacidade de entregar peças conformes.',
          [
            Question(
              id: 'cnc-manufatura-3-1',
              topic: 'Automação da produção',
              prompt: 'Uma máquina produz uma peça a cada 30 s, sem paradas. Qual a produção teórica por hora?',
              options: ['120 peças', '30 peças', '60 peças', '1800 peças'],
              correctIndex: 0,
              explanation: 'Uma hora tem 3600 s; 3600/30 = 120 peças.',
            ),
            Question(
              id: 'cnc-manufatura-3-2',
              topic: 'Automação da produção',
              prompt: 'Em uma linha, o gargalo é o recurso que:',
              options: ['Tem obrigatoriamente o maior motor', 'Limita a capacidade global nas condições consideradas', 'Sempre possui maior área física', 'Nunca sofre manutenção'],
              correctIndex: 1,
              explanation: 'O gargalo restringe a vazão da linha em relação aos demais recursos.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'projetos-manutencao', 'Projetos e manutenção', MedalIcon.installation, [
        CurriculumLesson(
          'Documentação de projeto',
          'Requisitos descrevem o que o sistema deve atender. Diagramas, listas de materiais e critérios de aceitação permitem construir, verificar e manter o projeto com rastreabilidade.',
          [
            Question(
              id: 'projetos-manutencao-1-1',
              topic: 'Documentação de projeto',
              prompt: 'Um requisito verificável deve permitir:',
              options: ['Avaliar objetivamente se foi atendido', 'Interpretação ilimitada sem critério', 'Dispensar qualquer teste', 'Eliminar documentação'],
              correctIndex: 0,
              explanation: 'Critérios mensuráveis ou observáveis tornam possível verificar o requisito.',
            ),
            Question(
              id: 'projetos-manutencao-1-2',
              topic: 'Documentação de projeto',
              prompt: 'Qual documento relaciona os componentes previstos para montagem?',
              options: ['Mapa meteorológico', 'Lista de materiais', 'Somente o calendário', 'Folha de presença'],
              correctIndex: 1,
              explanation: 'A lista de materiais identifica itens, quantidades e especificações necessários.',
            ),
          ],
        ),
        CurriculumLesson(
          'Manutenção preventiva e preditiva',
          'A preventiva pode seguir intervalos ou uso planejado. A preditiva acompanha condições do equipamento para orientar intervenções antes de falhas, respeitando limites e métodos adequados.',
          [
            Question(
              id: 'projetos-manutencao-2-1',
              topic: 'Manutenção preventiva e preditiva',
              prompt: 'Qual exemplo representa manutenção baseada em condição?',
              options: ['Esperar sempre pela quebra', 'Escolher datas aleatórias', 'Acompanhar vibração e intervir conforme tendência e limites definidos', 'Trocar toda peça diariamente sem análise'],
              correctIndex: 2,
              explanation: 'O monitoramento de condição utiliza evidências do estado do ativo para orientar a intervenção.',
            ),
            Question(
              id: 'projetos-manutencao-2-2',
              topic: 'Manutenção preventiva e preditiva',
              prompt: 'Uma troca programada a cada determinado número de horas é tipicamente:',
              options: ['Somente corretiva emergencial', 'Ausência de manutenção', 'Calibração obrigatoriamente', 'Manutenção preventiva'],
              correctIndex: 3,
              explanation: 'A manutenção preventiva pode ser definida por tempo de funcionamento ou uso.',
            ),
          ],
        ),
        CurriculumLesson(
          'Diagnóstico de falhas',
          'Diagnóstico organiza sintomas, hipóteses e testes. Confirmar uma causa exige evidência; trocar componentes sem verificação pode ocultar a origem do problema.',
          [
            Question(
              id: 'projetos-manutencao-3-1',
              topic: 'Diagnóstico de falhas',
              prompt: 'Após observar um sintoma, qual próximo passo ajuda no diagnóstico?',
              options: ['Formular hipóteses e definir testes que as distingam', 'Trocar todos os componentes sem medir', 'Apagar todos os registros', 'Ignorar as condições de ocorrência'],
              correctIndex: 0,
              explanation: 'Testes orientados por hipóteses ajudam a localizar a causa com evidências.',
            ),
            Question(
              id: 'projetos-manutencao-3-2',
              topic: 'Diagnóstico de falhas',
              prompt: 'Por que registrar condições e medições durante uma falha?',
              options: ['Para substituir a especificação do equipamento', 'Para apoiar reprodução e análise da causa', 'Para garantir que a falha nunca existiu', 'Para dispensar a inspeção'],
              correctIndex: 1,
              explanation: 'Registros permitem comparar condições, verificar hipóteses e avaliar ações corretivas.',
            ),
          ],
        ),
      ],
    ),
    CurriculumDiscipline(
      'qualidade-gestao-ambiente', 'Qualidade, gestão e meio ambiente', MedalIcon.installation, [
        CurriculumLesson(
          'Ferramentas da qualidade',
          'Indicadores ajudam a acompanhar resultados. O ciclo PDCA organiza planejamento, execução, verificação e ação de melhoria; análise de causa busca entender a origem dos problemas.',
          [
            Question(
              id: 'qualidade-gestao-ambiente-1-1',
              topic: 'Ferramentas da qualidade',
              prompt: 'Qual é a ordem usual do PDCA?',
              options: ['Planejar, executar, verificar e agir', 'Executar, apagar, repetir e encerrar', 'Comprar, vender, medir e transportar', 'Inspecionar, ignorar, produzir e descartar'],
              correctIndex: 0,
              explanation: 'PDCA significa Plan, Do, Check, Act.',
            ),
            Question(
              id: 'qualidade-gestao-ambiente-1-2',
              topic: 'Ferramentas da qualidade',
              prompt: 'Em um lote de 200 peças, 10 são não conformes. Qual a taxa de não conformidade?',
              options: ['0,5%', '5%', '10%', '20%'],
              correctIndex: 1,
              explanation: '10/200 = 0,05 = 5%.',
            ),
          ],
        ),
        CurriculumLesson(
          'Gestão de projetos',
          'Escopo, prazo, custo e riscos precisam ser acompanhados de forma conjunta. Dependências entre tarefas influenciam a sequência e mudanças devem ter seus impactos avaliados.',
          [
            Question(
              id: 'qualidade-gestao-ambiente-2-1',
              topic: 'Gestão de projetos',
              prompt: 'Uma tarefa B só pode começar após terminar A. Essa relação é uma:',
              options: ['Forma de aterramento', 'Garantia de atraso obrigatório', 'Dependência entre tarefas', 'Medição de tensão'],
              correctIndex: 2,
              explanation: 'A relação estabelece uma condição de precedência para o início de B.',
            ),
            Question(
              id: 'qualidade-gestao-ambiente-2-2',
              topic: 'Gestão de projetos',
              prompt: 'Ao alterar o escopo de um projeto, o adequado é:',
              options: ['Assumir que nada será afetado', 'Eliminar automaticamente todos os testes', 'Ignorar os responsáveis', 'Avaliar impactos sobre prazo, custo, riscos e entregas'],
              correctIndex: 3,
              explanation: 'Mudanças podem afetar recursos, requisitos e compromissos do projeto.',
            ),
          ],
        ),
        CurriculumLesson(
          'Sustentabilidade',
          'Reduzir desperdícios e consumo de recursos ajuda a diminuir impactos ambientais. Indicadores devem comparar situações equivalentes e considerar produção e condições de operação.',
          [
            Question(
              id: 'qualidade-gestao-ambiente-3-1',
              topic: 'Sustentabilidade',
              prompt: 'Uma melhoria reduz o consumo de 100 kWh para 80 kWh para a mesma produção. Qual a economia percentual?',
              options: ['20%', '80%', '25%', '10%'],
              correctIndex: 0,
              explanation: '(100 − 80)/100 = 0,20 = 20%.',
            ),
            Question(
              id: 'qualidade-gestao-ambiente-3-2',
              topic: 'Sustentabilidade',
              prompt: 'Qual prática contribui para reduzir desperdício de material?',
              options: ['Descartar todo material novo', 'Planejar cortes e reaproveitar sobras adequadas', 'Misturar resíduos sem critério', 'Produzir refugos deliberadamente'],
              correctIndex: 1,
              explanation: 'Planejamento e reaproveitamento adequado reduzem perdas e consumo de matéria-prima.',
            ),
          ],
        ),
      ],
    ),
  ];

  static final List<Quiz> lessons = [
    for (final discipline in disciplines)
      for (var i = 0; i < discipline.lessons.length; i++)
        Quiz(
          id: 'q-${discipline.id}-${i + 1}',
          title: discipline.lessons[i].title,
          topic: discipline.title,
          rewardXp: 30,
          questions: discipline.lessons[i].questions,
        ),
  ];

  static final List<Quiz> exams = [
    for (final discipline in disciplines)
      Quiz(
        id: 'q-${discipline.id}-final',
        title: 'Prova final — ${discipline.title}',
        topic: discipline.title,
        rewardXp: 300,
        badgeId: 'dominio-${discipline.id}',
        questions: [
          for (final lesson in discipline.lessons) ...lesson.questions,
        ],
      ),
  ];

  static final List<Trail> trails = [
    for (final discipline in disciplines)
      Trail(
        id: discipline.id,
        title: discipline.title,
        modules: [
          for (var i = 0; i < discipline.lessons.length; i++)
            TrailModule(
              id: '${discipline.id}-${i + 1}',
              order: i + 1,
              title: discipline.lessons[i].title,
              subtitle: 'Resumo e atividade introdutória',
              lessonText: discipline.lessons[i].summary,
              status: i == 0 ? ModuleStatus.current : ModuleStatus.locked,
              quizId: 'q-${discipline.id}-${i + 1}',
            ),
          TrailModule(
            id: '${discipline.id}-final',
            order: discipline.lessons.length + 1,
            title: 'Prova final da trilha',
            subtitle: 'Revisão dos módulos · mínimo de 70% para concluir',
            status: ModuleStatus.locked,
            quizId: 'q-${discipline.id}-final',
            isFinalExam: true,
          ),
        ],
      ),
  ];

  static final List<Medal> medals = [
    for (final discipline in disciplines)
      Medal(
        id: 'dominio-${discipline.id}',
        name: 'Domínio em ${discipline.title}',
        discipline: discipline.title,
        description: 'Todos os módulos e a prova final de ${discipline.title} com pelo menos 70% de acerto',
        icon: discipline.icon,
      ),
  ];
}
