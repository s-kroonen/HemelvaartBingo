class EventModel {
  final String id;
  final String name;
  final String? description;
  final bool called;
  final List<int> numbers;
  final List<int> manualNumbers;

  EventModel({
    required this.id,
    required this.name,
    this.description,
    required this.called,
    required this.numbers,
    required this.manualNumbers
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'], // backend strips _id → good
      name: json['name'],
      description: json['description'],
      called: json['called'] ?? false,
      numbers: List<int>.from(json['numbers'] ?? []),
      manualNumbers: List<int>.from(json['manualNumbers'] ?? [])
    );
  }
  static List<EventModel> mockList() => [
    EventModel(
      id: "1",
      name: "Someone repeats a joke",
      description: "",
      called: false,
      numbers: [],
      manualNumbers: []
    ),
  ];
}