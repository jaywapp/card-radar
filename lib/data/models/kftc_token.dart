class KftcToken {
  final String accessToken;
  final String userSeqNo;

  const KftcToken({required this.accessToken, required this.userSeqNo});

  factory KftcToken.fromJson(Map<String, dynamic> json) {
    final accessToken = json['access_token'];
    final userSeqNo = json['user_seq_no'];
    if (accessToken is! String ||
        accessToken.trim().isEmpty ||
        userSeqNo is! String ||
        userSeqNo.trim().isEmpty) {
      throw const FormatException('Invalid card access token response');
    }
    return KftcToken(accessToken: accessToken, userSeqNo: userSeqNo);
  }
}
