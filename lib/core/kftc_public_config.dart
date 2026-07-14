const String kftcClientId = String.fromEnvironment('KFTC_CLIENT_ID');
const String kftcRedirectUri =
    'https://kmgoanbulmxmeuzmxmnv.supabase.co/functions/v1/kftc-callback';
const String kftcBaseUrl = 'https://testapi.openbanking.or.kr';

bool get kftcConfigured => kftcClientId.isNotEmpty;
