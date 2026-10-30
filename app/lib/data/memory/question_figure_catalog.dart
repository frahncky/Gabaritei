import 'dart:math' as math;

import '../../domain/models/content.dart';
import '../../domain/models/question_figure.dart';

/// Vínculos explícitos por ID: nenhum valor é inferido do texto ou gabarito.
class QuestionFigureCatalog {
  QuestionFigureCatalog._();

  static Question attach(Question question) {
    final figure = figures[question.id];
    return figure == null || question.figure != null
        ? question : question.withFigure(figure);
  }

  static final Map<String, QuestionFigure> figures = {

    // Eletricidade básica: mesmos valores e topologias do enunciado.
    'ohm-1': _series('12 V', ['R = 220 Ω']),
    'ohm-2': _series('10 V', ['R = ?'], note: 'Corrente informada: 2 A.'),
    'ohm-3': _series('V = ?', ['R = 1 kΩ'], note: 'Corrente informada: 5 mA.'),
    'assoc-1': _series('Fonte', ['R1 = 100 Ω', 'R2 = 100 Ω']),
    'assoc-2': _parallel('Fonte', ['R1 = 100 Ω', 'R2 = 100 Ω']),
    'assoc-3': _parallel('Fonte', ['R1 = 6 Ω', 'R2 = 3 Ω']),
    'assoc-4': _series('Fonte', ['R1', 'R2', 'R3']),
    'ohm-5': _blocks(['127 V', 'Lâmpada\n60 W', 'I = ?'],
      'Carga de 60 W alimentada em 127 V. A corrente é a grandeza procurada.'),
    'bank-v2-eb-2-0': _series('V = ?', ['R = 330 Ω'], note: 'Corrente: 20 mA.'),
    'bank-v2-eb-4-0': _parallel('Fonte', ['R1 = 90 Ω', 'R2 = 90 Ω', 'R3 = 90 Ω']),
    'bank-v2-eb-4-1': _mixed('Fonte', ['R1 = 10 Ω', 'R2 = 20 Ω', 'R3 = 20 Ω']),
    'bank-v2-eb-6-0': _series('12 V', ['R1 = 3 kΩ', 'R2 = 1 kΩ'],
      note: 'Saída medida sobre R2. Divisor sem carga.'),
    'exam-v2-eletricidade-basica-0': _series('24 V', ['R = 48 Ω']),
    'exam-v2-eletricidade-basica-1': _series('20 V', ['R1 = 2 Ω', 'R2 = 3 Ω', 'R3 = 5 Ω']),
    // Eletrônica analógica: faixas e circuitos com hipóteses explícitas.
    'cores-1': _bands(['marrom', 'preto', 'vermelho', 'dourado']),
    'cores-2': _bands(['vermelho', 'vermelho', 'marrom']),
    'cores-3': _bands(['amarelo', 'violeta', 'laranja']),
    'bank-v2-ea-2-0': _series('10 V', ['D = 0,7 V', 'R = 1 kΩ'],
      note: 'Diodo em condução direta, segundo a queda adotada no problema.'),
    'bank-v2-ea-2-1': _rectifiedWave(),
    'bank-v2-ea-3-0': _table(['Grandeza', 'Dado'],
      [['β', '100'], ['IB', '20 µA'], ['IC', '?']],
      'Modelo ativo IC = βIB; β = 100 e IB = 20 µA.'),
    'bank-v2-ea-4-0': _blocks(['Vin', 'Não inversor\nRf 30 kΩ\nRg 10 kΩ', 'Vout'],
      'Amplificador não inversor ideal. Resistência de realimentação 30 kΩ e resistência à referência 10 kΩ.'),
    'bank-v2-ea-5-0': _series('Entrada', ['R = 1 kΩ', 'C = 1 µF'],
      note: 'Rede RC; frequência de corte procurada.'),
    'exam-v2-eletronica-analogica-0': _series('5 V', ['D = 0,6 V', 'R = 2 kΩ']),
    'exam-v2-eletronica-analogica-1': _blocks(['Vin\n0,4 V', 'Inversor\nRin 5 kΩ\nRf 15 kΩ', 'Vout = ?'],
      'Inversor ideal, sem saturação, com Rin de 5 kΩ e Rf de 15 kΩ.'),
    // Lógica digital: saídas em aberto para o aluno completar.
    'bank-v2-ed-1-0': _table(['Parcela', 'Binário'],
      [['Primeira', '0111'], ['Segunda', '0001'], ['Soma', '????']],
      'Soma de dois números binários de quatro bits, sem sinal.'),
    'bank-v2-ed-2-0': _truth('NAND', 'A = 1; B = 1.'),
    'bank-v2-ed-2-1': _truth('OR', 'A = 0; B = 1.'),
    'bank-v2-ed-3-1': _blocks(['A B C', 'Decodificador', 'Saídas\n?'],
      'Decodificador binário com três entradas independentes.'),
    'bank-v2-ed-4-0': _chart('Registro na borda de subida',
      'D permanece em 1. A amostra ocorre na borda de subida do clock; Q não está desenhado.',
      'Tempo normalizado', 'Nível lógico', 0, 4, -.2, 1.2,
      [const FigureTrace('Clock', [FigurePoint(0,0), FigurePoint(1,0), FigurePoint(1,1),
        FigurePoint(2,1), FigurePoint(2,0), FigurePoint(3,0), FigurePoint(3,1), FigurePoint(4,1)]),
       const FigureTrace('D', [FigurePoint(0,1), FigurePoint(4,1)])]),
    'exam-v2-eletronica-digital-0': _table(['Posição', '3', '2', '1', '0'],
      [['Bit', '1', '1', '0', '1']], 'Número binário 1101; posições do bit mais significativo ao menos significativo.'),
    'exam-v2-eletronica-digital-1': _ladder([['A','C'], ['B','C']], 'Y', 'A = 0; B = 1; C = 0. Rede equivalente a (A OU B) E C.'),
    // Instalações: condutores, documentação e comando.
    'bank-v2-ie-1-1': _table(['Planta', 'Quadro'],
      [['C1: iluminação', 'C1: iluminação'], ['C2: tomadas', 'C2: tomadas']],
      'Exemplo de identificação coerente entre os documentos de dois circuitos.'),
    'bank-v2-ie-2-0': _dimension('Comprimento inicial L e depois 2L', 'Mesmo material e mesma seção',
      'Comparação conceitual: a seção e o material são mantidos; somente o comprimento dobra. Desenho sem escala física.'),
    'bank-v2-ie-4-0': _ladder([['!Parada','Partida'], ['!Parada','K']], 'K',
      'Comando convencional de partida e selo. Parada é contato NF; K é auxiliar NA do próprio contator. Esquema didático de comando.'),
    'bank-v2-ie-4-1': _ladder([['Partida'], ['K']], 'K',
      'Botão de partida em paralelo ao contato auxiliar NA K: circuito de selo convencional.'),
    'exam-v2-instalacoes-eletricas-0': _series('Alimentação', ['Rpercurso = 0,3 Ω'],
      note: 'Corrente de 15 A. A resistência representa todo o percurso dos condutores.'),
    'exam-v2-instalacoes-eletricas-3': _ladder([['Partida','!K2']], 'K1',
      'Bobina K1 em série com contato auxiliar NF do contator oposto K2.'),
    // CLP: contatos, temporização e conversão de sinal.
    'bank-v2-clp-1-0': _ladder([['A','B'], ['A','C']], 'Y',
      'A em série com B OU C, representado por dois caminhos logicamente equivalentes.'),
    'bank-v2-clp-1-1': _ladder([['A','!B']], 'Y', 'A = 1; B = 1; Y não está indicado.'),
    'bank-v2-clp-2-0': _blocks(['Ler\nentradas', 'Executar\nprograma', 'Atualizar\nsaídas'],
      'Ciclo básico com imagem de processo: a próxima leitura ocorre na próxima atualização das entradas.'),
    'bank-v2-clp-3-0': _chart('Entrada de um TON de 5 s',
      'A entrada permanece ativa de 0 a 3 segundos e depois volta a zero. Tempo configurado: 5 segundos. Saída não exibida.',
      'Tempo (s)', 'Entrada lógica', 0, 6, -.2, 1.2,
      [const FigureTrace('Entrada', [FigurePoint(0,1), FigurePoint(3,1), FigurePoint(3,0), FigurePoint(6,0)])]),
    'bank-v2-clp-3-1': _chart('Um sinal mantido em nível alto',
      'Uma única transição inicial de 0 para 1, seguida por permanência em 1 durante dez varreduras.',
      'Varreduras após a subida', 'Entrada lógica', -1, 10, -.2, 1.2,
      [const FigureTrace('Entrada', [FigurePoint(-1,0), FigurePoint(0,0), FigurePoint(0,1), FigurePoint(10,1)])]),
    'bank-v2-clp-4-0': _calibration(0, 10, 0, 500, 'Tensão (V)', 'Velocidade (rpm)'),
    'bank-v2-clp-4-1': _calibration(4, 20, 0, 10, 'Corrente (mA)', 'Pressão (bar)'),
    'exam-v2-clp-automacao-0': _ladder([['A','B'], ['C']], 'Y', 'A = 1; B = 0; C = 1.'),
    'exam-v2-clp-automacao-2': _calibration(4, 20, 0, 80, 'Corrente (mA)', 'Vazão (L/min)'),
    // Circuitos CC e CA.
    'circuitos-cc-3-1': _series('Fonte', ['R = 10 kΩ', 'C = 100 µF'],
      note: 'Rede RC de primeira ordem. A constante de tempo é desconhecida.'),
    'circuitos-cc-3-2': _series('Fonte', ['R = 10 Ω', 'L = 0,2 H'],
      note: 'Rede RL de primeira ordem. A constante de tempo é desconhecida.'),
    'circuitos-ca-2-1': _series('CA', ['R = 3 Ω', 'XL = 4 Ω'], alternating: true,
      note: 'R é resistência; XL é a reatância indutiva na frequência de operação.'),
    'circuitos-ca-2-2': _series('CA', ['R', 'XL = 20 Ω', 'XC = 30 Ω'], alternating: true,
      note: 'RLC série. Somente as reatâncias XL e XC são dadas; a pergunta trata da reatância resultante.'),
    'bank-v2-circuitos-cc-1-0': _series('V = ?', ['R1 = 5 Ω', 'R2 = 15 Ω'], note: 'Corrente de 0,4 A.'),
    'bank-v2-circuitos-cc-1-1': _parallel('24 V', ['R1 = 12 Ω', 'R2 = 12 Ω']),
    'bank-v2-circuitos-cc-2-1': _series('18 V', ['R1 = 3 Ω', 'R2 = ?'], note: 'Corrente de 2 A.'),
    'bank-v2-circuitos-cc-3-0': _chart('Descarga RC normalizada',
      'Capacitor descarregando: v/V0 = exp(−t/τ). Observe a curva em t/τ = 1.',
      'Tempo t/τ', 'Tensão v/V0', 0, 4, 0, 1,
      [FigureTrace('v/V0', [for (var i=0; i<=100; i++) FigurePoint(i/25, math.exp(-i/25))])]),
    'exam-v2-circuitos-cc-1': _parallel('Fonte', ['R1 = 8 Ω', 'R2 = 24 Ω']),
    'bank-v2-circuitos-ca-1-0': _wave(25, 1, 'Senoide de 25 Hz com amplitude normalizada.'),
    'bank-v2-circuitos-ca-1-1': _normalizedPhase(),
    'bank-v2-circuitos-ca-2-1': _phasor(6, 8, 'R = 6 Ω', 'X = 8 Ω', 'Z = ?'),
    'bank-v2-circuitos-ca-3-0': _phasor(400, 300, 'P = 400 W', 'Q = 300 var', 'S = ?'),
    'exam-v2-circuitos-ca-0': _wave(100, 1, 'Senoide com período informado de 10 ms. Amplitude normalizada.'),
    'exam-v2-circuitos-ca-1': _phasor(8, 6, 'R = 8 Ω', 'X = 6 Ω', 'Z = ?'),
    'exam-v2-circuitos-ca-3': _wave(50, 1, 'Senoides de 50 Hz. O segundo sinal atrasa 5 ms.', delayMs: 5),
    // Potência e segurança.
    'bank-v2-eletronica-potencia-2-0': _blocks(['40 V CC', 'Buck ideal\nD = 0,3', 'Vout = ?'],
      'Conversor buck ideal em condução contínua, com entrada de 40 V e razão cíclica 0,3.'),
    'bank-v2-eletronica-potencia-2-1': _blocks(['12 V CC', 'Boost ideal\nD = 0,5', 'Vout = ?'],
      'Conversor boost ideal em condução contínua, com entrada de 12 V e razão cíclica 0,5.'),
    'bank-v2-eletronica-potencia-3-1': _chart('Comandos complementares com intervalo',
      'Exemplo normalizado de comando: há intervalo em que as duas chaves ficam desligadas. Valores de tempo são ilustrativos.',
      'Tempo normalizado', 'Comando lógico', 0, 4, -.2, 1.2,
      [const FigureTrace('Chave superior', [FigurePoint(0,1), FigurePoint(1.8,1), FigurePoint(1.8,0), FigurePoint(4,0)]),
       const FigureTrace('Chave inferior', [FigurePoint(0,0), FigurePoint(2.2,0), FigurePoint(2.2,1), FigurePoint(4,1)])]),
    'exam-v2-eletronica-potencia-0': _blocks(['30 V CC', 'Buck ideal\nD = 0,4', 'Vout = ?'],
      'Buck ideal, entrada de 30 V, razão cíclica 0,4 e condução contínua.'),
    'bank-v2-seguranca-normas-1-0': _blocks(['Local anterior', 'Novo local', 'Outra fonte'],
      'Mudança de condições: um novo local possui fonte adicional de energia. Esquema conceitual, não procedimento de intervenção.'),
    'bank-v2-seguranca-normas-2-0': _table(['Fonte', 'Condição no problema'],
      [['Principal', 'Desligada'], ['Auxiliar', 'Deve ser considerada']],
      'Duas fontes podem alimentar o sistema. A pergunta informa desligamento apenas da principal.'),
    'bank-v2-seguranca-normas-2-1': _table(['Registro', 'Informação'],
      [['Ponto', 'Identificação'], ['Responsável', 'Identificação'], ['Estado', 'Condição de bloqueio']],
      'Campos de rastreabilidade do bloqueio, conforme o procedimento aplicável.'),
    'exam-v2-seguranca-normas-0': _topology(['Equipamento', 'Rede externa', 'Bateria interna'],
      'Existem alimentação externa e bateria interna. O esquema apenas identifica fontes possíveis.'),
    // Máquinas e robótica.
    'bank-v2-maquinas-eletricas-1-0': _blocks(['Primário\n200 V; I1 ?', 'Transformador\nideal', 'Secundário\n50 V; 4 A'],
      'Transformador ideal com 200 V no primário e 50 V, 4 A no secundário.'),
    'bank-v2-maquinas-eletricas-2-0': _table(['Grandeza', 'Dado'],
      [['Velocidade síncrona', '1200 rpm'], ['Escorregamento', '4%'], ['Rotação do rotor', '?']],
      'Dados do motor para calcular sua rotação.'),
    'bank-v2-maquinas-eletricas-3-1': _table(['Alimentação', 'Máquina'],
      [['60 Hz', '6 polos'], ['Velocidade síncrona', '?']],
      'Máquina síncrona de seis polos ligada à frequência de 60 Hz.'),
    'exam-v2-maquinas-eletricas-0': _blocks(['100 V', 'Ideal\nN1/N2 = 5', 'V2 = ?'],
      'Transformador ideal: entrada de 100 V e relação de espiras N1/N2 igual a cinco.'),
    'bank-v2-robotica-1-0': _blocks(['Pose desejada', 'Modelo inverso', 'Saída = ?'],
      'O problema fornece a pose desejada a um modelo cinemático inverso; a saída deve ser identificada.'),
    'bank-v2-robotica-1-1': _mechanical(FigureKind.robotArm,
      ['Junta 1', 'Junta 2', 'Efetuador'], [], 'Braço planar',
      'Duas juntas rotativas independentes ligam a base ao efetuador. Esquema sem escala.'),
    'bank-v2-robotica-2-0': _table(['Encoder', 'Deslocamento'],
      [['1000 pulsos/volta', '1/2 volta'], ['Pulsos contados', '?']],
      'Contagem sem multiplicação: mil pulsos por volta e meia volta de deslocamento.'),
    'exam-v2-robotica-0': _table(['Resolução', 'Contagem observada'],
      [['800 pulsos/volta', '200 pulsos'], ['Deslocamento angular', '?']],
      'Encoder sem multiplicação de contagem. Dados informados: 800 pulsos por volta e 200 pulsos medidos.'),
    // Supervisório e processos.
    'bank-v2-supervisorios-processos-1-0': _blocks(['Erro e = 3', 'Kp = 2', 'u = ?'],
      'Ação proporcional u = Kp vezes e, antes de limites e termos adicionais.'),
    'bank-v2-supervisorios-processos-2-0': _table(['Valor mostrado', 'Qualidade temporal'],
      [['Última medição', 'Sem atualização'], ['Estado da conexão', 'Precisa ser indicado']],
      'Uma leitura antiga não deve ser confundida com dado atual. Tabela conceitual sem valores adicionais.'),
    'bank-v2-supervisorios-processos-3-0': _blocks(['Sensor', 'Controlador', 'Resistência', 'Planta'],
      'Malha fechada de temperatura: o sensor fornece realimentação e a resistência atua sobre a planta.', feedback: true),
    'exam-v2-supervisorios-processos-0': _chart('Referência e medição',
      'Valores informados na questão: SP = 120 kPa e PV = 128 kPa. As linhas constantes são apenas representação desses valores.',
      'Tempo normalizado', 'Pressão (kPa)', 0, 4, 110, 140,
      [const FigureTrace('SP', [FigurePoint(0,120), FigurePoint(4,120)]),
       const FigureTrace('PV', [FigurePoint(0,128), FigurePoint(4,128)])]),

    // Telecomunicações.
    'bank-v2-telecomunicacoes-1-0': _chart('Portadora com espaçamento variável',
      'Exemplo qualitativo de FM: amplitude normalizada constante; o espaçamento entre ciclos varia. Frequência numérica não é dado do problema.',
      'Tempo normalizado', 'Amplitude normalizada', 0, 4, -1.2, 1.2,
      [FigureTrace('Portadora', [for (var i=0; i<=200; i++)
        FigurePoint(i/50, math.sin(2*math.pi*(i/50 + .18*math.sin(i/50))))])]),
    'bank-v2-telecomunicacoes-2-0': _blocks(['Sinal elétrico', 'Transmissor', 'Fibra óptica'],
      'Um sinal elétrico chega ao transmissor e a informação segue pela fibra óptica.'),
    'bank-v2-telecomunicacoes-3-0': _table(['Quantidade', 'Taxa', 'Tempo'],
      [['24 kbit', '6 kbit/s', '?']],
      'Dados de transmissão sem cabeçalhos: 24 kbit e 6 kbit por segundo.'),
    'exam-v2-telecomunicacoes-0': _table(['Dados', 'Taxa', 'Tempo'],
      [['12000 bits', '3000 bit/s', '?']], 'Dados e taxa informados para calcular o tempo de transmissão.'),
    // Programação: acompanhamento e estrutura de dados.
    'bank-v2-programacao-1-0': _table(['Passo', 'Parcela somada', 'Acumulador'],
      [['Inicial', '—', '0'], ['1', '1', '?'], ['2', '2', '?'], ['3', '3', '?'], ['4', '4', '?']],
      'Acumulador inicialmente zero; as parcelas 1, 2, 3 e 4 são somadas nessa ordem.'),
    'bank-v2-programacao-2-0': _table(['Entrada', 'Ordem de chegada'],
      [['A', '1ª'], ['B', '2ª'], ['C', '3ª']],
      'Itens A, B e C chegam nessa ordem a uma fila. A ordem de saída não está indicada.'),
    'bank-v2-programacao-3-1': _blocks(['Requisição', 'Aguardando', 'Sem resposta'],
      'A operação de rede aguarda uma resposta que não chega; a figura não define o tratamento da falha.'),
    'exam-v2-programacao-0': _table(['Operação', 'Dado'],
      [['Valor inicial', '2'], ['Incremento', '+2'], ['Repetições', '3'], ['Valor final', '?']],
      'Contador inicia em 2 e recebe três incrementos de duas unidades.'),
    // Matemática e física.
    'bank-v2-matematica-fisica-1-1': _phasor(6, 8, 'x = 6', 'y = 8', '|v| = ?'),
    'bank-v2-matematica-fisica-2-0': _blocks(['Massa\n3 kg', 'Força resultante\n12 N', 'a = ?'],
      'Corpo de massa 3 kg submetido a força resultante de 12 N.'),
    'bank-v2-matematica-fisica-3-0': _wave(150, 1,
      'O problema informa frequência de 150 Hz e comprimento de onda de 2 m. A amplitude do gráfico é normalizada.'),
    'exam-v2-matematica-fisica-3': _table(['Energia', 'Intervalo', 'Potência média'],
      [['600 J', '30 s', '?']], 'Transferência de 600 J no intervalo de 30 s.'),
    // CAD.
    'bank-v2-desenho-cad-2-0': _dimension('Dimensão real = 120 mm', 'Escala 1:4',
      'Representação de uma dimensão real de 120 mm em escala 1:4. Não medir pixels: a figura é esquemática.'),
    'bank-v2-desenho-cad-2-1': _dimension('Comprimento no papel = 90 mm', 'Escala 3:1',
      'Comprimento gráfico informado: 90 mm. Escala de ampliação 3:1. A dimensão real é desconhecida.'),
    'bank-v2-desenho-cad-3-0': _table(['Elemento', 'Comprimento'],
      [['Linha A', 'L'], ['Linha B', 'L']],
      'Duas linhas devem conservar o mesmo comprimento L após alterações.'),
    'exam-v2-desenho-cad-0': _dimension('Dimensão real = 75 mm', 'Escala 1:5',
      'Dimensão real 75 mm e escala de redução 1:5. A representação na tela não tem escala física.'),
    // Metrologia.
    'bank-v2-metrologia-1-0': _series('Fonte', ['Ramo de carga'],
      note: 'Corrente medida no próprio ramo; posição do amperímetro a definir no exercício.'),
    'bank-v2-metrologia-2-0': _bars(['Referência', 'Indicação'], [50,49.5], 'mm',
      'Comparação de medição', 'Referência de 50,0 mm e indicação de 49,5 mm. Barras com origem zero.'),
    'bank-v2-metrologia-3-0': _blocks(['Antes do ajuste', 'Ajuste', 'Após o ajuste'],
      'O comportamento de um instrumento pode ser alterado durante um ajuste. Não são atribuídos erros ou correções numéricos.'),
    'exam-v2-metrologia-0': _table(['Referência', 'Indicação', 'Erro'],
      [['100,0 kPa', '101,2 kPa', '?']], 'Comparação entre indicação de 101,2 kPa e referência de 100,0 kPa.'),
    // Materiais e fabricação.
    'bank-v2-materiais-fabricacao-1-0': _table(['Condição', 'Avaliação necessária'],
      [['Temperatura ambiente', 'Propriedades de referência'], ['Temperatura elevada', '?']],
      'O componente operará a temperatura elevada. Não se presume que as propriedades permaneçam iguais.'),
    'bank-v2-materiais-fabricacao-2-0': _blocks(['Peça bruta', 'Furação', 'Peça + material\nremovido'],
      'Uma broca remove material de uma peça durante a operação de furação.'),
    'bank-v2-materiais-fabricacao-3-0': _blocks(['Montagem', 'Acesso periódico', 'Desmontagem'],
      'Requisito de manutenção: o conjunto precisa ser aberto periodicamente.'),
    'exam-v2-materiais-fabricacao-1': _blocks(['Peça', 'Torneamento', 'Peça + material\nremovido'],
      'O problema descreve torneamento com remoção de cavacos; o processo deve ser classificado.'),
    // Mecânica.
    'bank-v2-mecanica-maquinas-1-0': _mechanical(FigureKind.lever,
      ['F = 200 N', 'Braço perpendicular = 0,3 m'], [], 'Momento de uma força',
      'Força de 200 N perpendicular à alavanca, a 0,3 m do eixo. O momento não está indicado.'),
    'bank-v2-mecanica-maquinas-1-1': _mechanical(FigureKind.force,
      ['F = 3000 N', 'Área = 150 mm²'], [], 'Solicitação axial',
      'Módulo da força axial 3000 N, área da seção 150 mm². Representação esquemática.'),
    'bank-v2-mecanica-maquinas-2-0': _mechanical(FigureKind.gears,
      ['Z1 = 15; n1 = 800 rpm', 'Z2 = 60; n2 = ?'], [15,60], 'Par de engrenagens',
      'Engrenagem motora de 15 dentes a 800 rpm; movida de 60 dentes. O sentido não é necessário para o módulo da rotação.'),
    'exam-v2-mecanica-maquinas-0': _mechanical(FigureKind.lever,
      ['F = 80 N', 'Braço perpendicular = 0,5 m'], [], 'Momento de uma força',
      'Força perpendicular de 80 N aplicada a 0,5 m do eixo.'),
    'exam-v2-mecanica-maquinas-1': _mechanical(FigureKind.gears,
      ['Z1 = 25; n1 = 900 rpm', 'Z2 = 75; n2 = ?'], [25,75], 'Transmissão por engrenagens',
      'Engrenagem motora com 25 dentes a 900 rpm aciona uma engrenagem de 75 dentes.'),
    // Pneumática e hidráulica.
    'bank-v2-pneumatica-hidraulica-1-1': _blocks(['Alimentação', 'Regulador', 'Linha a jusante'],
      'O regulador está entre a alimentação e a linha a jusante.'),
    'bank-v2-pneumatica-hidraulica-2-0': _mechanical(FigureKind.cylinder,
      ['p = 500 kPa', 'Área útil = 0,002 m²'], [], 'Cilindro ideal',
      'Pressão de 500 kPa atua sobre área útil de 0,002 m². A força é desconhecida; perdas e atrito são desprezados.'),
    'bank-v2-pneumatica-hidraulica-3-1': _table(['Observação', 'Estado'],
      [['Bobina', 'Recebe comando'], ['Cilindro', 'Sem movimento']],
      'Sintoma informado: há comando elétrico, mas o cilindro não se move. Outras condições ainda precisam ser verificadas.'),
    'exam-v2-pneumatica-hidraulica-0': _mechanical(FigureKind.cylinder,
      ['p = 200 kPa', 'Área útil = 0,004 m²'], [], 'Força de um cilindro',
      'Cilindro ideal, pressão 200 kPa e área útil 0,004 m².'),
    // Sensores e instrumentação.
    'bank-v2-sensores-instrumentacao-1-1': _table(['Sensor', 'Processo'],
      [['Faixa 0–50 °C', 'Condição de 120 °C']], 'Faixa nominal do sensor e condição de uso informadas no problema.'),
    'bank-v2-sensores-instrumentacao-2-0': _blocks(['20 mV', 'Amplificador\nganho 100', 'Vout = ?'],
      'Amplificação ideal de sinal de 20 mV, ganho 100 e ausência de saturação.'),
    'bank-v2-sensores-instrumentacao-2-1': _calibration(4,20,0,400,'Corrente (mA)','Vazão (L/min)'),
    'bank-v2-sensores-instrumentacao-3-0': _calibration(4,20,0,100,'Corrente (mA)','Pressão (bar)'),
    'exam-v2-sensores-instrumentacao-0': _calibration(4,20,0,300,'Corrente (mA)','Temperatura (°C)'),
    // Sistemas embarcados.
    'bank-v2-microcontroladores-embarcados-1-0': _blocks(['Entrada\nanalógica', 'ADC\n8 bits', 'Códigos = ?'],
      'Conversor analógico-digital ideal de oito bits. O número de códigos não é mostrado.'),
    'bank-v2-microcontroladores-embarcados-2-0': _table(['Tarefa', 'Necessidade'],
      [['Botão', 'Verificar continuamente'], ['Intervalo', 'Ainda em andamento']],
      'O firmware precisa verificar um botão enquanto aguarda um intervalo.'),
    'bank-v2-microcontroladores-embarcados-3-1': _topology(
      ['Barramento I²C', 'Dispositivo A\nEndereço x', 'Dispositivo B\nEndereço x'],
      'Dois dispositivos no mesmo barramento possuem o mesmo endereço fixo x. Linhas representam conexão lógica, não pinagem.'),
    'exam-v2-microcontroladores-embarcados-0': _blocks(['Entrada\nanalógica', 'ADC\n9 bits', 'Códigos = ?'],
      'Conversor ideal de nove bits. O número de códigos é a grandeza procurada.'),
    // Redes industriais.
    'bank-v2-redes-industriais-1-0': _topology(
      ['Switch', 'CLP', 'IHM', 'Dispositivo'],
      'Três dispositivos têm enlaces independentes até um switch central. Conexões lógicas, sem escala ou pinagem.'),
    'bank-v2-redes-industriais-2-0': _blocks(['Cliente\nPedido', 'Servidor', 'Resposta\nExceção'],
      'O cliente envia um pedido e recebe uma resposta de exceção do servidor. A falha deve ser interpretada.'),
    'bank-v2-redes-industriais-3-1': _table(['Registro', 'Horário'],
      [['Evento do processo', 't1'], ['Mensagem de rede', 't2']],
      'Dois registros têm horários para permitir comparar a sequência temporal.'),
    'exam-v2-redes-industriais-0': _topology(
      ['Rede', 'Nó A\nEndereço x', 'Nó B\nEndereço x'],
      'Rede que exige endereços únicos: os nós A e B aparecem com o mesmo endereço x.'),
    // CNC e manufatura.
    'bank-v2-cnc-manufatura-1-0': _table(['Posição inicial X', 'Deslocamento', 'Posição final'],
      [['40 mm', '−12 mm', '?']], 'Posicionamento incremental: posição inicial 40 mm e deslocamento de menos 12 mm.'),
    'bank-v2-cnc-manufatura-2-1': _blocks(['Programa', 'Simulação', 'Colisão prevista'],
      'A simulação informa colisão entre ferramenta e fixação. A figura não representa uma trajetória geometricamente válida.'),
    'bank-v2-cnc-manufatura-3-1': _bars(['Etapa A', 'Etapa B'], [100,60], 'peças/h',
      'Capacidade das etapas', 'Etapas em série com capacidades de 100 e 60 peças por hora.'),
    'exam-v2-cnc-manufatura-3': _bars(['Etapa A','Etapa B','Etapa C'], [90,70,100], 'peças/h',
      'Capacidade da linha', 'Etapas em série de 90, 70 e 100 peças por hora.'),
    // Projetos e manutenção.
    'bank-v2-projetos-manutencao-1-0': _table(['Texto do requisito', 'Limite de tempo'],
      [['O sistema deve ser rápido', 'Não definido']],
      'O requisito original não fornece um limite de tempo verificável.'),
    'bank-v2-projetos-manutencao-2-1': _chart('Histórico de vibração',
      'Exemplo qualitativo de tendência crescente ao longo de semanas. Os valores são normalizados, não limites de diagnóstico.',
      'Semanas', 'Vibração normalizada', 0, 4, 0, 1,
      [const FigureTrace('Medição', [FigurePoint(0,.2), FigurePoint(1,.3),
        FigurePoint(2,.42), FigurePoint(3,.6), FigurePoint(4,.8)])]),
    'bank-v2-projetos-manutencao-3-0': _table(['Hipótese', 'Resultado do teste a definir'],
      [['H1', '?'], ['H2', '?']],
      'Duas hipóteses explicam o sintoma; o objetivo é escolher um teste que as diferencie.'),
    'exam-v2-projetos-manutencao-0': _table(['Requisito', 'Condição'],
      [['Tempo de resposta', 'Até 2 s'], ['Ensaio', 'Condições definidas']],
      'Exemplo de requisito com limite temporal e condições de ensaio explícitos.'),
    // Qualidade, gestão e meio ambiente.
    'bank-v2-qualidade-gestao-ambiente-1-0': _bars(['Inspecionados', 'Não conformes'], [500,15], 'itens',
      'Dados de inspeção', 'Foram inspecionados 500 itens; 15 são não conformes. Barras começam em zero.'),
    'bank-v2-qualidade-gestao-ambiente-2-0': _blocks(['Tarefa prevista', 'Equipamento\nindisponível', 'Execução = ?'],
      'A tarefa depende de um equipamento que está indisponível.'),
    'bank-v2-qualidade-gestao-ambiente-3-0': _bars(['Antes', 'Depois'], [250,200], 'kWh',
      'Consumo para a mesma produção', 'Consumo de 250 kWh antes e 200 kWh depois; a produção é a mesma.'),
    'exam-v2-qualidade-gestao-ambiente-0': _bars(['Unidades', 'Não conformes'], [800,24], 'itens',
      'Inspeção de um lote', 'Lote de 800 unidades, das quais 24 são não conformes.'),
    'exam-v2-qualidade-gestao-ambiente-1': _bars(['Antes', 'Depois'], [400,300], 'kWh',
      'Comparação energética', 'Consumo de 400 e 300 kWh para a mesma produção.'),

  };
}

CircuitElement _element(String label) => CircuitElement(label,
  symbol: label.startsWith('C =') || label.startsWith('XC') ? CircuitSymbol.capacitor
    : label.startsWith('L =') || label.startsWith('XL') ? CircuitSymbol.inductor
    : label.startsWith('D =') ? CircuitSymbol.diode : CircuitSymbol.resistor);

QuestionFigure _series(String source, List<String> parts,
    {String note = '', bool alternating = false}) => QuestionFigure(
  kind: FigureKind.seriesCircuit, title: 'Circuito em série',
  description: 'Fonte: $source. Em série: ${parts.join('; ')}. $note',
  sourceLabel: source, elements: [for (final p in parts) _element(p)],
  alternatingSource: alternating,
);

QuestionFigure _parallel(String source, List<String> parts) => QuestionFigure(
  kind: FigureKind.parallelCircuit, title: 'Ramos em paralelo',
  description: 'Fonte: $source. Ramos conectados aos mesmos dois nós: ${parts.join('; ')}.',
  sourceLabel: source, elements: [for (final p in parts) _element(p)],
);

QuestionFigure _mixed(String source, List<String> parts) => QuestionFigure(
  kind: FigureKind.mixedCircuit, title: 'Associação mista',
  description: 'Fonte: $source. ${parts.first} em série com o paralelo de ${parts.skip(1).join(' e ')}.',
  sourceLabel: source, elements: [for (final p in parts) _element(p)],
);

QuestionFigure _wave(double hz, double peak, String given, {double delayMs = 0}) {
  final duration = 2000 / hz;
  return QuestionFigure(
    kind: FigureKind.waveform, title: 'Forma de onda',
    description: given, values: [hz, peak, delayMs],
    xLabel: 'Tempo (ms)', yLabel: peak == 1 ? 'Amplitude normalizada' : 'Tensão (V)',
    xMin: 0, xMax: duration, yMin: -peak * 1.15, yMax: peak * 1.15,
    traces: [
      FigureTrace('Sinal de referência', [for (var i=0; i<=200; i++)
        FigurePoint(duration*i/200, peak*math.sin(2*math.pi*hz*duration*i/200/1000))]),
      if (delayMs != 0)
        FigureTrace('Sinal atrasado', [for (var i=0; i<=200; i++)
          FigurePoint(duration*i/200, peak*math.sin(2*math.pi*hz*(duration*i/200-delayMs)/1000))]),
    ],
  );
}

QuestionFigure _normalizedPhase() => QuestionFigure(
  kind: FigureKind.waveform, title: 'Comparação de fase',
  description: 'Senoides de mesma frequência com atraso Δt = T/4. Tempo e amplitude são normalizados; não há frequência numérica adicional.',
  xLabel: 'Tempo t/T', yLabel: 'Amplitude normalizada',
  xMin: 0, xMax: 2, yMin: -1.15, yMax: 1.15,
  traces: [
    FigureTrace('Referência', [for (var i=0; i<=200; i++)
      FigurePoint(i/100, math.sin(2*math.pi*i/100))]),
    FigureTrace('Atrasado T/4', [for (var i=0; i<=200; i++)
      FigurePoint(i/100, math.sin(2*math.pi*(i/100-.25)))]),
  ],
);

QuestionFigure _phasor(double real, double imaginary, String a, String b, String result) =>
  QuestionFigure(kind: FigureKind.phasor, title: 'Componentes ortogonais',
    description: '$a no eixo horizontal; $b no eixo vertical. A diagonal representa $result.',
    values: [real, imaginary], labels: [a,b,result]);

QuestionFigure _table(List<String> headers, List<List<String>> rows, String description) =>
  QuestionFigure(kind: FigureKind.referenceTable, title: 'Dados da questão',
    description: description, headers: headers, rows: rows);

QuestionFigure _truth(String gate, String inputs) => QuestionFigure(
  kind: FigureKind.truthTable, title: 'Tabela-verdade · $gate',
  description: 'Porta $gate de duas entradas. $inputs As saídas estão em aberto para completar.',
  headers: const ['A','B','Y'], rows: const [['0','0','?'],['0','1','?'],['1','0','?'],['1','1','?']],
);

QuestionFigure _ladder(List<List<String>> paths, String coil, String description) =>
  QuestionFigure(kind: FigureKind.ladder, title: 'Lógica Ladder',
    description: '$description Contatos com barra são NF; os demais são NA. Bobina: $coil.',
    rows: paths, labels: [coil]);

QuestionFigure _chart(String title, String description, String x, String y,
  double xmin, double xmax, double ymin, double ymax, List<FigureTrace> traces) =>
  QuestionFigure(kind: FigureKind.chart, title: title, description: description,
    xLabel: x, yLabel: y, xMin: xmin, xMax: xmax, yMin: ymin, yMax: ymax, traces: traces);

QuestionFigure _calibration(double xmin, double xmax, double ymin, double ymax, String x, String y) =>
  _chart('Relação linear de escala',
    'Escala linear: $x entre $xmin e $xmax corresponde a $y entre $ymin e $ymax. O gráfico contém os extremos informados; valores intermediários devem ser interpretados.',
    x, y, xmin, xmax, ymin, ymax, [
      FigureTrace('Escala', [FigurePoint(xmin,ymin), FigurePoint(xmax,ymax)]),
    ]);

QuestionFigure _blocks(List<String> labels, String description, {bool feedback = false}) =>
  QuestionFigure(kind: FigureKind.blocks, title: 'Diagrama funcional',
    description: description, labels: labels, feedback: feedback);

QuestionFigure _bars(List<String> labels, List<double> values, String unit, String title, String description) =>
  QuestionFigure(kind: FigureKind.bars, title: title,
    description: description, labels: labels, values: values, yLabel: unit);

QuestionFigure _mechanical(FigureKind kind, List<String> labels,
  List<double> values, String title, String description) =>
  QuestionFigure(kind: kind, title: title, description: description,
    labels: labels, values: values);

QuestionFigure _dimension(String dimension, String scale, String description) =>
  _mechanical(FigureKind.dimension, [dimension,scale], [], 'Desenho e escala', description);

QuestionFigure _bands(List<String> names) => QuestionFigure(
  kind: FigureKind.resistorBands, title: 'Faixas do resistor',
  description: 'Da esquerda para a direita: ${names.join(', ')}. O valor da resistência não está indicado.',
  labels: names,
);

QuestionFigure _topology(List<String> labels, String description) =>
  QuestionFigure(kind: FigureKind.topology, title: 'Conexões do sistema',
    description: description, labels: labels);

QuestionFigure _rectifiedWave() {
  const hz = 60.0;
  const duration = 2000 / hz;
  return QuestionFigure(
    kind: FigureKind.waveform, title: 'Retificação de onda completa',
    description: 'Entrada senoidal de 60 Hz e saída ideal de uma ponte sem filtro. '
        'A saída retificada mantém ambos os semiciclos positivos. Amplitudes normalizadas.',
    xLabel: 'Tempo (ms)', yLabel: 'Amplitude normalizada',
    xMin: 0, xMax: duration, yMin: -1.15, yMax: 1.15,
    traces: [
      FigureTrace('Entrada CA', [for (var i=0; i<=200; i++)
        FigurePoint(duration*i/200, math.sin(4*math.pi*i/200))]),
      FigureTrace('Saída retificada', [for (var i=0; i<=200; i++)
        FigurePoint(duration*i/200, math.sin(4*math.pi*i/200).abs())]),
    ],
  );
}
