class KftcToken {
  final String accessToken;
  final String userSeqNo;

  const KftcToken({required this.accessToken, required this.userSeqNo});

  factory KftcToken.fromJson(Map<String, dynamic> json) => KftcToken(
        accessToken: json['access_token'] as String,
        userSeqNo: json['user_seq_no'] as String,
      );
}
