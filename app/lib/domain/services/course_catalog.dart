import '../models/content.dart';
import 'question_generator.dart';

/// Cursos do catálogo local. Não representam matrículas ou turmas no servidor.
class StudyCourse {
  const StudyCourse(this.type, this.description, this.objective);
  final TechnicalCourse type;
  final String description;
  final String objective;

  String get id => type.name;
  String get title => type.label;
  List<String> get disciplines => QuestionGenerator.topicsFor(type);
}

class CourseCatalog {
  CourseCatalog._();

  static const courses = [
    StudyCourse(
      TechnicalCourse.electrotechnics,
      'Fundamentos, circuitos, máquinas e instalações elétricas.',
      'Relacionar análise de circuitos, conversão de energia e aplicações em instalações e manutenção.',
    ),
    StudyCourse(
      TechnicalCourse.electronics,
      'Circuitos analógicos e digitais, instrumentação e sistemas embarcados.',
      'Estudar dispositivos, sinais, medições e programação aplicada a sistemas eletrônicos.',
    ),
    StudyCourse(
      TechnicalCourse.automation,
      'CLP, sensores, processos, robótica e redes industriais.',
      'Integrar medição, programação e controle em sistemas automatizados.',
    ),
    StudyCourse(
      TechnicalCourse.mechatronics,
      'Integração de mecânica, eletrônica, programação e manufatura.',
      'Relacionar elementos mecânicos e eletrônicos no desenvolvimento de sistemas mecatrônicos.',
    ),
  ];

  /// Chaves da matriz curricular associadas a IDs permanentes de trilhas.
  static const trailIds = <String, String>{
    'Eletricidade básica': 'eletricidade-basica',
    'Eletrônica analógica': 'eletronica-analogica',
    'Eletrônica digital': 'eletronica-digital',
    'Instalações elétricas': 'instalacoes-eletricas',
    'CLP': 'clp-automacao',
    'Circuitos CC': 'circuitos-cc',
    'Circuitos CA': 'circuitos-ca',
    'Eletrônica de potência': 'eletronica-potencia',
    'Segurança e normas': 'seguranca-normas',
    'Máquinas elétricas': 'maquinas-eletricas',
    'Robótica': 'robotica',
    'Supervisórios e controle de processos': 'supervisorios-processos',
    'Telecomunicações': 'telecomunicacoes',
    'Programação': 'programacao',
    'Matemática e física aplicadas': 'matematica-fisica',
    'Desenho técnico e CAD': 'desenho-cad',
    'Metrologia': 'metrologia',
    'Materiais e processos de fabricação': 'materiais-fabricacao',
    'Mecânica e elementos de máquinas': 'mecanica-maquinas',
    'Pneumática e hidráulica': 'pneumatica-hidraulica',
    'Sensores e instrumentação': 'sensores-instrumentacao',
    'Microcontroladores e sistemas embarcados': 'microcontroladores-embarcados',
    'Redes industriais': 'redes-industriais',
    'CNC e manufatura': 'cnc-manufatura',
    'Projetos e manutenção': 'projetos-manutencao',
    'Qualidade, gestão e meio ambiente': 'qualidade-gestao-ambiente',
  };

  static StudyCourse forType(TechnicalCourse type) =>
      courses.firstWhere((course) => course.type == type);

  static List<Trail> trailsFor(TechnicalCourse type, List<Trail> trails) {
    final byId = {for (final trail in trails) trail.id: trail};
    return [
      for (final topic in forType(type).disciplines)
        if (byId[trailIds[topic]] case final Trail trail) trail,
    ];
  }
}
