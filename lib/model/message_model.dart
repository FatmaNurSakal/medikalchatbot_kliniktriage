class MessageModel {
  String msg;
  String sendAt;
  int sendId; // 0 user, 1 bot
  bool isRead;

  MessageModel({
    required this.msg,
    required this.sendAt,
    required this.sendId,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        msg: json['msg'] ?? '',
        sendAt: json['sendAt'] ?? '',
        sendId: json['sendId'] ?? 0,
        isRead: json['isRead'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'msg': msg,
        'sendAt': sendAt,
        'sendId': sendId,
        'isRead': isRead,
      };
}
