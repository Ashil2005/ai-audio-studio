
enum PersonaTone {
  calm,
  analytical,
  motivational,
  skeptical,
  philosophical,
}

enum SpeakingStyle {
  short,
  balanced,
  elaborate,
}

class PersonaModel {
  final String id;
  final String name;
  final String description;
  final PersonaTone tone;
  final SpeakingStyle speakingStyle;
  final String prefixStyle;

  const PersonaModel({
    required this.id,
    required this.name,
    required this.description,
    required this.tone,
    required this.speakingStyle,
    required this.prefixStyle,
  });

  factory PersonaModel.fromJson(Map<String, dynamic> json) {
    return PersonaModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      tone: PersonaTone.values.firstWhere(
        (e) => e.name == json['tone'],
        orElse: () => PersonaTone.calm,
      ),
      speakingStyle: SpeakingStyle.values.firstWhere(
        (e) => e.name == json['speakingStyle'],
        orElse: () => SpeakingStyle.balanced,
      ),
      prefixStyle: json['prefixStyle'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tone': tone.name,
      'speakingStyle': speakingStyle.name,
      'prefixStyle': prefixStyle,
    };
  }
}
