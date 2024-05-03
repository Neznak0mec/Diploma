class MyAudio{
  String? radioName;
  String fileName;
  String folderName;
  DateTime startRecording;
  DateTime endRecording;
  int status;

  MyAudio({required this.radioName,required this.fileName,required this.folderName,required this.startRecording,required this.endRecording,required this.status});

  factory MyAudio.fromJson(Map<String, dynamic> json) {
    return MyAudio(
      radioName: json['radioName'],
      fileName: json['fileName'],
      folderName: json['folderName'],
      startRecording: DateTime.parse(json['startRecording']),
      endRecording: DateTime.parse(json['endRecording']),
      status: json['status']
    );
  }
}