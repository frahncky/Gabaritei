import '../../domain/models/content.dart';

/// Enunciados próprios para prática e avaliação. As listas não se misturam.
class BankItem {
  const BankItem(this.prompt, this.answer, this.distractors, this.explanation);
  final String prompt;
  final String answer;
  final List<String> distractors;
  final String explanation;

  Question question(String id, String topic, int position) {
    // Distribui o gabarito sem mudar o vínculo entre resposta e alternativa.
    final options = [answer, ...distractors];
    final shift = position % options.length;
    final rotated = [...options.skip(options.length - shift),
      ...options.take(options.length - shift)];
    return Question(
      id: id,
      topic: topic,
      prompt: prompt,
      options: List.unmodifiable(rotated),
      correctIndex: shift,
      explanation: explanation,
    );
  }
}

class ExpandedQuestionBank {
  ExpandedQuestionBank._();

  static const revision = '2026.10.30.2';

  static const practice = <String, List<BankItem>>{
    'eb-1': [
      BankItem(
        'Um dispositivo transfere 30 C em 5 s. Qual a corrente média?',
        '6 A',
        ['150 A', '0,167 A', '25 A'],
        'I = ΔQ/Δt = 30/5 = 6 A.',
      ),
      BankItem(
        'Um componente dissipa 18 W sob 9 V em CC. Qual a corrente?',
        '2 A',
        ['162 A', '0,5 A', '27 A'],
        'P = VI; I = 18/9 = 2 A. A resistência não é necessária para este cálculo.',
      ),
    ],
    'eb-2': [
      BankItem(
        'Um resistor de 330 Ω deve conduzir 20 mA. Qual tensão precisa ser aplicada?',
        '6,6 V',
        ['6600 V', '0,066 V', '16,5 V'],
        'Converta 20 mA para 0,020 A. V = RI = 330 × 0,020 = 6,6 V.',
      ),
      BankItem(
        'Um resistor ôhmico conduz 0,3 A sob 6 V. Se a tensão cair para 2 V sem alterar R, qual será a corrente?',
        '0,1 A',
        ['0,9 A', '0,3 A', '3 A'],
        'R = 6/0,3 = 20 Ω. Com 2 V, I = 2/20 = 0,1 A.',
      ),
    ],
    'eb-3': [
      BankItem(
        'Um aquecedor de 1500 W opera 40 minutos por dia. Qual energia consome em 30 dias?',
        '30 kWh',
        ['1800 kWh', '20 kWh', '45 kWh'],
        '40 min = 2/3 h. E = 1,5 kW × (2/3) h × 30 = 30 kWh.',
      ),
      BankItem(
        'Um resistor de 100 Ω conduz 0,2 A. Qual a potência dissipada?',
        '4 W',
        ['20 W', '0,4 W', '40 W'],
        'P = RI² = 100 × 0,2² = 4 W.',
      ),
    ],
    'eb-4': [
      BankItem(
        'Três resistores iguais de 90 Ω são conectados em paralelo. Qual a resistência equivalente?',
        '30 Ω',
        ['270 Ω', '90 Ω', '45 Ω'],
        'Para n resistores iguais em paralelo, Req = R/n = 90/3 = 30 Ω.',
      ),
      BankItem(
        'Um resistor de 10 Ω está em série com dois de 20 Ω em paralelo. Qual a resistência equivalente?',
        '20 Ω',
        ['50 Ω', '30 Ω', '5 Ω'],
        'Os dois de 20 Ω em paralelo equivalem a 10 Ω. Em série com 10 Ω, o total é 20 Ω.',
      ),
    ],
    'eb-5': [
      BankItem(
        'Adotando correntes de saída positivas, um nó recebe 4 A e possui um ramo com saída de 7 A. Qual o valor algébrico da terceira corrente?',
        '−3 A',
        ['3 A', '11 A', '−11 A'],
        '−4 + 7 + I = 0, então I = −3 A. O sinal indica entrada de 3 A, contrária à referência.',
      ),
      BankItem(
        'Uma malha contém fonte de 24 V e resistores em série de 4 Ω e 8 Ω. Qual a corrente?',
        '2 A',
        ['6 A', '3 A', '0,5 A'],
        'Pela lei das malhas, 24 − 4I − 8I = 0. Logo I = 24/12 = 2 A.',
      ),
    ],
    'eb-6': [
      BankItem(
        'Um divisor sem carga usa R1 = 3 kΩ e R2 = 1 kΩ, com saída sobre R2 e entrada de 12 V. Qual a saída?',
        '3 V',
        ['9 V', '4 V', '12 V'],
        'Vout = 12 × 1/(3+1) = 3 V.',
      ),
      BankItem(
        'Dois ramos de 4 Ω e 12 Ω em paralelo recebem corrente total de 8 A. Quanto passa pelo ramo de 4 Ω?',
        '6 A',
        ['2 A', '4 A', '8 A'],
        'I4 = Itotal × 12/(4+12) = 8 × 12/16 = 6 A. O ramo menos resistivo conduz mais.',
      ),
    ],
    'ea-1': [
      BankItem(
        'Em uma junção PN sem polarização externa, a região de depleção é caracterizada por:',
        'Escassez de portadores móveis e presença de cargas fixas',
        ['Corrente infinita permanente', 'Ausência de campo elétrico em qualquer ponto', 'Uma camada de cobre metálico'],
        'A difusão inicial deixa íons fixos e forma o campo da junção; a região fica pobre em portadores móveis.',
      ),
      BankItem(
        'Aumentar a dopagem de um semicondutor, em condições comparáveis, tende a:',
        'Aumentar a concentração de portadores e reduzir a resistividade',
        ['Transformá-lo obrigatoriamente em isolante ideal', 'Zerar a temperatura', 'Eliminar qualquer dependência térmica'],
        'A dopagem controla a concentração de portadores. Mais portadores disponíveis podem elevar a condutividade.',
      ),
    ],
    'ea-2': [
      BankItem(
        'Uma fonte de 10 V alimenta um resistor de 1 kΩ e um diodo em série. Adote queda direta de 0,7 V. Qual a corrente?',
        '9,3 mA',
        ['10,7 mA', '0,7 mA', '93 mA'],
        'O resistor recebe 10 − 0,7 = 9,3 V. I = 9,3/1000 = 9,3 mA.',
      ),
      BankItem(
        'Uma ponte monofásica de onda completa é alimentada a 60 Hz. Qual é a frequência fundamental da ondulação antes da filtragem?',
        '120 Hz',
        ['60 Hz', '30 Hz', '240 Hz'],
        'A retificação de onda completa produz dois pulsos por ciclo de entrada: 2 × 60 = 120 Hz.',
      ),
    ],
    'ea-3': [
      BankItem(
        'Um BJT em região ativa possui β = 100 e corrente de base de 20 µA. Qual a corrente de coletor no modelo IC = βIB?',
        '2 mA',
        ['0,2 mA', '20 mA', '200 mA'],
        'IC = 100 × 20 µA = 2000 µA = 2 mA, enquanto o transistor permanecer na região ativa.',
      ),
      BankItem(
        'Para usar um BJT como chave fechada no modelo didático, busca-se tipicamente:',
        'Operação em saturação',
        ['Corte', 'Junções sempre abertas', 'Corrente de base rigorosamente nula'],
        'Na saturação, a queda coletor-emissor é pequena no modelo de chaveamento.',
      ),
    ],
    'ea-4': [
      BankItem(
        'Um amplificador não inversor ideal usa Rf = 30 kΩ e Rg = 10 kΩ. Qual seu ganho?',
        '4',
        ['3', '−3', '0,25'],
        'No não inversor, Av = 1 + Rf/Rg = 1 + 30/10 = 4.',
      ),
      BankItem(
        'Um amplificador ideal com ganho linear 10 e alimentação ±12 V recebe entrada de 2 V. A saída linear calculada é 20 V. O que ocorre em um dispositivo real?',
        'A saída satura nos limites permitidos pela alimentação e pelo dispositivo',
        ['A saída necessariamente chega a 20 V sem outra fonte', 'O ganho se torna infinito', 'A tensão de alimentação dobra automaticamente'],
        'A realimentação não permite exceder os limites de excursão de saída; o modelo linear deixa de valer na saturação.',
      ),
    ],
    'ea-5': [
      BankItem(
        'Um filtro RC possui R = 1 kΩ e C = 1 µF. Qual a frequência de corte aproximada?',
        '159 Hz',
        ['1 Hz', '1000 Hz', '6,28 kHz'],
        'fc = 1/(2πRC) = 1/(2π × 1000 × 10⁻⁶) ≈ 159 Hz.',
      ),
      BankItem(
        'Em um passa-altas RC com saída no resistor, a tensão de saída em regime permanente para entrada CC ideal é:',
        'Zero',
        ['Igual à entrada necessariamente', 'Infinita', 'Metade da entrada em qualquer RC'],
        'Em regime permanente CC, o capacitor em série bloqueia a corrente ideal; sem corrente, a queda no resistor é zero.',
      ),
    ],
    'ed-1': [
      BankItem(
        'Qual é o resultado de 0111₂ + 0001₂ em 4 bits, sem sinal?',
        '1000₂',
        ['0110₂', '1111₂', '0000₂'],
        '7 + 1 = 8; a representação binária de 8 em 4 bits é 1000.',
      ),
      BankItem(
        'Qual valor decimal representa 2A em hexadecimal?',
        '42',
        ['26', '32', '210'],
        '2A₁₆ = 2 × 16 + 10 = 42.',
      ),
    ],
    'ed-2': [
      BankItem(
        'Uma porta NAND de duas entradas recebe 1 e 1. Qual é sua saída?',
        '0',
        ['1', '2', 'Alta impedância obrigatória'],
        'NAND é a negação de AND: NÃO(1 E 1) = 0.',
      ),
      BankItem(
        'Uma porta OR recebe 0 e 1. Qual é a saída?',
        '1',
        ['0', 'Indefinida', 'Alta impedância'],
        'OR vale 1 quando pelo menos uma entrada é 1.',
      ),
    ],
    'ed-3': [
      BankItem(
        'Qual é a forma simplificada de A·B + A·NÃO B?',
        'A',
        ['B', 'NÃO A', 'A·B'],
        'Fatore A: A(B + NÃO B) = A·1 = A.',
      ),
      BankItem(
        'Um decodificador binário de 3 entradas pode selecionar até quantas saídas distintas?',
        '8',
        ['3', '6', '9'],
        'Três bits representam 2³ = 8 combinações de entrada.',
      ),
    ],
    'ed-4': [
      BankItem(
        'Um flip-flop D é acionado na borda de subida. Na borda, D = 1. Qual será Q após o tempo de propagação, sem reset ativo?',
        '1',
        ['0 sempre', 'O complemento de D', 'Uma tensão analógica arbitrária'],
        'Na borda ativa, o flip-flop D registra o valor lógico presente na entrada D.',
      ),
      BankItem(
        'Qual o número mínimo de bits para representar 12 estados distintos?',
        '4',
        ['3', '6', '12'],
        '3 bits representam 8 estados, insuficientes. 4 bits representam 16 estados, suficientes para 12.',
      ),
    ],
    'ie-1': [
      BankItem(
        'Em um diagrama, um ponto de conexão entre dois condutores indica:',
        'Conexão elétrica no ponto segundo a convenção do desenho',
        ['Cruzamento obrigatoriamente sem ligação', 'Um fusível em qualquer norma', 'Uma medição de potência'],
        'Pontos e cruzamentos devem ser lidos conforme a convenção e legenda; o ponto de junção indica ligação.',
      ),
      BankItem(
        'Por que identificar circuitos com códigos consistentes na planta e no quadro?',
        'Para relacionar pontos, proteções e documentação do mesmo circuito',
        ['Para dispensar a legenda', 'Para aumentar automaticamente a corrente admissível', 'Para eliminar a necessidade de manutenção'],
        'A identificação permite localizar e correlacionar elementos na execução, operação e manutenção.',
      ),
    ],
    'ie-2': [
      BankItem(
        'Mantendo material e seção, dobrar o comprimento de um condutor provoca qual mudança em sua resistência?',
        'A resistência dobra',
        ['A resistência cai à metade', 'A resistência não muda', 'A resistência fica negativa'],
        'R = ρL/A. Com ρ e A constantes, R é diretamente proporcional a L.',
      ),
      BankItem(
        'Um circuito CC tem queda de 2,4 V numa alimentação de 120 V. Qual a queda percentual?',
        '2%',
        ['20%', '0,2%', '5%'],
        'ΔV% = 100 × 2,4/120 = 2%. Esse cálculo não determina sozinho se o projeto atende aos critérios aplicáveis.',
      ),
    ],
    'ie-3': [
      BankItem(
        'Por que um fusível não deve ser substituído apenas por outro de corrente nominal muito maior?',
        'A proteção pode deixar de ser compatível com os condutores e equipamentos',
        ['Porque toda corrente maior é sempre mais segura', 'Porque a tensão de rede necessariamente aumenta', 'Porque o consumo é zerado'],
        'A coordenação da proteção considera características do circuito; aumentar a corrente nominal sem avaliação pode comprometer a proteção.',
      ),
      BankItem(
        'Um dispositivo diferencial e um disjuntor de sobrecorrente têm exatamente a mesma função?',
        'Não; respondem a condições diferentes e podem ser complementares',
        ['Sim, sem exceção', 'Sim, ambos medem somente temperatura ambiente', 'Não, pois nenhum atua automaticamente'],
        'O diferencial avalia desequilíbrio de correntes; a proteção de sobrecorrente responde à corrente acima dos seus critérios.',
      ),
    ],
    'ie-4': [
      BankItem(
        'Em um comando convencional de parada, por que se usa um contato normalmente fechado no botão de desligamento?',
        'A abertura do circuito de comando desenergiza a bobina',
        ['Para impedir qualquer desligamento', 'Para aumentar a potência do motor', 'Para substituir o contator por um resistor'],
        'O comando de parada interrompe o caminho de alimentação da bobina; isso não equivale por si só a uma função de segurança certificada.',
      ),
      BankItem(
        'Qual contato auxiliar é usado no selo convencional de um contator?',
        'Normalmente aberto, comandado pelo próprio contator',
        ['Sempre um contato de outro circuito sem vínculo', 'Normalmente fechado em paralelo à proteção', 'Qualquer sensor analógico sem adaptação'],
        'Ao energizar o contator, o contato auxiliar NA fecha e mantém o caminho de retenção.',
      ),
    ],
    'clp-1': [
      BankItem(
        'Uma lógica Ladder possui contato A em série com ramos paralelos B e C. Qual expressão representa a saída?',
        'A E (B OU C)',
        ['A OU (B E C)', 'NÃO A', 'A E B E C'],
        'O contato em série exige A; os caminhos paralelos permitem B ou C.',
      ),
      BankItem(
        'Na lógica Y = A E NÃO B, qual é Y para A = 1 e B = 1?',
        '0',
        ['1', '2', 'Depende obrigatoriamente do endereço IP'],
        'NÃO B = 0; 1 E 0 = 0.',
      ),
    ],
    'clp-2': [
      BankItem(
        'Uma entrada muda imediatamente após a leitura das entradas em um CLP com imagem de processo. No modelo básico, quando essa mudança será lida?',
        'Na próxima atualização da imagem de entradas',
        ['Antes da mudança ocorrer', 'Nunca, em qualquer CLP', 'Somente após recompilar o programa'],
        'No modelo cíclico com imagem de processo, a lógica usa a imagem lida; a mudança posterior é capturada na atualização seguinte.',
      ),
      BankItem(
        'Um ciclo de varredura leva 5 ms, de forma constante. Aproximadamente quantos ciclos ocorrem por segundo?',
        '200',
        ['5', '50', '5000'],
        '1 s / 0,005 s = 200 ciclos por segundo.',
      ),
    ],
    'clp-3': [
      BankItem(
        'Um TON é configurado para 5 s. Sua entrada fica ativa por 3 s e volta a zero. Em um TON não retentivo, a saída de término chegou a ativar?',
        'Não',
        ['Sim, aos 3 s', 'Sim, imediatamente sempre', 'Sim, depois de desligar a entrada independentemente de nova ativação'],
        'A entrada não permaneceu ativa pelo tempo configurado; o TON não retentivo não completa os 5 s.',
      ),
      BankItem(
        'Um contador conta bordas de subida. A entrada fica em 1 durante dez varreduras sem novas transições. Quantos eventos essa permanência representa?',
        'Um, na transição inicial de 0 para 1',
        ['Dez, um por varredura obrigatoriamente', 'Zero em qualquer caso', 'Cem'],
        'Um contador por borda registra a transição, não cada varredura em que o nível permanece alto.',
      ),
    ],
    'clp-4': [
      BankItem(
        'Uma entrada de 0–10 V representa linearmente 0–500 rpm. Qual velocidade corresponde a 6 V?',
        '300 rpm',
        ['60 rpm', '600 rpm', '200 rpm'],
        '6/10 = 0,6 da escala; 0,6 × 500 = 300 rpm.',
      ),
      BankItem(
        'Um transmissor de 4–20 mA mede 0–10 bar. Qual corrente corresponde a 2,5 bar?',
        '8 mA',
        ['4 mA', '10 mA', '12 mA'],
        'A fração é 2,5/10 = 0,25. I = 4 + 16 × 0,25 = 8 mA.',
      ),
    ],
    'circuitos-cc-1': [
      BankItem(
        'Um resistor de 5 Ω em série com outro de 15 Ω recebe corrente de 0,4 A. Qual a tensão total?',
        '8 V',
        ['4 V', '20 V', '50 V'],
        'Req = 20 Ω. V = 20 × 0,4 = 8 V.',
      ),
      BankItem(
        'Dois resistores de 12 Ω em paralelo recebem 24 V. Qual a potência total?',
        '96 W',
        ['48 W', '24 W', '192 W'],
        'Cada ramo conduz 2 A; a corrente total é 4 A. P = 24 × 4 = 96 W.',
      ),
    ],
    'circuitos-cc-2': [
      BankItem(
        'Um nó recebe 12 A e 3 A. Dele saem três correntes iguais. Qual o valor de cada uma?',
        '5 A',
        ['3 A', '9 A', '15 A'],
        'A entrada total é 15 A. Como as três saídas são iguais, cada uma vale 15/3 = 5 A.',
      ),
      BankItem(
        'Uma fonte de 18 V alimenta em série 3 Ω e um resistor desconhecido. A corrente é 2 A. Qual o resistor desconhecido?',
        '6 Ω',
        ['9 Ω', '12 Ω', '3 Ω'],
        'Pela malha: 18 − 3×2 − R×2 = 0. Assim R = 6 Ω.',
      ),
    ],
    'circuitos-cc-3': [
      BankItem(
        'Na descarga ideal de um capacitor em um RC, após uma constante de tempo a tensão vale aproximadamente qual fração do valor inicial?',
        '36,8%',
        ['63,2%', '100%', '0%'],
        'Na descarga, v(t) = V0·e^(−t/τ). Para t = τ, e⁻¹ ≈ 0,368.',
      ),
      BankItem(
        'A tensão de um capacitor ideal pode mudar instantaneamente com corrente finita?',
        'Não',
        ['Sim, sempre', 'Somente por estar carregado', 'Somente se a capacitância for constante'],
        'i = C·dv/dt. Um salto instantâneo de tensão exigiria corrente impulsiva no modelo ideal.',
      ),
    ],
    'circuitos-ca-1': [
      BankItem(
        'Uma senoide tem frequência de 25 Hz. Qual seu período?',
        '40 ms',
        ['25 ms', '4 ms', '400 ms'],
        'T = 1/25 = 0,04 s = 40 ms.',
      ),
      BankItem(
        'Duas senoides de mesma frequência têm defasagem temporal de um quarto de período. Qual o módulo do ângulo entre elas?',
        '90°',
        ['45°', '180°', '360°'],
        'φ = 360°·Δt/T = 360°/4 = 90°.',
      ),
    ],
    'circuitos-ca-2': [
      BankItem(
        'Um capacitor tem reatância de 100 Ω em certa frequência. Ao dobrar a frequência, mantendo C, qual será XC?',
        '50 Ω',
        ['200 Ω', '100 Ω', '400 Ω'],
        'XC = 1/(2πfC). Ao dobrar f, XC cai à metade.',
      ),
      BankItem(
        'Um circuito série possui R = 6 Ω, XL = 12 Ω e XC = 4 Ω. Qual |Z|?',
        '10 Ω',
        ['22 Ω', '14 Ω', '2 Ω'],
        'X = 12 − 4 = 8 Ω. |Z| = √(6²+8²) = 10 Ω.',
      ),
    ],
    'circuitos-ca-3': [
      BankItem(
        'Uma carga senoidal monofásica tem P = 400 W e Q = 300 var. Qual sua potência aparente?',
        '500 VA',
        ['700 VA', '100 VA', '120000 VA'],
        'S = √(P²+Q²) = √(400²+300²) = 500 VA.',
      ),
      BankItem(
        'Mantendo a potência ativa e a tensão, elevar o fator de potência de uma carga senoidal provoca qual tendência na corrente eficaz?',
        'Redução',
        ['Aumento obrigatório', 'Nenhuma mudança possível', 'Inversão obrigatória de sentido'],
        'I = P/(V·fp). Para P e V fixos, elevar fp reduz a corrente.',
      ),
    ],
    'eletronica-potencia-1': [
      BankItem(
        'Em um retificador controlado, o ângulo de disparo é medido em relação a:',
        'Uma referência de fase da alimentação',
        ['À cor do dissipador', 'Ao comprimento do cabo apenas', 'À temperatura em graus Celsius'],
        'O disparo é sincronizado a uma referência angular da forma de onda de entrada.',
      ),
      BankItem(
        'Depois de disparado, um SCR convencional é desligado apenas retirando o sinal de gate em qualquer condição?',
        'Não',
        ['Sim, sempre', 'Sim, mesmo com corrente acima da manutenção', 'Sim, pois o gate é o único caminho da corrente principal'],
        'O gate de um SCR convencional não comanda o desligamento como em um MOSFET; é preciso atingir as condições de comutação.',
      ),
    ],
    'eletronica-potencia-2': [
      BankItem(
        'Um buck ideal em condução contínua recebe 40 V e opera com D = 0,3. Qual Vout?',
        '12 V',
        ['120 V', '28 V', '0,75 V'],
        'Vout = D·Vin = 0,3 × 40 = 12 V.',
      ),
      BankItem(
        'Um boost ideal em condução contínua recebe 12 V e tem D = 0,5. Qual Vout?',
        '24 V',
        ['6 V', '12 V', '18 V'],
        'No boost ideal, Vout = Vin/(1−D) = 12/0,5 = 24 V.',
      ),
    ],
    'eletronica-potencia-3': [
      BankItem(
        'Um inversor produz frequência de 50 Hz para uma máquina de 4 polos. Qual a velocidade síncrona?',
        '1500 rpm',
        ['3000 rpm', '1200 rpm', '750 rpm'],
        'ns = 120f/p = 120 × 50/4 = 1500 rpm.',
      ),
      BankItem(
        'Em uma ponte inversora, por que é usado tempo morto entre chaves complementares do mesmo braço?',
        'Para reduzir o risco de condução simultânea que curto-circuite o barramento',
        ['Para obrigar todas as chaves a ficarem sempre ligadas', 'Para remover a necessidade de proteção', 'Para duplicar a tensão da bateria automaticamente'],
        'O intervalo evita sobreposição indevida de condução entre chaves complementares.',
      ),
    ],
    'seguranca-normas-1': [
      BankItem(
        'Uma tarefa mudou de local e passou a envolver outra fonte de energia. A avaliação anterior deve ser:',
        'Reavaliada para as novas condições',
        ['Aceita sem revisão em qualquer caso', 'Substituída pela experiência pessoal apenas', 'Descartada junto das proteções'],
        'Mudanças de condições podem introduzir perigos não contemplados na análise anterior.',
      ),
      BankItem(
        'Qual situação deve motivar interrupção e reavaliação de uma atividade?',
        'Uma condição de risco não prevista',
        ['Uma legenda legível', 'Documentação coerente', 'Instrumento adequado e íntegro'],
        'Uma condição não prevista exige reavaliar riscos e controles antes de prosseguir.',
      ),
    ],
    'seguranca-normas-2': [
      BankItem(
        'Um sistema possui alimentação principal e fonte auxiliar. Desligar apenas a principal permite concluir que toda a instalação está sem energia?',
        'Não; todas as fontes e condições devem ser consideradas',
        ['Sim, independentemente da auxiliar', 'Sim, se houver uma lâmpada apagada', 'Sim, sem verificar'],
        'Fontes auxiliares e retornos podem manter partes energizadas.',
      ),
      BankItem(
        'Qual registro contribui para o controle de um bloqueio de energia?',
        'Identificação do ponto, responsável e condição de bloqueio conforme procedimento',
        ['Somente a cor da parede', 'A potência nominal do monitor', 'O tamanho da sala sem identificar fontes'],
        'Identificação e rastreabilidade apoiam o controle do estado das fontes durante o trabalho.',
      ),
    ],
    'seguranca-normas-3': [
      BankItem(
        'Uma carcaça metálica acessível pode ficar energizada por falha de isolamento. O projeto deve considerar:',
        'Medidas de proteção contra contato indireto adequadas ao sistema',
        ['Somente pintura decorativa', 'Remover todas as proteções', 'Usar a carcaça como condutor ativo normal'],
        'Falhas que energizam massas acessíveis precisam ser consideradas no esquema de proteção.',
      ),
      BankItem(
        'A existência de aterramento comprova que qualquer intervenção energizada é segura?',
        'Não',
        ['Sim, sempre', 'Sim, dispensando autorização', 'Sim, dispensando análise de risco'],
        'O aterramento integra a proteção e não elimina todos os perigos nem substitui procedimentos.',
      ),
    ],
    'maquinas-eletricas-1': [
      BankItem(
        'Um transformador ideal abaixa de 200 V para 50 V. Se o secundário fornece 4 A, qual a corrente primária?',
        '1 A',
        ['16 A', '4 A', '0,25 A'],
        'A potência ideal é conservada: 50×4 = 200 W. I1 = 200/200 = 1 A.',
      ),
      BankItem(
        'Por que um transformador convencional não opera em regime permanente com alimentação CC constante como em CA?',
        'A tensão induzida depende da variação do fluxo magnético',
        ['Porque não possui enrolamentos', 'Porque CC não produz corrente em cobre', 'Porque toda tensão CC é nula'],
        'Sem a variação de fluxo requerida, o funcionamento e as correntes não correspondem ao regime de projeto em CA.',
      ),
    ],
    'maquinas-eletricas-2': [
      BankItem(
        'Um motor tem velocidade síncrona de 1200 rpm e escorregamento de 4%. Qual sua rotação?',
        '1152 rpm',
        ['1248 rpm', '480 rpm', '1160 rpm'],
        'n = ns(1−s) = 1200 × 0,96 = 1152 rpm.',
      ),
      BankItem(
        'Um motor de indução acionando carga em regime motor usual apresenta escorregamento:',
        'Positivo',
        ['Sempre zero', 'Sempre negativo', 'Sempre maior que 100%'],
        'Nesse regime, n < ns; então s = (ns−n)/ns > 0.',
      ),
    ],
    'maquinas-eletricas-3': [
      BankItem(
        'Um motor CC tem torque T = kΦIa. Mantendo Φ constante, dobrar Ia provoca qual tendência ideal em T?',
        'Dobrar',
        ['Cair à metade', 'Não mudar', 'Ficar obrigatoriamente nulo'],
        'No modelo, torque é diretamente proporcional à corrente de armadura.',
      ),
      BankItem(
        'Uma máquina síncrona de 6 polos gira sincronizada com uma rede de 60 Hz. Qual sua velocidade?',
        '1200 rpm',
        ['1800 rpm', '3600 rpm', '600 rpm'],
        'ns = 120 × 60/6 = 1200 rpm.',
      ),
    ],
    'robotica-1': [
      BankItem(
        'A cinemática inversa procura determinar:',
        'Variáveis das juntas para uma pose desejada do efetuador',
        ['Somente a corrente da fonte', 'O peso do cabo de rede', 'A taxa de transmissão do encoder'],
        'O problema inverso parte da pose desejada e procura configurações articulares possíveis.',
      ),
      BankItem(
        'Um robô planar tem duas juntas rotativas independentes. Quantas variáveis articulares independentes ele possui?',
        'Duas',
        ['Uma', 'Quatro obrigatoriamente', 'Seis obrigatoriamente'],
        'Cada junta rotativa independente fornece uma coordenada angular.',
      ),
    ],
    'robotica-2': [
      BankItem(
        'Um encoder fornece 1000 pulsos por volta, sem multiplicação de contagem. Quantos pulsos correspondem a meia volta?',
        '500',
        ['1000', '2000', '250'],
        'Meia volta corresponde a metade de 1000 pulsos: 500.',
      ),
      BankItem(
        'Qual é a função da realimentação de posição em um servossistema?',
        'Comparar posição medida e desejada para corrigir o movimento',
        ['Eliminar todos os limites mecânicos', 'Substituir a fonte de alimentação', 'Garantir erro nulo sem ajuste em qualquer situação'],
        'A medição permite ao controlador estimar o erro e atuar sobre o movimento.',
      ),
    ],
    'robotica-3': [
      BankItem(
        'Uma ferramenta foi trocada por outra com geometria diferente. Qual informação de programação deve ser verificada?',
        'O referencial e o ponto da ferramenta, além da trajetória',
        ['Somente a cor do programa', 'A senha do monitor apenas', 'Nenhuma informação geométrica'],
        'Mudar a ferramenta pode alterar o ponto efetivo e a ocupação do espaço pelo conjunto.',
      ),
      BankItem(
        'Uma trajetória passa por um obstáculo no ambiente real. A ação adequada antes da execução é:',
        'Revisar e verificar o percurso e as condições de operação',
        ['Executar apenas mais rápido', 'Desativar todos os sensores', 'Ignorar a geometria da ferramenta'],
        'Verificar percurso, referências e ambiente ajuda a evitar movimentos incompatíveis com o espaço disponível.',
      ),
    ],
    'supervisorios-processos-1': [
      BankItem(
        'Em um controle proporcional u = Kp·e, com Kp = 2 e e = 3, qual é u antes de limites e termos adicionais?',
        '6',
        ['1,5', '5', '9'],
        'u = 2 × 3 = 6 nas unidades compatíveis com o ganho.',
      ),
      BankItem(
        'Ação derivativa é particularmente sensível a qual característica da medição?',
        'Ruído de alta frequência',
        ['Apenas seu nome textual', 'Somente a unidade escrita na tela', 'A cor da tubulação'],
        'Derivadas amplificam variações rápidas; por isso a ação derivativa requer cuidado com ruído e filtragem.',
      ),
    ],
    'supervisorios-processos-2': [
      BankItem(
        'Um gráfico mantém o último valor mesmo após perder comunicação. Qual informação precisa acompanhar esse valor?',
        'Seu instante de atualização e estado de comunicação',
        ['Somente uma cor decorativa', 'A marca do teclado', 'Uma animação sem relação com a medição'],
        'Sem indicação de validade e tempo, um valor antigo pode ser confundido com uma medição atual.',
      ),
      BankItem(
        'Um alarme foi reconhecido, mas a variável continua fora do limite. Qual afirmação é correta?',
        'A condição de alarme pode permanecer ativa',
        ['O processo está necessariamente normalizado', 'O sensor foi automaticamente calibrado', 'A leitura passa a ser sempre zero'],
        'O reconhecimento registra ciência; não remove por si só a condição de processo.',
      ),
    ],
    'supervisorios-processos-3': [
      BankItem(
        'Em uma malha de temperatura, uma resistência elétrica controlada varia a energia fornecida. Ela funciona como:',
        'Elemento final de atuação sobre a planta',
        ['Referência de temperatura obrigatoriamente', 'Sensor de temperatura apenas', 'Registro histórico'],
        'O elemento final modifica uma grandeza física para influenciar a variável controlada.',
      ),
      BankItem(
        'Uma malha utiliza medição de pressão para ajustar uma válvula. Se a medição falhar, o controle deve:',
        'Aplicar o tratamento de falha e o estado previsto no projeto',
        ['Tratar qualquer erro como pressão válida', 'Abrir a válvula totalmente em todo processo', 'Ignorar permanentemente o alarme'],
        'A resposta à falha depende dos requisitos e riscos do processo e deve ser definida no projeto.',
      ),
    ],
    'telecomunicacoes-1': [
      BankItem(
        'Em FM ideal de amplitude constante, a informação é transportada principalmente pela variação da:',
        'Frequência instantânea',
        ['Potência média necessariamente nula', 'Massa da antena', 'Resistência do receptor'],
        'A modulação FM altera a frequência instantânea de acordo com o sinal de informação.',
      ),
      BankItem(
        'Por que se utiliza uma portadora em um sistema modulado?',
        'Para transportar a informação em uma faixa adequada ao sistema de transmissão',
        ['Para eliminar toda necessidade de receptor', 'Para tornar o ruído impossível', 'Para substituir qualquer antena por resistência'],
        'A modulação desloca a informação para uma faixa compatível com o canal e a arquitetura do enlace.',
      ),
    ],
    'telecomunicacoes-2': [
      BankItem(
        'Num enlace de fibra, qual conversão é necessária na transmissão elétrica convencional para o meio óptico?',
        'Conversão eletro-óptica',
        ['Conversão de pressão em torque', 'Somente ampliação mecânica', 'Conversão de massa em tensão'],
        'Uma fonte óptica converte o sinal elétrico de informação em luz modulada.',
      ),
      BankItem(
        'Um cabo de cobre instalado próximo a fontes intensas de interferência pode exigir:',
        'Avaliação de blindagem, encaminhamento e compatibilidade eletromagnética',
        ['Remoção de todos os conectores', 'Aumento ilimitado do comprimento', 'Dispensar a especificação do enlace'],
        'O projeto deve considerar o ambiente eletromagnético e os limites do meio.',
      ),
    ],
    'telecomunicacoes-3': [
      BankItem(
        'Sem cabeçalhos, transmitir 24 kbit a 6 kbit/s leva quanto tempo?',
        '4 s',
        ['144 s', '0,25 s', '18 s'],
        't = 24/6 = 4 s, usando unidades coerentes.',
      ),
      BankItem(
        'Uma taxa de 8 Mbit/s equivale a quantos Mbyte/s, sem sobrecarga?',
        '1 Mbyte/s',
        ['8 Mbyte/s', '64 Mbyte/s', '0,125 Mbyte/s'],
        'Um byte contém 8 bits; 8 Mbit/s ÷ 8 = 1 Mbyte/s.',
      ),
    ],
    'programacao-1': [
      BankItem(
        'Um laço soma os números 1, 2, 3 e 4 a uma variável inicialmente zero. Qual o resultado?',
        '10',
        ['4', '6', '24'],
        'A soma é 1+2+3+4 = 10; não se trata do produto.',
      ),
      BankItem(
        'Em uma decisão se x > 10, para x = 10 a condição é:',
        'Falsa',
        ['Verdadeira', 'Sempre indefinida', 'Um valor de 10 volts'],
        'O operador > exclui a igualdade. Para incluir 10, seria necessário ≥.',
      ),
    ],
    'programacao-2': [
      BankItem(
        'Uma fila segue qual regra usual de retirada?',
        'Primeiro a entrar, primeiro a sair',
        ['Último a entrar, primeiro a sair', 'Sempre o maior número', 'Sempre o elemento central'],
        'Uma fila usual segue FIFO: First In, First Out.',
      ),
      BankItem(
        'Uma lista possui índices de 0 a 7. Qual sua quantidade de elementos?',
        '8',
        ['7', '6', '9'],
        'São oito posições: 0,1,2,3,4,5,6 e 7.',
      ),
    ],
    'programacao-3': [
      BankItem(
        'Uma função pode receber valor fora da faixa aceita. O que deve ser feito?',
        'Validar a entrada e tratar a condição conforme o contrato da função',
        ['Assumir sempre um valor válido', 'Ignorar todas as exceções', 'Alterar silenciosamente qualquer dado sem regra'],
        'A validação evita processar entradas incompatíveis e torna o comportamento definido.',
      ),
      BankItem(
        'Uma operação de rede nunca responde. Qual mecanismo evita espera indefinida no fluxo?',
        'Tempo limite com tratamento de falha',
        ['Um comentário no código apenas', 'Uma variável sem uso', 'Remoção dos testes'],
        'O timeout permite interromper a espera e executar a política de recuperação.',
      ),
    ],
    'matematica-fisica-1': [
      BankItem(
        'Resolva 5x − 10 = 15.',
        'x = 5',
        ['x = 1', 'x = 3', 'x = 25'],
        '5x = 25; logo x = 5.',
      ),
      BankItem(
        'Um vetor plano tem componentes 6 e 8. Qual seu módulo?',
        '10',
        ['14', '2', '48'],
        '|v| = √(6²+8²) = 10.',
      ),
    ],
    'matematica-fisica-2': [
      BankItem(
        'Uma força resultante de 12 N age numa massa de 3 kg. Qual a aceleração?',
        '4 m/s²',
        ['36 m/s²', '9 m/s²', '0,25 m/s²'],
        'a = F/m = 12/3 = 4 m/s².',
      ),
      BankItem(
        'Um trabalho de 120 J é realizado em 6 s. Qual a potência média?',
        '20 W',
        ['720 W', '126 W', '0,05 W'],
        'P = W/Δt = 120/6 = 20 W.',
      ),
    ],
    'matematica-fisica-3': [
      BankItem(
        'Uma onda tem comprimento de 2 m e frequência de 150 Hz. Qual sua velocidade?',
        '300 m/s',
        ['75 m/s', '152 m/s', '148 m/s'],
        'v = fλ = 150 × 2 = 300 m/s.',
      ),
      BankItem(
        'Se um fluxo magnético constante atravessa uma espira fixa ideal, qual a tensão induzida pela variação desse fluxo?',
        'Zero',
        ['Sempre infinita', 'Igual ao fluxo em volts', 'Sempre 1 V'],
        'A lei de Faraday depende de dΦ/dt. Para fluxo constante, essa derivada é zero.',
      ),
    ],
    'desenho-cad-1': [
      BankItem(
        'Linhas ocultas em uma vista representam usualmente:',
        'Arestas ou detalhes não visíveis naquela direção de observação',
        ['Somente cabos elétricos', 'A massa da peça', 'Uma escala diferente obrigatória'],
        'A representação de detalhes ocultos permite indicar geometria atrás de superfícies visíveis.',
      ),
      BankItem(
        'Um corte é especialmente útil quando:',
        'Detalhes internos dificultam a interpretação por vistas externas',
        ['A peça não possui geometria', 'Não se deseja representar o interior', 'É preciso apagar todas as dimensões'],
        'A seção evidencia formas internas e reduz ambiguidades de leitura.',
      ),
    ],
    'desenho-cad-2': [
      BankItem(
        'Uma dimensão real de 120 mm é desenhada em escala 1:4. Qual seu comprimento no papel?',
        '30 mm',
        ['480 mm', '4 mm', '120 mm'],
        '120/4 = 30 mm.',
      ),
      BankItem(
        'Um desenho em escala 3:1 mostra uma linha de 90 mm no papel. Qual a dimensão real correspondente?',
        '30 mm',
        ['270 mm', '90 mm', '3 mm'],
        'A escala ampliada é desenho/real = 3; real = 90/3 = 30 mm.',
      ),
    ],
    'desenho-cad-3': [
      BankItem(
        'Duas linhas precisam permanecer com o mesmo comprimento após alterações. Qual restrição é adequada?',
        'Igualdade de comprimento',
        ['Perpendicularidade apenas', 'Tangência obrigatória', 'Ausência de qualquer restrição'],
        'A restrição de igualdade relaciona os comprimentos, preservando a condição durante modificações.',
      ),
      BankItem(
        'Um esquema usa símbolos sem legenda nem referência. Qual problema isso pode causar?',
        'Ambiguidade de interpretação',
        ['Aumento automático da precisão', 'Redução obrigatória do consumo', 'Validação automática de todas as conexões'],
        'A identificação dos símbolos é necessária para interpretar de modo consistente os elementos representados.',
      ),
    ],
    'metrologia-1': [
      BankItem(
        'Para medir corrente com um amperímetro convencional em um ramo, sua ligação deve ser:',
        'Em série com o ramo, respeitando faixa e procedimento',
        ['Em paralelo diretamente à fonte em qualquer escala', 'Sem considerar limites do instrumento', 'No lugar da proteção permanente'],
        'A corrente do ramo deve passar pelo instrumento; a ligação inadequada pode provocar falhas e riscos.',
      ),
      BankItem(
        'Um instrumento suporta até 30 V na configuração utilizada. Uma medição esperada de 100 V está:',
        'Fora da faixa permitida dessa configuração',
        ['Sempre dentro da faixa por ser digital', 'Permitida se durar pouco', 'Permitida sem consultar especificações'],
        'A faixa e os limites de segurança do instrumento devem ser respeitados.',
      ),
    ],
    'metrologia-2': [
      BankItem(
        'Uma leitura é 49,5 mm para referência de 50,0 mm. Qual o erro de indicação?',
        '−0,5 mm',
        ['0,5 mm', '99,5 mm', '1 mm'],
        'Erro = indicação − referência = 49,5−50,0 = −0,5 mm.',
      ),
      BankItem(
        'Duas medições têm a mesma resolução. Isso garante igual incerteza?',
        'Não',
        ['Sim, sempre', 'Sim, independentemente do método', 'Sim, pois resolução elimina erros'],
        'Incerteza inclui contribuições do instrumento, método, ambiente e outras fontes; não depende só da resolução.',
      ),
    ],
    'metrologia-3': [
      BankItem(
        'Após ajustar um instrumento, por que pode ser necessária nova calibração?',
        'Para caracterizar sua relação com a referência após a alteração',
        ['Porque ajuste elimina toda necessidade de verificação', 'Para mudar apenas a etiqueta', 'Porque a unidade de medida desaparece'],
        'O ajuste modifica o comportamento; nova caracterização permite conhecer o resultado após a mudança.',
      ),
      BankItem(
        'Um certificado de calibração deve permitir relacionar resultados a:',
        'Condições, referências e incertezas da calibração',
        ['Somente uma cor de carimbo', 'Apenas o preço do instrumento', 'A marca da mesa'],
        'Resultados precisam ser interpretados com as referências, condições e incertezas pertinentes.',
      ),
    ],
    'materiais-fabricacao-1': [
      BankItem(
        'Um componente opera sob temperatura elevada. Na seleção do material, deve-se considerar:',
        'Como suas propriedades mudam na temperatura de operação',
        ['Somente a aparência em temperatura ambiente', 'A maior densidade possível', 'Que todos os materiais se comportam igualmente'],
        'Resistência, expansão e outras propriedades podem variar com a temperatura.',
      ),
      BankItem(
        'Um material com baixa resistividade é geralmente mais adequado para:',
        'Condução elétrica',
        ['Isolamento elétrico ideal', 'Absorção acústica necessariamente', 'Bloqueio absoluto de corrente'],
        'Baixa resistividade favorece passagem de corrente para uma dada geometria.',
      ),
    ],
    'materiais-fabricacao-2': [
      BankItem(
        'A furação de uma peça com broca remove material na forma de:',
        'Cavacos',
        ['Sinais digitais', 'Somente vapor em todo caso', 'Campo magnético'],
        'A furação é uma operação de usinagem com remoção de material.',
      ),
      BankItem(
        'Na conformação, a mudança de geometria ocorre principalmente por:',
        'Deformação do material',
        ['Remoção obrigatória de todo o volume', 'Conversão direta em dados', 'Apenas pintura'],
        'Processos de conformação dão forma por deformação, segundo as condições do material e processo.',
      ),
    ],
    'materiais-fabricacao-3': [
      BankItem(
        'Uma junta precisa ser desmontada periodicamente para manutenção. Qual solução deve ser considerada?',
        'União desmontável adequada, como parafusos especificados',
        ['Soldagem obrigatória em qualquer condição', 'Colagem sem análise de acesso', 'Eliminar a fixação'],
        'A necessidade de manutenção deve influenciar a seleção e o dimensionamento da união.',
      ),
      BankItem(
        'Uma inspeção superficial não encontrou defeitos numa solda. Isso comprova ausência de defeitos internos?',
        'Não',
        ['Sim, sempre', 'Sim, independentemente da espessura', 'Sim, sem qualquer outro método'],
        'A capacidade de detecção depende do método e do tipo e localização da descontinuidade.',
      ),
    ],
    'mecanica-maquinas-1': [
      BankItem(
        'Uma força de 200 N atua perpendicularmente a uma alavanca de 0,3 m. Qual o momento?',
        '60 N·m',
        ['600 N·m', '0,0015 N·m', '200,3 N·m'],
        'M = Fd = 200 × 0,3 = 60 N·m.',
      ),
      BankItem(
        'Uma barra suporta 3000 N em área de 150 mm². Qual a tensão normal média?',
        '20 MPa',
        ['450 MPa', '2 MPa', '200 MPa'],
        'σ = F/A = 3000/150 = 20 N/mm² = 20 MPa.',
      ),
    ],
    'mecanica-maquinas-2': [
      BankItem(
        'Uma engrenagem motora de 15 dentes a 800 rpm aciona outra de 60 dentes. Qual o módulo da rotação de saída?',
        '200 rpm',
        ['3200 rpm', '800 rpm', '400 rpm'],
        'n2 = 800 × 15/60 = 200 rpm.',
      ),
      BankItem(
        'Uma redução ideal diminui a velocidade angular à metade, conservando potência. Como muda o torque?',
        'Dobra',
        ['Cai à metade', 'Permanece necessariamente igual', 'Torna-se nulo'],
        'P = Tω. Se ω cai à metade e P é constante, T dobra.',
      ),
    ],
    'mecanica-maquinas-3': [
      BankItem(
        'Desalinhamento entre eixos pode contribuir para:',
        'Vibração, cargas adicionais e desgaste',
        ['Eliminação de todo atrito', 'Vida útil infinita', 'Redução automática de todas as forças'],
        'Desalinhamento pode impor esforços adicionais aos componentes de apoio e transmissão.',
      ),
      BankItem(
        'Qual função básica um rolamento exerce num conjunto rotativo?',
        'Apoiar movimento relativo e transmitir cargas conforme seu tipo',
        ['Converter toda corrente em tensão', 'Substituir sempre o eixo', 'Armazenar programas'],
        'O rolamento suporta cargas e permite movimento relativo com características dependentes de sua construção.',
      ),
    ],
    'pneumatica-hidraulica-1': [
      BankItem(
        'A contaminação do fluido em um sistema hidráulico pode provocar:',
        'Desgaste e falhas em componentes',
        ['Precisão infinita', 'Eliminação do atrito', 'Aumento garantido de vida útil'],
        'Partículas e contaminantes podem danificar superfícies e comprometer válvulas e atuadores.',
      ),
      BankItem(
        'Um regulador de pressão numa preparação pneumática atua principalmente sobre:',
        'A pressão de alimentação a jusante, dentro das condições de operação',
        ['A composição química de qualquer material', 'A rotação do encoder diretamente', 'O programa do CLP'],
        'O regulador controla a pressão fornecida conforme sua construção e capacidade.',
      ),
    ],
    'pneumatica-hidraulica-2': [
      BankItem(
        'Um cilindro ideal recebe 500 kPa numa área útil de 0,002 m². Qual a força?',
        '1000 N',
        ['250 N', '100 N', '10000 N'],
        'F = pA = 500000 × 0,002 = 1000 N.',
      ),
      BankItem(
        'Mantendo a vazão, reduzir a área útil de um cilindro ideal provoca qual tendência na velocidade linear?',
        'Aumento',
        ['Redução obrigatória', 'Nenhuma mudança possível', 'Velocidade sempre nula'],
        'Q = Av. Para Q constante, v = Q/A cresce quando A diminui.',
      ),
    ],
    'pneumatica-hidraulica-3': [
      BankItem(
        'Um sensor indica que o cilindro chegou ao fim de avanço. Essa informação pode servir para:',
        'Autorizar a próxima etapa da sequência conforme a lógica projetada',
        ['Eliminar qualquer necessidade de intertravamento', 'Medir diretamente a composição do ar', 'Garantir ausência de energia armazenada'],
        'O estado de posição pode integrar condições de sequência; ele não comprova sozinho todas as condições do sistema.',
      ),
      BankItem(
        'Uma bobina de válvula recebe comando, mas o cilindro não se move. Qual abordagem é adequada?',
        'Verificar comando, alimentação, válvula e condições pneumáticas conforme procedimento',
        ['Concluir imediatamente que o CLP está queimado', 'Trocar todos os elementos sem teste', 'Ignorar a pressão disponível'],
        'O sintoma pode ter causas elétricas, pneumáticas ou mecânicas; o diagnóstico deve separá-las.',
      ),
    ],
    'sensores-instrumentacao-1': [
      BankItem(
        'Um sensor indutivo não detecta uma peça plástica sem elemento metálico no alcance previsto. Isso é necessariamente falha do sensor?',
        'Não; o princípio de detecção pode ser inadequado ao alvo',
        ['Sim, em qualquer modelo', 'Sim, pois todo sensor detecta qualquer material', 'Sim, sem avaliar especificações'],
        'O sensor deve ser escolhido segundo material, distância e condições de aplicação.',
      ),
      BankItem(
        'Um sensor com faixa de 0–50 °C será usado a 120 °C. Qual problema existe?',
        'A condição está fora da faixa declarada',
        ['Nenhum, pois a unidade é a mesma', 'A resolução dobra automaticamente', 'A calibração se torna desnecessária'],
        'A faixa e os limites do sensor precisam ser compatíveis com a medição.',
      ),
    ],
    'sensores-instrumentacao-2': [
      BankItem(
        'Uma tensão de 20 mV é amplificada com ganho 100. Qual é a saída ideal sem saturação?',
        '2 V',
        ['0,2 V', '20 V', '200 V'],
        'Vout = 100 × 0,020 = 2 V.',
      ),
      BankItem(
        'Um sinal linear 4–20 mA corresponde a 0–400 L/min. Qual vazão representa 16 mA?',
        '300 L/min',
        ['400 L/min', '160 L/min', '250 L/min'],
        '(16−4)/16 = 0,75; 0,75 × 400 = 300 L/min.',
      ),
    ],
    'sensores-instrumentacao-3': [
      BankItem(
        'Um transmissor linear de 0–100 bar usa saída 4–20 mA. Qual corrente corresponde a 50 bar?',
        '12 mA',
        ['10 mA', '8 mA', '16 mA'],
        'A metade da faixa corresponde a 4 + 0,5 × 16 = 12 mA.',
      ),
      BankItem(
        'Uma leitura de 0 mA num laço nominal 4–20 mA deve ser interpretada automaticamente como zero da grandeza?',
        'Não; pode indicar falha ou condição fora da faixa nominal',
        ['Sim, sempre', 'Sim, porque zero da escala é 0 mA', 'Sim, sem diagnóstico'],
        'O zero nominal da grandeza é representado por 4 mA; 0 mA requer diagnóstico segundo o sistema.',
      ),
    ],
    'microcontroladores-embarcados-1': [
      BankItem(
        'Um ADC ideal de 8 bits possui quantos códigos?',
        '256',
        ['8', '128', '512'],
        'O número de códigos é 2⁸ = 256.',
      ),
      BankItem(
        'Qual periférico é apropriado para contar intervalos de tempo por hardware?',
        'Temporizador',
        ['Somente uma string', 'A cor do LED', 'Um arquivo de imagem'],
        'Timers usam uma base de clock para contar eventos e intervalos.',
      ),
    ],
    'microcontroladores-embarcados-2': [
      BankItem(
        'Uma tarefa precisa verificar um botão enquanto aguarda um intervalo. Qual estrutura favorece resposta contínua?',
        'Controle de tempo sem bloquear o laço principal',
        ['Uma espera longa que impeça qualquer outra execução', 'Um laço infinito sem leitura', 'Desligar todas as interrupções permanentemente'],
        'Comparar instantes ou usar temporização permite executar outras tarefas durante o intervalo.',
      ),
      BankItem(
        'Uma variável compartilhada entre interrupção e fluxo principal pode exigir:',
        'Cuidados de sincronização e acesso consistente',
        ['Somente renomear a variável', 'Ignorar o tipo dos dados', 'Remover todos os testes'],
        'Acesso concorrente pode gerar estados inconsistentes, dependendo da operação e arquitetura.',
      ),
    ],
    'microcontroladores-embarcados-3': [
      BankItem(
        'Na UART assíncrona usual, transmissor e receptor precisam concordar principalmente em:',
        'Taxa e formato dos quadros',
        ['Cor dos fios apenas', 'Nome da função no programa', 'Frequência da rede elétrica obrigatoriamente'],
        'Baud rate, bits de dados, paridade e bits de parada devem ser compatíveis.',
      ),
      BankItem(
        'Em I²C, dois dispositivos com o mesmo endereço fixo no mesmo barramento podem causar:',
        'Conflito de endereçamento',
        ['Aumento garantido de precisão', 'Comunicação independente sem qualquer cuidado', 'Multiplicação automática de endereços'],
        'Sem mecanismos adequados, ambos podem responder ao mesmo endereço.',
      ),
    ],
    'redes-industriais-1': [
      BankItem(
        'Um switch é normalmente encontrado como elemento central em qual topologia física Ethernet?',
        'Estrela',
        ['Anel obrigatório sem centro', 'Linha mecânica sem sinais', 'Malha apenas óptica obrigatória'],
        'Enlaces de dispositivos podem convergir para um switch em topologia estrela.',
      ),
      BankItem(
        'Separar diagnóstico físico do diagnóstico de aplicação ajuda a:',
        'Localizar a camada provável da falha',
        ['Eliminar necessidade de parâmetros', 'Garantir que cabos nunca falhem', 'Substituir todas as mensagens por analogia'],
        'A separação distingue problemas de enlace e sinalização daqueles de endereçamento e serviço.',
      ),
    ],
    'redes-industriais-2': [
      BankItem(
        'Um cliente Modbus solicita dados de um endereço que não existe no servidor. Uma resposta de exceção indica:',
        'Que o servidor identificou uma condição de erro no pedido',
        ['Que toda a rede está fisicamente desligada', 'Que o valor medido necessariamente é zero', 'Que o cabo foi automaticamente reparado'],
        'Uma exceção de protocolo informa falha de processamento ou validade da requisição; não equivale a perda total de comunicação.',
      ),
      BankItem(
        'Dois nós com o mesmo endereço numa rede que exige endereços únicos podem provocar:',
        'Conflitos e identificação ambígua',
        ['Redundância válida automática em qualquer protocolo', 'Dobro garantido de velocidade', 'Correção automática de todos os erros'],
        'A unicidade do endereço permite identificar corretamente os participantes.',
      ),
    ],
    'redes-industriais-3': [
      BankItem(
        'Há alimentação no dispositivo, mas nenhum pacote chega ao destino. Qual sequência de verificação é coerente?',
        'Conexões e enlace, depois parâmetros e aplicação',
        ['Trocar imediatamente todos os sensores', 'Assumir que alimentação garante comunicação', 'Ignorar contadores e registros'],
        'A investigação por camadas ajuda a isolar a causa com evidências.',
      ),
      BankItem(
        'Por que registrar horário ao capturar uma falha de comunicação intermitente?',
        'Para correlacionar mensagens e eventos do processo',
        ['Para aumentar a corrente do barramento', 'Para corrigir o protocolo sem análise', 'Para eliminar necessidade de conteúdo dos pacotes'],
        'A correlação temporal auxilia a identificar condições associadas à falha.',
      ),
    ],
    'cnc-manufatura-1': [
      BankItem(
        'Em modo incremental, um eixo em X = 40 mm recebe deslocamento de −12 mm. Qual o destino?',
        '28 mm',
        ['52 mm', '−12 mm', '480 mm'],
        'A posição final é 40 + (−12) = 28 mm.',
      ),
      BankItem(
        'No modo absoluto, um comando para X = 25 mm refere-se a:',
        'Uma coordenada em relação à origem ativa',
        ['Sempre um deslocamento adicional de 25 mm', 'Um raio de 25 mm obrigatoriamente', 'Um avanço de 25 rpm'],
        'Coordenadas absolutas são interpretadas no sistema de referência ativo.',
      ),
    ],
    'cnc-manufatura-2': [
      BankItem(
        'Por que conferir unidades e modo de posicionamento ao carregar um programa CNC?',
        'Porque eles alteram a interpretação das coordenadas e movimentos',
        ['Porque impedem todo desgaste', 'Porque substituem fixação e ferramentas', 'Porque todo controlador ignora unidades'],
        'Uma mesma sequência numérica pode produzir movimentos distintos conforme unidades e modos ativos.',
      ),
      BankItem(
        'Uma simulação mostra colisão entre ferramenta e fixação. Qual ação é adequada?',
        'Revisar trajetória, referências e montagem antes da execução',
        ['Aumentar a velocidade para passar mais rápido', 'Ignorar por ser uma simulação', 'Remover todos os limites sem análise'],
        'A colisão prevista exige corrigir a situação e verificar novamente.',
      ),
    ],
    'cnc-manufatura-3': [
      BankItem(
        'Uma célula produz uma peça a cada 45 s, sem paradas. Qual a produção teórica por hora?',
        '80 peças',
        ['45 peças', '60 peças', '160 peças'],
        '3600/45 = 80 peças por hora.',
      ),
      BankItem(
        'Duas etapas em série têm capacidades de 100 e 60 peças/h. Sem estoques iniciais e em regime estável, qual o limite da linha?',
        '60 peças/h',
        ['160 peças/h', '100 peças/h', '40 peças/h'],
        'A etapa de menor capacidade limita a vazão sustentada da linha.',
      ),
    ],
    'projetos-manutencao-1': [
      BankItem(
        'Um requisito diz apenas que o sistema deve ser rápido. Qual melhoria o torna verificável?',
        'Definir tempo de resposta e condições de medição',
        ['Retirar todos os números', 'Usar uma fonte maior no texto', 'Substituir por outra palavra vaga'],
        'Critérios objetivos permitem comparar o comportamento medido ao requisito.',
      ),
      BankItem(
        'Uma alteração de componente deve ser refletida em quais registros pertinentes?',
        'Lista de materiais, diagramas e revisões afetadas',
        ['Somente no nome da pasta', 'Apenas na cor da capa', 'Em nenhum documento'],
        'Documentação coerente deve refletir a configuração efetivamente adotada.',
      ),
    ],
    'projetos-manutencao-2': [
      BankItem(
        'Trocar um componente somente após sua falha caracteriza tipicamente:',
        'Manutenção corretiva',
        ['Exclusivamente preditiva', 'Calibração', 'Teste de software'],
        'A manutenção corretiva é realizada após identificar uma falha ou perda de função.',
      ),
      BankItem(
        'Uma tendência de vibração cresce ao longo de semanas. Qual uso adequado desse dado?',
        'Apoiar diagnóstico e planejamento de intervenção com critérios definidos',
        ['Trocar qualquer peça sem análise', 'Assumir que a causa é única', 'Ignorar condições de operação'],
        'Tendências devem ser interpretadas com histórico, limites e condições do ativo.',
      ),
    ],
    'projetos-manutencao-3': [
      BankItem(
        'Duas hipóteses explicam uma falha. Qual teste é mais útil?',
        'Um teste capaz de produzir resultados diferentes entre as hipóteses',
        ['Um teste sem relação com os sintomas', 'Uma troca aleatória de peças', 'Uma repetição sem registro em qualquer condição'],
        'Um teste discriminante ajuda a confirmar ou rejeitar causas possíveis.',
      ),
      BankItem(
        'Após corrigir uma falha, por que verificar o funcionamento?',
        'Para confirmar a recuperação e procurar efeitos não previstos',
        ['Para eliminar todos os registros', 'Para garantir vida infinita', 'Para dispensar critérios de aceitação'],
        'A verificação confirma se a ação resolveu o problema nas condições relevantes.',
      ),
    ],
    'qualidade-gestao-ambiente-1': [
      BankItem(
        'Em 500 itens inspecionados, 15 são não conformes. Qual a proporção?',
        '3%',
        ['15%', '30%', '0,3%'],
        '15/500 = 0,03 = 3%.',
      ),
      BankItem(
        'Na etapa Check do PDCA, realiza-se principalmente:',
        'Verificação dos resultados em relação ao planejamento',
        ['Somente execução sem medição', 'Abandono dos indicadores', 'Compra automática de materiais'],
        'A verificação compara evidências e resultados ao objetivo planejado.',
      ),
    ],
    'qualidade-gestao-ambiente-2': [
      BankItem(
        'Uma tarefa depende de um equipamento indisponível. Isso deve ser tratado no planejamento como:',
        'Restrição e risco ao prazo da tarefa',
        ['Garantia de execução imediata', 'Um dado sem efeito', 'Motivo para eliminar todos os requisitos'],
        'A disponibilidade de recursos influencia a viabilidade e o cronograma.',
      ),
      BankItem(
        'Uma mudança reduz custo, mas aumenta o risco de falha. Qual avaliação é adequada?',
        'Considerar conjuntamente custo, requisitos e riscos',
        ['Aprovar apenas pelo menor custo', 'Ignorar os usuários afetados', 'Eliminar a validação'],
        'Decisões de projeto exigem avaliar impactos e critérios, não apenas um indicador.',
      ),
    ],
    'qualidade-gestao-ambiente-3': [
      BankItem(
        'Para a mesma produção, o consumo caiu de 250 kWh para 200 kWh. Qual a economia?',
        '20%',
        ['25%', '50%', '80%'],
        '(250−200)/250 = 0,2 = 20%.',
      ),
      BankItem(
        'Por que comparar energia por unidade produzida entre períodos?',
        'Para considerar diferenças de produção na análise de eficiência',
        ['Para dispensar a medição de energia', 'Para ocultar todas as perdas', 'Para garantir que toda redução de consumo é eficiência'],
        'O consumo absoluto pode mudar apenas por variar a produção; indicadores específicos ajudam na comparação.',
      ),
    ],
  };

  static const assessment = <String, List<BankItem>>{
    'eletricidade-basica': [
      BankItem(
        'Uma carga resistiva de 48 Ω é ligada a 24 V. Qual potência dissipa?',
        '12 W',
        ['0,5 W', '48 W', '1152 W'],
        'I = 24/48 = 0,5 A; P = VI = 24 × 0,5 = 12 W.',
      ),
      BankItem(
        'Três resistores de 2 Ω, 3 Ω e 5 Ω estão em série sob 20 V. Qual a queda no resistor de 3 Ω?',
        '6 V',
        ['3 V', '10 V', '12 V'],
        'Req = 10 Ω e I = 2 A. A queda no resistor de 3 Ω é 2 × 3 = 6 V.',
      ),
      BankItem(
        'Um equipamento de 800 W opera 5 h. Qual energia consome?',
        '4 kWh',
        ['0,16 kWh', '40 kWh', '800 kWh'],
        '800 W = 0,8 kW. E = 0,8 × 5 = 4 kWh.',
      ),
      BankItem(
        'Em um nó entram 9 A; saem 2 A e 4 A por dois ramos. Qual a corrente de saída no terceiro?',
        '3 A',
        ['15 A', '6 A', '−3 A'],
        '9 = 2 + 4 + I. Portanto I = 3 A.',
      ),
    ],
    'eletronica-analogica': [
      BankItem(
        'Um diodo com queda de 0,6 V está em série com 2 kΩ sob 5 V. Qual a corrente?',
        '2,2 mA',
        ['2,5 mA', '0,3 mA', '22 mA'],
        'VR = 5 − 0,6 = 4,4 V; I = 4,4/2000 = 2,2 mA.',
      ),
      BankItem(
        'Um inversor ideal usa Rin = 5 kΩ, Rf = 15 kΩ e Vin = 0,4 V. Sem saturação, qual é Vout?',
        '−1,2 V',
        ['1,2 V', '−0,133 V', '6 V'],
        'Av = −Rf/Rin = −3. Vout = −3 × 0,4 = −1,2 V.',
      ),
      BankItem(
        'Um BJT no modelo ativo tem β = 50 e IB = 40 µA. Qual IC calculada?',
        '2 mA',
        ['20 mA', '0,8 µA', '200 mA'],
        'IC = 50 × 40 µA = 2000 µA = 2 mA.',
      ),
      BankItem(
        'Se R dobrar em um filtro RC mantendo C constante, como muda sua frequência de corte?',
        'Cai à metade',
        ['Dobra', 'Quadruplica', 'Não muda'],
        'fc = 1/(2πRC). Dobrar R dobra o denominador e reduz fc à metade.',
      ),
      BankItem(
        'Uma fonte de 12 V alimenta um Zener ideal de 5 V por resistor de 1 kΩ, sem carga. Admitindo regulação, qual a corrente no resistor?',
        '7 mA',
        ['5 mA', '12 mA', '17 mA'],
        'A queda no resistor é 12−5 = 7 V; I = 7/1000 = 7 mA.',
      ),
      BankItem(
        'Qual é o efeito de dobrar C, mantendo R, na frequência de corte de um filtro RC?',
        'Reduzir à metade',
        ['Dobrar', 'Quadruplicar', 'Manter constante'],
        'fc = 1/(2πRC). Dobrar C reduz fc à metade.',
      ),
      BankItem(
        'Um seguidor ideal em operação linear recebe 1,8 V na entrada não inversora. Qual é sua saída?',
        '1,8 V',
        ['−1,8 V', '0 V', '3,6 V'],
        'O seguidor tem ganho unitário: Vout = Vin, dentro da faixa de operação.',
      ),
      BankItem(
        'Em um BJT usado como chave, corrente de base insuficiente pode impedir:',
        'Que ele atinja a saturação desejada para a carga',
        ['A existência de qualquer tensão na fonte', 'A presença de resistência no circuito', 'A formação da junção PN'],
        'O acionamento de base deve ser compatível com a corrente de carga e o estado de chaveamento desejado.',
      ),
      BankItem(
        'Um retificador de meia onda recebe uma senoide de 50 Hz. Antes da filtragem, quantos pulsos principais de saída ocorrem por segundo?',
        '50',
        ['100', '25', '200'],
        'Há um pulso por ciclo na meia onda; a frequência de repetição é 50 Hz.',
      ),
      BankItem(
        'O curto virtual de um amplificador operacional ideal com realimentação negativa significa:',
        'Tensões aproximadamente iguais nas entradas em operação linear, sem ligação física entre elas',
        ['Curto físico obrigatório entre os terminais', 'Corrente infinita de entrada', 'Ganho de malha aberta igual a zero'],
        'A aproximação decorre do alto ganho e da realimentação em regime linear; não é uma conexão condutora entre entradas.',
      ),
    ],
    'eletronica-digital': [
      BankItem(
        'Qual o decimal correspondente ao binário 1101?',
        '13',
        ['11', '14', '15'],
        '1101₂ = 8 + 4 + 1 = 13.',
      ),
      BankItem(
        'Para Y = (A OU B) E C, com A = 0, B = 1 e C = 0, qual é Y?',
        '0',
        ['1', '2', 'Alta impedância obrigatória'],
        '(0 OU 1) E 0 = 1 E 0 = 0.',
      ),
      BankItem(
        'Um multiplexador 8 para 1 precisa de quantos bits de seleção?',
        '3',
        ['2', '4', '8'],
        'É necessário representar oito escolhas: 2³ = 8.',
      ),
      BankItem(
        'Um contador binário sem sinal de 4 bits possui quantos estados?',
        '16',
        ['4', '8', '15'],
        'O número de estados é 2⁴ = 16, correspondentes aos valores 0 a 15.',
      ),
    ],
    'instalacoes-eletricas': [
      BankItem(
        'Uma resistência total de condutores de 0,3 Ω conduz 15 A. Qual a queda de tensão?',
        '4,5 V',
        ['50 V', '0,02 V', '45 V'],
        'ΔV = RI = 0,3 × 15 = 4,5 V. A resistência informada já inclui o percurso completo.',
      ),
      BankItem(
        'A resistência de um condutor é 0,8 Ω. Para mesmo material e comprimento, qual seria sua resistência ao dobrar a seção?',
        '0,4 Ω',
        ['1,6 Ω', '0,8 Ω', '3,2 Ω'],
        'R é inversamente proporcional à área; dobrar A reduz R à metade.',
      ),
      BankItem(
        'O diagrama unifilar e a lista de circuitos apresentam identificadores divergentes. Qual a providência adequada antes da execução?',
        'Conciliar a documentação e corrigir a inconsistência',
        ['Executar por tentativa sem registrar', 'Desconsiderar todas as proteções', 'Escolher o desenho pela cor'],
        'Documentos precisam identificar os mesmos circuitos para permitir execução e verificação coerentes.',
      ),
      BankItem(
        'Em uma reversão com contatores, o intertravamento elétrico utiliza tipicamente:',
        'Contato auxiliar NF do contator oposto em série com a bobina',
        ['Um contato NA em curto com a fonte', 'Apenas a lâmpada de sinalização', 'Um resistor substituindo todos os contatos'],
        'Quando um contator está energizado, seu auxiliar NF abre o circuito de comando do oposto.',
      ),
    ],
    'clp-automacao': [
      BankItem(
        'Na expressão Y = (A E B) OU C, com A = 1, B = 0 e C = 1, qual é Y?',
        '1',
        ['0', '−1', 'Alta impedância'],
        '(1 E 0) OU 1 = 0 OU 1 = 1.',
      ),
      BankItem(
        'Um TON não retentivo de 4 s recebe entrada ativa continuamente por 6 s. Sem outra condição de reset, quando sua saída de término ativa?',
        'Após aproximadamente 4 s, limitada pela resolução e varredura',
        ['Somente aos 6 s', 'Imediatamente no primeiro instante em qualquer configuração', 'Nunca'],
        'O tempo configurado é 4 s; a detecção efetiva depende da base de tempo e da execução do controlador.',
      ),
      BankItem(
        'Uma entrada 4–20 mA representa 0–80 L/min. Qual vazão corresponde a 10 mA?',
        '30 L/min',
        ['40 L/min', '50 L/min', '10 L/min'],
        '(10 − 4)/16 = 0,375; 0,375 × 80 = 30 L/min.',
      ),
      BankItem(
        'Um contador por borda recebe quatro pulsos completos de 0 para 1 e de volta a 0. Quantos incrementos registra, sem reset?',
        '4',
        ['8', '1', '0'],
        'Cada borda de subida produz um incremento; quatro pulsos contêm quatro bordas de subida.',
      ),
    ],
    'circuitos-cc': [
      BankItem(
        'Uma fonte de 30 V alimenta resistores em série de 10 Ω e 5 Ω. Qual a corrente?',
        '2 A',
        ['3 A', '6 A', '0,5 A'],
        'Req = 15 Ω; I = 30/15 = 2 A.',
      ),
      BankItem(
        'Resistores de 8 Ω e 24 Ω em paralelo apresentam qual resistência equivalente?',
        '6 Ω',
        ['32 Ω', '16 Ω', '3 Ω'],
        'Req = 8×24/(8+24) = 192/32 = 6 Ω.',
      ),
      BankItem(
        'Um RC tem R = 2 kΩ e C = 250 µF. Qual sua constante de tempo?',
        '0,5 s',
        ['5 s', '0,05 s', '500 s'],
        'τ = 2000 × 250×10⁻⁶ = 0,5 s.',
      ),
      BankItem(
        'Uma malha tem fonte de 15 V e duas quedas, uma de 9 V. Qual é a outra?',
        '6 V',
        ['24 V', '9 V', '1,67 V'],
        'A soma algébrica das tensões é zero: 15 − 9 − V = 0.',
      ),
    ],
    'circuitos-ca': [
      BankItem(
        'Uma senoide tem T = 10 ms. Qual sua frequência?',
        '100 Hz',
        ['10 Hz', '50 Hz', '1000 Hz'],
        'f = 1/0,010 = 100 Hz.',
      ),
      BankItem(
        'Um circuito série tem R = 8 Ω e reatância resultante de 6 Ω. Qual |Z|?',
        '10 Ω',
        ['14 Ω', '2 Ω', '48 Ω'],
        'O módulo é √(8²+6²) = 10 Ω.',
      ),
      BankItem(
        'Uma carga senoidal monofásica recebe 200 V, conduz 3 A e tem fp = 0,5. Qual P?',
        '300 W',
        ['600 W', '100 W', '1200 W'],
        'P = VI·fp = 200 × 3 × 0,5 = 300 W.',
      ),
      BankItem(
        'Uma senoide de 50 Hz atrasa outra de mesma frequência em 5 ms. Qual o atraso angular?',
        '90°',
        ['45°', '180°', '18°'],
        'T = 20 ms. φ = 360° × 5/20 = 90°.',
      ),
    ],
    'eletronica-potencia': [
      BankItem(
        'Um buck ideal em condução contínua recebe 30 V e usa D = 0,4. Qual sua saída?',
        '12 V',
        ['75 V', '18 V', '0,4 V'],
        'Vout = 30 × 0,4 = 12 V.',
      ),
      BankItem(
        'Um boost ideal em condução contínua recebe 10 V e usa D = 0,6. Qual sua saída?',
        '25 V',
        ['6 V', '16 V', '4 V'],
        'Vout = 10/(1−0,6) = 25 V.',
      ),
      BankItem(
        'Qual é o efeito pretendido do tempo morto no comando de um braço inversor?',
        'Evitar sobreposição indevida de condução das chaves complementares',
        ['Manter ambas as chaves continuamente ligadas', 'Eliminar todo ruído de medição', 'Aumentar o fator de potência de qualquer carga a 1'],
        'O tempo morto cria um intervalo entre desligar uma chave e ligar sua complementar.',
      ),
      BankItem(
        'Um SCR convencional está conduzindo corrente acima da manutenção. Retirar o sinal do gate garante bloqueio imediato?',
        'Não',
        ['Sim, em todos os SCRs', 'Sim, se o gate estiver sem fio', 'Sim, pois toda a corrente passa pelo gate'],
        'O SCR pode manter condução sem gate; o desligamento depende das condições de corrente e comutação.',
      ),
    ],
    'seguranca-normas': [
      BankItem(
        'Um equipamento aparentemente desligado possui bateria interna. A análise de energia deve:',
        'Incluir a bateria e as demais fontes possíveis',
        ['Considerar somente o cabo externo', 'Assumir energia zero pela aparência', 'Substituir verificação por sinalização luminosa'],
        'Fontes internas podem manter energia mesmo sem alimentação externa.',
      ),
      BankItem(
        'Uma tarefa foge às condições previstas no procedimento. Qual atitude é adequada?',
        'Interromper e solicitar reavaliação das condições e controles',
        ['Improvisar para terminar antes', 'Retirar a proteção para ganhar tempo', 'Ignorar os novos perigos'],
        'Mudanças não previstas precisam ser avaliadas antes de continuar.',
      ),
      BankItem(
        'O uso de EPI autoriza automaticamente uma pessoa a executar qualquer serviço elétrico?',
        'Não',
        ['Sim, qualquer serviço', 'Sim, sem capacitação', 'Sim, se houver urgência'],
        'Proteção individual não substitui requisitos de capacitação, autorização e procedimentos aplicáveis.',
      ),
      BankItem(
        'Uma proteção foi removida temporariamente. O retorno à operação deve considerar:',
        'Restabelecimento e verificação das condições de proteção previstas',
        ['Somente a aparência externa', 'A maior velocidade possível', 'A ausência de qualquer registro'],
        'O estado de proteção necessário à operação deve ser restabelecido e verificado conforme o procedimento.',
      ),
    ],
    'maquinas-eletricas': [
      BankItem(
        'Um transformador ideal tem relação N1/N2 = 5 e recebe 100 V. Qual V2?',
        '20 V',
        ['500 V', '5 V', '50 V'],
        'V2 = 100/5 = 20 V.',
      ),
      BankItem(
        'Um motor de 2 polos é alimentado a 50 Hz. Qual sua velocidade síncrona?',
        '3000 rpm',
        ['1500 rpm', '6000 rpm', '2500 rpm'],
        'ns = 120 × 50/2 = 3000 rpm.',
      ),
      BankItem(
        'Com ns = 1500 rpm e n = 1440 rpm, qual o escorregamento?',
        '4%',
        ['6%', '96%', '40%'],
        's = (1500−1440)/1500 = 0,04 = 4%.',
      ),
      BankItem(
        'Uma máquina recebe 2000 W e entrega 1700 W. Qual seu rendimento?',
        '85%',
        ['15%', '117,6%', '70%'],
        'η = 1700/2000 = 0,85 = 85%.',
      ),
    ],
    'robotica': [
      BankItem(
        'Um encoder de 800 pulsos por volta, sem multiplicação, registra 200 pulsos. Qual o deslocamento angular?',
        '90°',
        ['45°', '180°', '200°'],
        '200/800 = 1/4 de volta; 360°/4 = 90°.',
      ),
      BankItem(
        'Qual problema calcula as juntas a partir da posição e orientação desejadas da ferramenta?',
        'Cinemática inversa',
        ['Retificação de tensão', 'Contagem de pacotes', 'Calibração de pressão'],
        'A cinemática inversa procura configurações articulares para a pose desejada.',
      ),
      BankItem(
        'Duas posições têm as mesmas coordenadas numéricas, mas usam referenciais distintos. Elas necessariamente coincidem fisicamente?',
        'Não',
        ['Sim, sempre', 'Sim, se forem números inteiros', 'Sim, independentemente das origens'],
        'O significado físico das coordenadas depende da origem e orientação do referencial.',
      ),
      BankItem(
        'Qual par associa corretamente medição e atuação em uma junta?',
        'Encoder e motor',
        ['Fusível e legenda', 'Parafuso e comentário', 'Carcaça e arquivo de texto'],
        'O encoder fornece posição e o motor produz movimento.',
      ),
    ],
    'supervisorios-processos': [
      BankItem(
        'Usando e = SP−PV, com SP = 120 kPa e PV = 128 kPa, qual é o erro?',
        '−8 kPa',
        ['8 kPa', '248 kPa', '0 kPa'],
        'e = 120 − 128 = −8 kPa.',
      ),
      BankItem(
        'Um controle proporcional tem Kp = 4 e erro e = 2. Qual a contribuição proporcional, antes de limites?',
        '8',
        ['2', '6', '0,5'],
        'P = Kp·e = 4 × 2 = 8.',
      ),
      BankItem(
        'A IHM exibe um valor sem atualização há dez minutos, mas o operador precisa da condição atual. Qual informação é indispensável?',
        'Tempo da última atualização e validade da comunicação',
        ['Apenas a cor do título', 'O nome do cabo de energia', 'Somente a resolução do monitor'],
        'O operador precisa distinguir valor atual de valor histórico ou inválido.',
      ),
      BankItem(
        'Em uma malha fechada, qual fluxo funcional está correto?',
        'Medição, comparação e ação sobre a planta',
        ['Apenas comando sem medição', 'Somente histórico sem atuação', 'Apenas desenho sem sinais'],
        'A realimentação usa a medição para comparar com a referência e determinar a ação de controle.',
      ),
    ],
    'telecomunicacoes': [
      BankItem(
        'Transmitir 12000 bits a 3000 bit/s, sem sobrecarga, leva:',
        '4 s',
        ['36 s', '0,25 s', '9 s'],
        't = 12000/3000 = 4 s.',
      ),
      BankItem(
        'Um arquivo contém 250 bytes. Quantos bits de dados há?',
        '2000 bits',
        ['250 bits', '31,25 bits', '258 bits'],
        '250 × 8 = 2000 bits.',
      ),
      BankItem(
        'Qual meio é especialmente indicado quando se deseja isolamento elétrico do enlace e transmissão óptica?',
        'Fibra óptica',
        ['Fio de cobre nu', 'Barra metálica', 'Par de alimentação CC'],
        'A fibra transporta luz por um meio dielétrico.',
      ),
      BankItem(
        'Qual par associa corretamente técnica e característica variada?',
        'AM: amplitude; FM: frequência',
        ['AM: massa; FM: pressão', 'AM: fase exclusivamente; FM: resistência', 'AM e FM: somente velocidade no vácuo'],
        'As siglas AM e FM se referem às características da portadora usadas para a modulação.',
      ),
    ],
    'programacao': [
      BankItem(
        'Um contador inicia em 2 e recebe três incrementos de 2. Qual o valor final?',
        '8',
        ['6', '5', '12'],
        '2 + 2 + 2 + 2 = 8.',
      ),
      BankItem(
        'Numa lista indexada do zero, qual é o índice do quinto elemento?',
        '4',
        ['5', '1', '0'],
        'O primeiro índice é 0; o quinto é 4.',
      ),
      BankItem(
        'Uma pilha usual segue qual regra?',
        'Último a entrar, primeiro a sair',
        ['Primeiro a entrar, primeiro a sair', 'Sempre o menor número', 'Escolha aleatória obrigatória'],
        'Uma pilha segue LIFO: Last In, First Out.',
      ),
      BankItem(
        'Uma API devolve resposta inválida. Qual abordagem preserva comportamento definido?',
        'Validar a resposta e tratar o erro previsto',
        ['Aceitar qualquer conteúdo como dado correto', 'Ignorar todos os limites de tempo', 'Apagar o código de validação'],
        'Entradas externas exigem verificação e tratamento de falhas.',
      ),
    ],
    'matematica-fisica': [
      BankItem(
        'Resolva 2x + 7 = 19.',
        'x = 6',
        ['x = 13', 'x = 12', 'x = 3'],
        '2x = 12, logo x = 6.',
      ),
      BankItem(
        'Uma massa de 4 kg sofre força resultante de 20 N. Qual sua aceleração?',
        '5 m/s²',
        ['80 m/s²', '16 m/s²', '0,2 m/s²'],
        'a = F/m = 20/4 = 5 m/s².',
      ),
      BankItem(
        'Uma onda tem velocidade de 240 m/s e comprimento de onda de 4 m. Qual a frequência?',
        '60 Hz',
        ['960 Hz', '4 Hz', '240 Hz'],
        'f = v/λ = 240/4 = 60 Hz.',
      ),
      BankItem(
        'Um equipamento transfere 600 J em 30 s. Qual a potência média?',
        '20 W',
        ['18000 W', '570 W', '0,05 W'],
        'P = 600/30 = 20 W.',
      ),
    ],
    'desenho-cad': [
      BankItem(
        'Em escala 1:5, uma peça de 75 mm é representada com qual comprimento?',
        '15 mm',
        ['375 mm', '75 mm', '5 mm'],
        'Comprimento desenhado = 75/5 = 15 mm.',
      ),
      BankItem(
        'Uma peça é desenhada em escala 4:1. A cota informa 12 mm. Qual a dimensão real?',
        '12 mm',
        ['3 mm', '48 mm', '4 mm'],
        'A cota informa a dimensão real, independentemente da escala gráfica.',
      ),
      BankItem(
        'Qual restrição mantém duas linhas a 90°?',
        'Perpendicularidade',
        ['Igualdade de raio', 'Tangência obrigatória', 'Paralelismo'],
        'Linhas perpendiculares formam ângulo reto.',
      ),
      BankItem(
        'Quando usar uma vista em corte?',
        'Quando for necessário evidenciar detalhes internos',
        ['Para substituir toda cotagem', 'Para eliminar a geometria', 'Para dispensar qualquer legenda'],
        'O corte torna visíveis regiões internas seccionadas.',
      ),
    ],
    'metrologia': [
      BankItem(
        'Um instrumento indica 101,2 kPa para referência de 100,0 kPa. Qual o erro de indicação?',
        '1,2 kPa',
        ['−1,2 kPa', '201,2 kPa', '0,12 kPa'],
        'Erro = 101,2 − 100,0 = 1,2 kPa.',
      ),
      BankItem(
        'Uma resolução de 0,01 mm garante erro menor que 0,01 mm?',
        'Não',
        ['Sim, sempre', 'Sim, sem calibração', 'Sim, independentemente do método'],
        'Resolução e erro são conceitos distintos.',
      ),
      BankItem(
        'Qual operação modifica o instrumento para alterar sua indicação?',
        'Ajuste',
        ['Somente registro de leitura', 'Leitura de legenda', 'Arquivamento do certificado'],
        'Ajuste atua no instrumento; calibração caracteriza sua relação com referências.',
      ),
      BankItem(
        'Um resultado rastreável deve estar relacionado a referências por:',
        'Uma cadeia documentada de calibrações',
        ['Apenas uma etiqueta colorida', 'Somente o nome do usuário', 'A ausência de qualquer incerteza'],
        'A cadeia documentada permite relacionar o resultado às referências declaradas.',
      ),
    ],
    'materiais-fabricacao': [
      BankItem(
        'Qual propriedade é diretamente relevante ao selecionar um condutor elétrico?',
        'Resistividade',
        ['Somente brilho', 'Apenas forma da embalagem', 'Somente textura da pintura'],
        'A resistividade influencia a resistência elétrica do componente.',
      ),
      BankItem(
        'Torneamento com remoção de cavacos é um processo de:',
        'Usinagem',
        ['Apenas conformação sem remoção', 'Calibração', 'Programação de rede'],
        'O torneamento remove material para obter geometria.',
      ),
      BankItem(
        'Uma união deve permitir desmontagem frequente. Qual característica deve ser priorizada no projeto?',
        'Acesso e solução de fixação desmontável adequada',
        ['Impossibilidade de acesso', 'Soldagem obrigatória', 'Ausência de retenção mecânica'],
        'A manutenção planejada exige considerar acesso, fixação e integridade após desmontagens.',
      ),
      BankItem(
        'Uma inspeção visual avalia diretamente qual tipo de condição?',
        'Aspectos visíveis na superfície e regiões acessíveis',
        ['Toda a estrutura interna sem restrição', 'A composição química exata', 'A vida útil infinita'],
        'A inspeção visual tem limites de acesso e detecção.',
      ),
    ],
    'mecanica-maquinas': [
      BankItem(
        'Uma força de 80 N age perpendicularmente a 0,5 m do eixo. Qual o torque?',
        '40 N·m',
        ['160 N·m', '80,5 N·m', '0,00625 N·m'],
        'T = Fd = 80 × 0,5 = 40 N·m.',
      ),
      BankItem(
        'Uma engrenagem de 25 dentes a 900 rpm aciona outra de 75 dentes. Qual o módulo da velocidade da movida?',
        '300 rpm',
        ['2700 rpm', '600 rpm', '900 rpm'],
        'n2 = 900 × 25/75 = 300 rpm.',
      ),
      BankItem(
        'Uma barra suporta 2400 N em área de 80 mm². Qual a tensão média?',
        '30 MPa',
        ['3 MPa', '192 MPa', '300 MPa'],
        'σ = 2400/80 = 30 N/mm² = 30 MPa.',
      ),
      BankItem(
        'Um rolamento apresenta aquecimento e vibração anormais. Qual atitude técnica inicial é adequada?',
        'Investigar condições como carga, alinhamento e lubrificação',
        ['Assumir funcionamento normal sem análise', 'Aumentar indiscriminadamente a velocidade', 'Remover a proteção e operar sem critério'],
        'Sintomas podem ter várias causas; o diagnóstico deve reunir evidências antes da intervenção.',
      ),
    ],
    'pneumatica-hidraulica': [
      BankItem(
        'Um cilindro ideal tem área útil de 0,004 m² e recebe 200 kPa. Qual a força?',
        '800 N',
        ['50 N', '8000 N', '80 N'],
        'F = 200000 × 0,004 = 800 N.',
      ),
      BankItem(
        'Qual componente altera os caminhos do fluido para comandar um atuador?',
        'Válvula direcional',
        ['Legenda do desenho', 'Arquivo de programa isolado', 'Termistor'],
        'A válvula direcional comuta conexões entre vias.',
      ),
      BankItem(
        'Uma unidade pneumática apresenta água e partículas no ar. Qual aspecto deve ser avaliado?',
        'Preparação e tratamento do ar',
        ['Somente a cor das mangueiras', 'A resolução do monitor', 'A frequência do encoder'],
        'A condição do ar influencia funcionamento e vida dos componentes.',
      ),
      BankItem(
        'Uma bobina está energizada e o cilindro permanece parado. O diagnóstico deve considerar:',
        'Possíveis causas elétricas, pneumáticas e mecânicas',
        ['Somente defeito do software em todos os casos', 'Que a pressão sempre está correta', 'Que sensores nunca falham'],
        'O mesmo sintoma pode decorrer de diferentes partes do sistema.',
      ),
    ],
    'sensores-instrumentacao': [
      BankItem(
        'Um transmissor 4–20 mA representa 0–300 °C. Qual temperatura corresponde a 12 mA?',
        '150 °C',
        ['120 °C', '75 °C', '300 °C'],
        '(12−4)/16 = 0,5; 0,5 × 300 = 150 °C.',
      ),
      BankItem(
        'Um amplificador ideal de ganho 50 recebe 10 mV. Qual sua saída sem saturação?',
        '0,5 V',
        ['5 V', '50 V', '0,05 V'],
        '50 × 0,010 = 0,5 V.',
      ),
      BankItem(
        'Qual característica deve orientar a seleção de um sensor de proximidade?',
        'Material do alvo, distância e ambiente',
        ['Somente a cor da carcaça', 'A marca do teclado', 'A temperatura da sala sem considerar o alvo'],
        'O princípio e as especificações devem atender à aplicação.',
      ),
      BankItem(
        'Um laço nominal 4–20 mA apresenta 0 mA. Qual interpretação é adequada?',
        'Investigar falha ou condição fora da faixa nominal',
        ['Assumir sempre zero válido da grandeza', 'Assumir obrigatoriamente fim de escala', 'Ignorar a leitura indefinidamente'],
        'O início da escala nominal é 4 mA; 0 mA requer diagnóstico.',
      ),
    ],
    'microcontroladores-embarcados': [
      BankItem(
        'Um ADC ideal de 9 bits pode produzir quantos códigos distintos?',
        '512',
        ['9', '256', '1024'],
        '2⁹ = 512.',
      ),
      BankItem(
        'Para atender várias tarefas durante um intervalo, qual estratégia favorece responsividade?',
        'Temporização sem bloquear o fluxo principal',
        ['Espera bloqueante ilimitada', 'Desativar toda leitura', 'Um laço sem condição de saída'],
        'O controle de tempo não bloqueante permite que o fluxo execute outras tarefas.',
      ),
      BankItem(
        'Qual par identifica os sinais básicos do I²C?',
        'SDA e SCL',
        ['TX e RX exclusivamente', 'Fase e terra', 'Dreno e porta'],
        'SDA transporta dados e SCL fornece clock.',
      ),
      BankItem(
        'Um watchdog não é atendido dentro do prazo configurado. Qual é sua função típica nesse contexto?',
        'Acionar a resposta de recuperação configurada',
        ['Melhorar a resolução do ADC automaticamente', 'Alterar a temperatura medida', 'Criar novos pinos físicos'],
        'O watchdog pode sinalizar ou reiniciar conforme a configuração para recuperar execução anormal.',
      ),
    ],
    'redes-industriais': [
      BankItem(
        'Dois dispositivos que exigem endereços únicos usam o mesmo identificador. Qual o risco?',
        'Conflito de endereçamento',
        ['Dobro automático de desempenho', 'Imunidade total a ruído', 'Redução garantida de latência'],
        'Endereços duplicados podem impedir identificar e direcionar mensagens corretamente.',
      ),
      BankItem(
        'Uma resposta de exceção de protocolo significa necessariamente cabo desconectado?',
        'Não',
        ['Sim, sempre', 'Sim, pois não houve mensagem', 'Sim, independentemente do protocolo'],
        'O recebimento de uma resposta demonstra que houve comunicação suficiente para retornar uma condição de erro.',
      ),
      BankItem(
        'Qual diagnóstico deve preceder uma conclusão de falha da aplicação quando não existe enlace?',
        'Verificar conexões, alimentação e condições físicas',
        ['Trocar todos os cálculos do processo', 'Reescrever a IHM sem medir', 'Ignorar indicadores físicos'],
        'Uma falha física pode impedir qualquer serviço de aplicação.',
      ),
      BankItem(
        'Para correlacionar uma perda de comunicação com outro evento, qual dado é especialmente útil?',
        'Horário dos eventos e das mensagens',
        ['Apenas a cor do logotipo', 'Somente o peso do painel', 'A marca do mouse'],
        'A correlação temporal permite comparar ocorrência, duração e sequência.',
      ),
    ],
    'cnc-manufatura': [
      BankItem(
        'Em modo incremental, X = 18 mm recebe deslocamento +7 mm. Qual a posição final?',
        '25 mm',
        ['7 mm', '11 mm', '126 mm'],
        'A posição final é 18+7 = 25 mm.',
      ),
      BankItem(
        'Uma máquina produz uma peça a cada 24 s sem paradas. Qual a produção teórica em uma hora?',
        '150 peças',
        ['24 peças', '60 peças', '240 peças'],
        '3600/24 = 150 peças.',
      ),
      BankItem(
        'Por que verificar a origem ativa antes de executar movimentos absolutos?',
        'Porque ela define a referência das coordenadas programadas',
        ['Porque elimina a necessidade de ferramenta', 'Porque altera a composição do material', 'Porque dispensa a fixação'],
        'Coordenadas absolutas dependem do sistema de referência ativo.',
      ),
      BankItem(
        'Uma linha tem etapas de 90, 70 e 100 peças/h. Qual sua capacidade sustentada máxima nessas condições?',
        '70 peças/h',
        ['260 peças/h', '100 peças/h', '90 peças/h'],
        'A etapa de 70 peças/h é o gargalo do fluxo em série.',
      ),
    ],
    'projetos-manutencao': [
      BankItem(
        'Qual formulação é mais verificável como requisito de tempo?',
        'Responder em até 2 s nas condições de ensaio definidas',
        ['Responder muito rápido', 'Ser moderno', 'Ser sempre bom'],
        'Um limite e condições de verificação permitem avaliar atendimento objetivamente.',
      ),
      BankItem(
        'Monitorar uma variável do ativo para orientar intervenção caracteriza abordagem:',
        'Baseada em condição',
        ['Obrigatoriamente corretiva após quebra', 'Sem diagnóstico', 'Apenas documental'],
        'O estado medido do equipamento orienta a decisão.',
      ),
      BankItem(
        'Um relatório afirma uma causa sem apresentar medições ou testes. Qual lacuna existe?',
        'Falta de evidência para sustentar a conclusão',
        ['Excesso obrigatório de dados', 'Garantia de causa correta', 'Ausência de necessidade de diagnóstico'],
        'Conclusões técnicas precisam ser apoiadas por evidências adequadas.',
      ),
      BankItem(
        'Uma peça foi substituída por outra de especificação diferente. Qual ação documental é necessária?',
        'Revisar registros e documentos afetados pela alteração',
        ['Apagar o histórico', 'Não registrar por ser manutenção', 'Mudar somente o nome do técnico'],
        'A documentação deve refletir a configuração e permitir rastrear mudanças.',
      ),
    ],
    'qualidade-gestao-ambiente': [
      BankItem(
        'Em 800 unidades, 24 são não conformes. Qual a taxa?',
        '3%',
        ['24%', '30%', '0,3%'],
        '24/800 = 0,03 = 3%.',
      ),
      BankItem(
        'O consumo caiu de 400 kWh para 300 kWh para a mesma produção. Qual a redução percentual?',
        '25%',
        ['75%', '33,3%', '10%'],
        '(400−300)/400 = 0,25 = 25%.',
      ),
      BankItem(
        'Um projeto ganha nova funcionalidade. O planejamento deve:',
        'Avaliar impactos em escopo, recursos, prazo e riscos',
        ['Assumir impacto nulo automaticamente', 'Eliminar critérios de aceitação', 'Ignorar dependências'],
        'Mudanças afetam compromissos e devem ser avaliadas de forma integrada.',
      ),
      BankItem(
        'No PDCA, após verificar uma diferença entre resultado e objetivo, a etapa Act pode incluir:',
        'Ações corretivas e padronização do que foi validado',
        ['Ignorar a diferença', 'Apagar os indicadores', 'Encerrar toda medição permanentemente'],
        'A ação de melhoria usa os resultados da verificação para corrigir e consolidar práticas.',
      ),
    ],
  };

  static List<Question> forModule(TrailModule module) => [
    for (var i = 0; i < (practice[module.id]?.length ?? 0); i++)
      practice[module.id]![i].question(
        'bank-v2-${module.id}-$i', module.title, module.order + i),
  ];

  static Quiz finalExam(Quiz original, String trailId) {
    final bank = assessment[trailId];
    if (bank == null || bank.isEmpty) {
      throw StateError('Banco de avaliação ausente: $trailId');
    }
    return Quiz(
      id: original.id,
      title: original.title,
      topic: original.topic,
      questions: [
        for (var i = 0; i < bank.length; i++)
          bank[i].question('exam-v2-$trailId-$i', original.topic, i + 1),
      ],
      rewardXp: original.rewardXp,
      timeLimitSeconds: original.timeLimitSeconds,
      badgeId: original.badgeId,
    );
  }
}
