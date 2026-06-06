-- 1. 공개 읽기 권한 설정 (로그인 없는 퍼블릭 앱)
grant select on cards to anon;
grant select on card_benefits to anon;

-- 2. 카드 데이터 삽입
insert into cards (id, name, issuer, apply_url) values
  ('shinhan-deep-dream', '신한 Deep Dream', '신한카드', 'https://www.shinhancard.com/pconts/html/card/apply/credit/1196838_2203.html'),
  ('shinhan-sline', '신한 S-Line', '신한카드', 'https://www.shinhancard.com'),
  ('shinhan-mrlife', '신한 Mr.Life', '신한카드', 'https://www.shinhancard.com'),
  ('hyundai-zero', '현대카드 ZERO', '현대카드', 'https://www.hyundaicard.com/cpc/si/CPCSIE0010_01.hc'),
  ('hyundai-m', '현대카드 M', '현대카드', 'https://www.hyundaicard.com'),
  ('hyundai-shopping', '현대카드 SHOPPING', '현대카드', 'https://www.hyundaicard.com'),
  ('kb-flex', 'KB 플렉스카드', 'KB국민카드', 'https://card.kbcard.com/CRD/DISI/LPCDISIHMPG0076.cms'),
  ('kb-tantan', 'KB 탄탄대로카드', 'KB국민카드', 'https://card.kbcard.com'),
  ('kb-nori', 'KB 노리 1.5', 'KB국민카드', 'https://card.kbcard.com'),
  ('samsung-taptap', '삼성 taptap', '삼성카드', 'https://www.samsungcard.com/home/card/cardinfo/PGBPCARDCardInfo0201V.do?CSTSQNO=1002020'),
  ('samsung-id-simple', '삼성 iD SIMPLE', '삼성카드', 'https://www.samsungcard.com'),
  ('samsung-7', '삼성카드 7', '삼성카드', 'https://www.samsungcard.com'),
  ('lotte-dc-plus', '롯데 DC PLUS', '롯데카드', 'https://www.lottecard.co.kr/app/LPCDCBCA_V100.lc'),
  ('lotte-likit', '롯데 LIKIT', '롯데카드', 'https://www.lottecard.co.kr'),
  ('woori-da', '우리 다통장카드', '우리카드', 'https://pc.wooricard.com/dcpc/yh1/crd/crdIssueMgmt/H1CRD101M1/selectCrdIssuDtl.do'),
  ('woori-da-big', '우리 Da Big카드', '우리카드', 'https://pc.wooricard.com'),
  ('hana-1q', '하나 1Q카드', '하나카드', 'https://www.hanacard.co.kr/OPI30000000N.web'),
  ('hana-moa', '하나 모아', '하나카드', 'https://www.hanacard.co.kr'),
  ('nh-all', 'NH올원카드 올바른FLEX', 'NH농협카드', 'https://card.nonghyup.com'),
  -- 신규 카드
  ('shinhan-deep-oil', '신한 Deep Oil', '신한카드', 'https://www.shinhancard.com'),
  ('hyundai-z', '현대카드 Z', '현대카드', 'https://www.hyundaicard.com'),
  ('hyundai-x', '현대카드 X', '현대카드', 'https://www.hyundaicard.com'),
  ('kb-my-wesh', 'KB MY WE:SH', 'KB국민카드', 'https://card.kbcard.com'),
  ('kb-altteu', 'KB 알뜰교통카드', 'KB국민카드', 'https://card.kbcard.com'),
  ('samsung-id-on', '삼성 iD ON', '삼성카드', 'https://www.samsungcard.com'),
  ('samsung-4', '삼성카드 4', '삼성카드', 'https://www.samsungcard.com'),
  ('lotte-loca365', '롯데 LOCA 365', '롯데카드', 'https://www.lottecard.co.kr'),
  ('woori-point', '우리카드 카드의정석 POINT', '우리카드', 'https://pc.wooricard.com'),
  ('woori-money', '우리카드 카드의정석 MONEY', '우리카드', 'https://pc.wooricard.com'),
  ('hana-viva-x', '하나 VIVA X', '하나카드', 'https://www.hanacard.co.kr'),
  ('hana-viva-w', '하나 VIVA W', '하나카드', 'https://www.hanacard.co.kr'),
  ('nh-chaeeum', 'NH채움카드', 'NH농협카드', 'https://card.nonghyup.com'),
  ('bc-baro-ez', 'BC 바로이지카드', 'BC카드', 'https://www.bccard.com'),
  ('kakao-check', '카카오뱅크 체크카드', '카카오뱅크', 'https://www.kakaobank.com'),
  ('toss-check', '토스뱅크 체크카드', '토스뱅크', 'https://www.tossbank.com')
on conflict (id) do nothing;

-- 3. 혜택 데이터 삽입
insert into card_benefits (card_id, category, benefit_type, rate, conditions) values
  -- 신한 Deep Dream
  ('shinhan-deep-dream', 'convenience', 'cashback', 5.0, null),
  ('shinhan-deep-dream', 'cafe', 'cashback', 3.0, null),
  ('shinhan-deep-dream', 'online', 'cashback', 2.0, '월 3만원 한도'),
  -- 신한 S-Line
  ('shinhan-sline', 'transit', 'cashback', 5.0, null),
  ('shinhan-sline', 'gasStation', 'cashback', 3.0, null),
  ('shinhan-sline', 'pharmacy', 'cashback', 2.0, null),
  -- 신한 Mr.Life
  ('shinhan-mrlife', 'mart', 'cashback', 5.0, null),
  ('shinhan-mrlife', 'pharmacy', 'cashback', 3.0, null),
  ('shinhan-mrlife', 'cafe', 'cashback', 2.0, null),
  -- 현대카드 ZERO
  ('hyundai-zero', 'gasStation', 'cashback', 5.0, null),
  ('hyundai-zero', 'transit', 'cashback', 3.0, null),
  ('hyundai-zero', 'mart', 'cashback', 2.0, null),
  -- 현대카드 M
  ('hyundai-m', 'restaurant', 'points', 5.0, null),
  ('hyundai-m', 'cafe', 'points', 3.0, null),
  ('hyundai-m', 'mart', 'points', 2.0, null),
  -- 현대카드 SHOPPING
  ('hyundai-shopping', 'online', 'cashback', 7.0, '월 30만원 이상'),
  ('hyundai-shopping', 'mart', 'cashback', 3.0, null),
  ('hyundai-shopping', 'convenience', 'cashback', 2.0, null),
  -- KB 플렉스
  ('kb-flex', 'restaurant', 'points', 5.0, null),
  ('kb-flex', 'online', 'points', 3.0, null),
  ('kb-flex', 'cafe', 'points', 2.0, null),
  -- KB 탄탄대로
  ('kb-tantan', 'gasStation', 'cashback', 5.0, null),
  ('kb-tantan', 'convenience', 'cashback', 3.0, null),
  ('kb-tantan', 'transit', 'cashback', 2.0, null),
  -- KB 노리
  ('kb-nori', 'restaurant', 'cashback', 3.0, null),
  ('kb-nori', 'cafe', 'cashback', 3.0, null),
  ('kb-nori', 'convenience', 'cashback', 3.0, null),
  -- 삼성 taptap
  ('samsung-taptap', 'online', 'cashback', 5.0, null),
  ('samsung-taptap', 'mart', 'cashback', 3.0, null),
  ('samsung-taptap', 'convenience', 'cashback', 2.0, null),
  -- 삼성 iD SIMPLE
  ('samsung-id-simple', 'convenience', 'cashback', 3.0, null),
  ('samsung-id-simple', 'transit', 'cashback', 3.0, null),
  ('samsung-id-simple', 'gasStation', 'cashback', 3.0, null),
  -- 삼성카드 7
  ('samsung-7', 'mart', 'cashback', 5.0, null),
  ('samsung-7', 'restaurant', 'cashback', 3.0, null),
  ('samsung-7', 'pharmacy', 'cashback', 2.0, null),
  -- 롯데 DC PLUS
  ('lotte-dc-plus', 'restaurant', 'cashback', 4.0, null),
  ('lotte-dc-plus', 'mart', 'cashback', 4.0, null),
  ('lotte-dc-plus', 'cafe', 'cashback', 2.0, null),
  -- 롯데 LIKIT
  ('lotte-likit', 'online', 'points', 4.0, null),
  ('lotte-likit', 'convenience', 'points', 3.0, null),
  ('lotte-likit', 'restaurant', 'points', 2.0, null),
  -- 우리 다통장
  ('woori-da', 'transit', 'cashback', 5.0, null),
  ('woori-da', 'gasStation', 'cashback', 3.0, null),
  ('woori-da', 'pharmacy', 'cashback', 2.0, null),
  -- 우리 Da Big
  ('woori-da-big', 'mart', 'cashback', 5.0, null),
  ('woori-da-big', 'restaurant', 'cashback', 3.0, null),
  ('woori-da-big', 'online', 'cashback', 2.0, null),
  -- 하나 1Q
  ('hana-1q', 'online', 'points', 5.0, null),
  ('hana-1q', 'mart', 'points', 3.0, null),
  ('hana-1q', 'convenience', 'points', 2.0, null),
  -- 하나 모아
  ('hana-moa', 'restaurant', 'cashback', 4.0, null),
  ('hana-moa', 'cafe', 'cashback', 4.0, null),
  ('hana-moa', 'transit', 'cashback', 2.0, null),
  -- NH 올원 FLEX
  ('nh-all', 'convenience', 'cashback', 5.0, null),
  ('nh-all', 'cafe', 'cashback', 3.0, null),
  ('nh-all', 'transit', 'cashback', 2.0, null),
  -- 신한 Deep Oil
  ('shinhan-deep-oil', 'gasStation', 'cashback', 7.0, null),
  ('shinhan-deep-oil', 'convenience', 'cashback', 2.0, null),
  ('shinhan-deep-oil', 'transit', 'cashback', 2.0, null),
  -- 현대카드 Z
  ('hyundai-z', 'gasStation', 'cashback', 7.0, null),
  ('hyundai-z', 'transit', 'cashback', 5.0, null),
  ('hyundai-z', 'online', 'cashback', 3.0, null),
  -- 현대카드 X
  ('hyundai-x', 'online', 'cashback', 5.0, null),
  ('hyundai-x', 'restaurant', 'cashback', 3.0, null),
  ('hyundai-x', 'convenience', 'cashback', 2.0, null),
  -- KB MY WE:SH
  ('kb-my-wesh', 'convenience', 'cashback', 5.0, null),
  ('kb-my-wesh', 'cafe', 'cashback', 3.0, null),
  ('kb-my-wesh', 'transit', 'cashback', 3.0, null),
  -- KB 알뜰교통카드
  ('kb-altteu', 'transit', 'cashback', 10.0, null),
  ('kb-altteu', 'gasStation', 'cashback', 3.0, null),
  ('kb-altteu', 'convenience', 'cashback', 2.0, null),
  -- 삼성 iD ON
  ('samsung-id-on', 'online', 'cashback', 5.0, null),
  ('samsung-id-on', 'convenience', 'cashback', 3.0, null),
  ('samsung-id-on', 'cafe', 'cashback', 2.0, null),
  -- 삼성카드 4
  ('samsung-4', 'mart', 'cashback', 4.0, null),
  ('samsung-4', 'gasStation', 'cashback', 4.0, null),
  ('samsung-4', 'pharmacy', 'cashback', 3.0, null),
  -- 롯데 LOCA 365
  ('lotte-loca365', 'restaurant', 'cashback', 3.0, null),
  ('lotte-loca365', 'cafe', 'cashback', 3.0, null),
  ('lotte-loca365', 'convenience', 'cashback', 3.0, null),
  -- 카드의정석 POINT
  ('woori-point', 'online', 'points', 5.0, null),
  ('woori-point', 'restaurant', 'points', 3.0, null),
  ('woori-point', 'cafe', 'points', 2.0, null),
  -- 카드의정석 MONEY
  ('woori-money', 'convenience', 'cashback', 5.0, null),
  ('woori-money', 'cafe', 'cashback', 3.0, null),
  ('woori-money', 'transit', 'cashback', 2.0, null),
  -- 하나 VIVA X
  ('hana-viva-x', 'gasStation', 'cashback', 5.0, null),
  ('hana-viva-x', 'convenience', 'cashback', 3.0, null),
  ('hana-viva-x', 'restaurant', 'cashback', 2.0, null),
  -- 하나 VIVA W
  ('hana-viva-w', 'mart', 'cashback', 5.0, null),
  ('hana-viva-w', 'online', 'cashback', 3.0, null),
  ('hana-viva-w', 'cafe', 'cashback', 2.0, null),
  -- NH채움카드
  ('nh-chaeeum', 'mart', 'cashback', 4.0, null),
  ('nh-chaeeum', 'restaurant', 'cashback', 3.0, null),
  ('nh-chaeeum', 'pharmacy', 'cashback', 2.0, null),
  -- BC 바로이지카드
  ('bc-baro-ez', 'gasStation', 'cashback', 4.0, null),
  ('bc-baro-ez', 'transit', 'cashback', 4.0, null),
  ('bc-baro-ez', 'mart', 'cashback', 2.0, null),
  -- 카카오뱅크 체크카드
  ('kakao-check', 'online', 'cashback', 3.0, null),
  ('kakao-check', 'cafe', 'cashback', 2.0, null),
  ('kakao-check', 'convenience', 'cashback', 2.0, null),
  -- 토스뱅크 체크카드
  ('toss-check', 'restaurant', 'cashback', 2.0, null),
  ('toss-check', 'online', 'cashback', 2.0, null),
  ('toss-check', 'convenience', 'cashback', 2.0, null)
on conflict do nothing;
