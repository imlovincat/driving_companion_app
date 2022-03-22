class AlgorithmJson {
  final List<dynamic> speeding;
  final List<dynamic> braking;
  final List<dynamic> accelerating;

  AlgorithmJson(this.speeding,this.braking,this.accelerating);

  AlgorithmJson.fromJson(Map<String,dynamic> json):
    speeding = json['speeding'],
    braking = json['braking'],
    accelerating = json['accelerating'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['speeding'] = this.speeding;
    data['braking'] = this.braking;
    data['accelerating'] = this.accelerating;
    return data;
  }
}
