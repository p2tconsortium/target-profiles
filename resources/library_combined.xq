module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
declare namespace c = 'urn:hl7-org:v3';
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq";

(:
    Returns a sequence containing the most recent assessment result as an xs:decimal or the empty sequence if no values 
    were found for the assessment.
:)
declare function p2t:last-assessment-result($root as element(c:ClinicalDocument), $codes as item()*) as xs:decimal* {
  let $ordered := p2t:assessment-observations-ordered($root, $codes)
  return if (empty($ordered)) then () else (xs:decimal(normalize-space($ordered[1]/c:value/@value)))
};

declare function p2t:assessment-values($root as element(c:ClinicalDocument), $codes as item()*) as xs:decimal* {
  for $observation in p2t:assessment-observations-ordered($root, $codes)
  return xs:decimal(normalize-space($observation/c:value/@value))
};

declare function p2t:assessment-observations-ordered($root as element(c:ClinicalDocument), $codes as item()*) as item()* {
  let 
    $observations := p2t:assessment-observations($root, $codes),
    $ordered := for $observation in $observations
        order by $observation/c:effectiveTime/@value descending
        return $observation
  return $ordered
};

declare function p2t:assessment-observations($root as element(c:ClinicalDocument), $codes as item()*) as item()* {
  let $observations := $root/c:component/c:structuredBody/c:component/c:section[c:templateId[@root='2.16.840.1.113883.10.20.22.2.14']][1]/c:entry//
      c:observation[c:code[@code=$codes]]
  return $observations
};

(:
    Note results are returned ordered by effectiveTime descending.
:)
declare function p2t:assessment-observations-within-n-months($root as element(c:ClinicalDocument), $searchCodes as item()*, $months as xs:integer) as item()* {
  for $observation in p2t:assessment-observations($root, $searchCodes)
  let 
      $observationTime := $observation/c:effectiveTime/@value,
      $effectiveTime := p2t:parse-date-time($root/c:effectiveTime/@value),
      $windowTime := $effectiveTime - xs:yearMonthDuration(fn:concat('P', $months, 'M'))
  where exists($observationTime) and p2t:parse-date-time(data($observationTime)) gt $windowTime
  order by $observation/c:effectiveTime/@value descending
  return $observation
};

declare function p2t:assessment-values-within-n-months($root as element(c:ClinicalDocument), $searchCodes as item()*, $months as xs:integer) as item()* {
  for $observation in p2t:assessment-observations-within-n-months($root, $searchCodes, $months)
  return xs:decimal(normalize-space($observation/c:value/@value))
};

declare function p2t:assessment-increasing-within-n-months($root as element(c:ClinicalDocument), $searchCodes as item()*, $months as xs:integer) as xs:boolean {
  let $observations := p2t:assessment-observations-within-n-months($root, $searchCodes, $months)
  return if (exists($observations)) then xs:decimal(normalize-space($observations[1]/c:value/@value)) gt xs:decimal(normalize-space($observations[last()]/c:value/@value)) else false()
};

declare variable $p2t:EDSS as xs:string* := ('273554001'); (: Does not have a LOINC code :)

declare variable $p2t:acyclovir as xs:string* := ('307730', '1250667', '998422', '141859', '197312', '313812', '415660',
    '197310', '199524', '197311', '1423662', '197313');
declare variable $p2t:adalimumab as xs:string* := ('763564','727703','351290');
declare variable $p2t:aldosterone as xs:string* := ('1312358');
declare variable $p2t:alemtuzumab as xs:string* := ('828265', '284679', '828267');
declare variable $p2t:aspirin as xs:string* := ('226718','17315','353447','353452','1242565','866776','1053104','404840','1053122','701317','215256','721973','724441','1303154','1372693','18385','1245474','202546','215431','1361397','215568','1193079','702317','1297834','1302796','1247393','1247398','1312950','215770','227773','92318','202554','1001473','216883','848763','216919','24292','1358848','217020','707765','747233','25027','217127','1363743','763112','763117','217481','545872','1039496','847088','218776','218783','219010','1359078','1052413','848769','1046795','1147493','168020','1241517','219779','219980','220011','796658','1053324','220112','220143','1437476','1438292','220751','1537032','1536501','724444','1358853','210864','213290','1101754','723533','1303159','1361402','1302801','209468','209470','1359083','1052416','1241522','1438297','723530','545875','1188388','1188440','763115','1147496','1247397','1362082','213371','994239','994277','211333','994228','1536937','1536874','1536680','1537012','1536673','209823','209867','848928','1234976','1192980','211292','211297','212989','608696','702320','1304215','1536818','1537203','1536996','1536835','1536507','1250909','797053','1053327','830530','830525','1537024','853501','1293665','387090','211874','1052982','211887','211902','825180','794229','825181','806450','1247402','260847','848166','979118','857531','212086','1189776','1189781','1001476','211878','747236','211310','1363748','211822','211835','1039499','1052678','994530','994537','211881','211891','848772','211832','749795','359221','308278','308281','647869','308287','205251','243694','827318','308297','432638','545871','763116','307677','692836','763111','1147492','900470','685589','994430','1433630','198461','876666','103863','891134','198477','308403','688214','198463','853499','259081','205281','647976','996988','433353','104899','199274','199281','198464','891136','435517','994237','238134','238135','308363','1312713','994226','197447','1111706','243011','1537029','1536840','1536871','1536467','1536675','996989','996991','996994','1536498','1536670','1291868','857525','197930','197945','724614','637540','848768','1049691','312287','849316','849315','646434','198467','198466','1050241','212033','198468','1234872','313806','863184','647984','994528','828585','828594','654251','1192977','243683','198479','863186','243685','994810','308366','198470','435504','235945','198480','1297833','702316','1537019','1536815','806446','1537200','1536993','1536833','1536503','1250907','1092398','106809','857121','308410','435521','308409','246460','1052980','198471','333834','198472','198473','243663','410205','695963','197429','308370','797050','605252','1312718','308411','308412','247137','198475','198474','896884','876667','308414','103954','104475','104474','994535','198476','252380','432389','197374','349516','318272','403924','308416','747211','1537021','392294','1535484','243670','994435','900528','994811','308417','308418','391930','892160');
declare variable $p2t:aubagio as xs:string* := ('1310531', '1310535', '1310526', '1310525', '1310533');
declare variable $p2t:avonex as xs:string* := ('153326', '153324', '727816', '727813', '153323');
declare variable $p2t:betaseron as xs:string* := ('82828', '207059', '198360');
declare variable $p2t:bupoprion as xs:string* := ('993550','993567','993681','993503','993687','993518','993536','1232585','993697','993691','993541','993557');declare variable $p2t:canakinumab as xs:string* := ('853494', '853498', '853495');
declare variable $p2t:campath as xs:string* := ('828265');
declare variable $p2t:certolizumab as xs:string* := ('849597','795081');
declare variable $p2t:cladribine as xs:string* := ('240754', '203767', '205841');
declare variable $p2t:clobetasone as xs:string* := ('438711', '1153359', '331728', '438710', '1153360', '335273', '379485', '358507');
declare variable $p2t:copaxone as xs:string* := ('135779', '1111642', '1487363', '1111641', '1487361');
declare variable $p2t:cyclophosamide as xs:string* := ('1156181', '1156182', '1156183', '1437967', '1437968', '1437969', '197549', '1437968', '1437969', '197550', '315746', '315747', '329664', '371664', '376666', '637543');
declare variable $p2t:deflazacort as xs:string* := ('385598', '332964', '1157200', '371693', '332963', '1157201');
declare variable $p2t:desoxycorticosterone as xs:string* := ('384823', '385036', '371719', '384822', '1294841', '1152180', '329676', '1152181', '385037');
declare variable $p2t:entanercept as xs:string* := ('253014','809158','727757','582671');
declare variable $p2t:extavia as xs:string* := ('860241','860244','198360');
declare variable $p2t:famciclovir as xs:string* := ('199192', '199193', '198382');
declare variable $p2t:fingolimod as xs:string* := ('1012895', '1012896', '1012899');
declare variable $p2t:fludrocortisone as xs:string* := ('328433', '1160242', '1160243', '372213');
declare variable $p2t:golimumab as xs:string* := ('1482813','848160','1431642');
declare variable $p2t:hydromorphone as xs:string* := ('1233859', '1233863', '1012656', '1012667', '1012666', '1012678', '1247421',
      '1014218', '1012679', '1247434', '1010898', '1250433', '1233856', '1242551', '897767', '1010897', '897771',
      '897756', '1433251', '1192498', '897653', '898004', '1013725', '1233700');
declare variable $p2t:ibuprofen as xs:string* := ('900431','153010','1310504','404831','702198','215041','993800','643061','902630','854184','578410','1101916','603609','1100067','702240','217324','217693','1372755','850404','1359092','165786','202488','284787','895656','637194','1429982','219128','1300262','579458','1151095','1191701','900435','220826','643099','1090447','900434','731536','731535','206878','731533','153008','731531','731529','1310509','1297371','1297392','1310489','1299020','1299022','1369777','901818','902633','854187','1049591','1101919','1310491','1100070','702243','206886','206905','206913','206917','859317','858780','850424','1359097','854760','1190622','792242','806013','544393','606990','201126','854762','201142','201152','202098','1310494','895666','637197','1429987','1232135','206876','1300267','859331','858772','858784','1151098','1190626','1191706','900438','858838','644386','643102','1299089','1297390','1310503','1297369','997164','997165','997280','1292323','895664','901814','1100066','859315','858770','858778','858798','392668','141997','389244','1362736','637193','1310487','310963','198405','748641','197803','854183','1369775','1299018','1299021','227159','310964','310965','141993','401976','380813','197804','1049589','197805','314047','204442','141998','226617','142102','197806','250418','197807');
declare variable $p2t:infliximab as xs:string* := ('310994');
declare variable $p2t:IVIg as xs:string* := ('261457', '547199', '1364424', '1364428', '352504', '351326', '541555', '1009212', '541558', '797554', '797557', '42697', '606479', '217247', '545179', '1117548', '1117551', '991216', '991219', '92776', '876409', '471329', '545184', '902750', '902753', '142061', '902749', '547196', '797553', '310494', '310495', '204406', '42750', '205849', '226026', '153530', '219312', '205853', '758996', '758999', '205847');
declare variable $p2t:lipitor as xs:string* := ('617314'); (:Incomplete set of codes here :)
declare variable $p2t:medrysone as xs:string* := ('329969', '372740', '1165099'); (:Incomplete set of codes here :)
declare variable $p2t:methadone as xs:string* := ('991147','1361710','864706','864769','864714','864751','864984','864794','864978','864718','864761','864828');
declare variable $p2t:methotrexate as xs:string* := ('1441407','1441418','105586','1441402','105589','311626','283510','1441411','105585','315148','1441416','1441422','311627','283511','311625','283671','1441403','1441413','1441424','491604','579782','284900','284593','284595','284592','284594');
declare variable $p2t:mitoxantrone as xs:string* := ('197989');
declare variable $p2t:morphine as xs:string* := ('1292838','894911','1234301','1115483','894912','1232113','998212','1303841','998213','1442790','894914','1312991','894915','891883','891878','894918','891885','891890','1241711','1306278','894926','894930','892297','894932','894938','894941','892342','894942','894969','892349','894970','894971','892355','1234294','1234295','1234291','1234292','1234297','1234293','1234298','1234290','1234299','1234300','1234296','1190775','1190785','895867','895927','894976','1247720','892365','892477','894997','892494','895014','892516','892531','895016','863845','892554','891874','895022','1303729','895027','891881','892579','892582','895185','895194','894933','895200','892589','895199','863848','892596','895201','892603','895202','892625','892643','892646','895206','895861','892650','895209','895208','863850','892345','891888','892669','892672','892678','895213','895215','895216','894780','1303736','895217','895869','894807','895220','895219','863852','894801','895221','895227','895229','895871','895237','895238','895233','895240','863854','892352','891893','895247','1303740','895248','895249','863856','894814');
declare variable $p2t:naproxen as xs:string* := ('352399','215101','1494155','849730','202399','603347','218599','203012','1117224','880900','794765','1372705','643130','1116331','1116341','1116351','849578','1112233','849728','1494160','1367428','849400','849438','849752','207093','105898','608793','105914','835560','105899','1117370','1117227','1373034','849452','994007','994010','849737','994005','994008','1494652','245420','311913','1114869','105918','198013','603103','1116320','198012','1116339','311915','198014','199490','1116349','849574','1367426','1112231','849398','849450','849431');
declare variable $p2t:natalizumab as xs:string* := ('477484', '492635', '603541');
declare variable $p2t:ofatumumab as xs:string* := ('876301', '877012', '877010');
declare variable $p2t:prednisone-ge-10mg as xs:string* := ('316583', '316586', '317663', '316582');
declare variable $p2t:rebif as xs:string* := ('228271', '795748', '758032', '758027', '758029', '758025', '758028');
declare variable $p2t:rituximab as xs:string* := ('226754', '213126', '242435');
declare variable $p2t:tecfidera as xs:string* := ('1373484', '1373489', '1373493', '1373483', '1373491');
declare variable $p2t:ustekinumab as xs:string* := ('853351','853354','853356','865174','865172','853350','853355');


declare variable $p2t:a1c as xs:string* := ('4548-4');
declare variable $p2t:HBsAg as xs:string* := ('22322-2');
declare variable $p2t:NT-proBNP as xs:string* := ('71425-3', '33762-6');
declare variable $p2t:LDL as xs:string* := ('2089-1');

declare variable $p2t:acute-coronary-syndrome as xs:string* := ('84757009');
declare variable $p2t:acute-rejection-of-organ-transplant as xs:string* := ('996.8', '431223003', '431222008', '236574008', '432843002', '433592008', '434238001');
declare variable $p2t:ankylosing-spondylitis as xs:string* := ('720.0', '9631008');
declare variable $p2t:aortic-valve-disorder as xs:string* := ('8722008');
declare variable $p2t:mitral-valve-disorder as xs:string* := ('11851006');
declare variable $p2t:ascites as xs:string* := ('789.5', '389026000');
declare variable $p2t:aortic-stenosis as xs:string* := ('60573004');
declare variable $p2t:awating-organ-transplant-diagnosis as xs:string* := ('V49.83');
declare variable $p2t:hemorrhagic-cerebral-infarction as xs:string* := ('230706003');
declare variable $p2t:cardiomyopathy as xs:string* := ('425.4', '85898001');
declare variable $p2t:castlemans-disease as xs:string* := ('785.6', '207036003');
declare variable $p2t:cholangitis as xs:string* := ('576.1', '82403002');
declare variable $p2t:cholestatis as xs:string* := ('576.2', '751.61', '1761006', '95556007');
declare variable $p2t:chrons-disease as xs:string* := ('555.0', '555.1', '555.2', '555.9', '34000006');
declare variable $p2t:chronic-kidney-disease-stage-4 as xs:string* := ('585.4', '431857002');
declare variable $p2t:chronic-kidney-disease-stage-5 as xs:string* := ('585.5', '585.6', '433146000');
declare variable $p2t:chronic-renal-failure as xs:string* := ('14669001');
declare variable $p2t:chronic-inflammatory-demyelinating-polyradiculoneuropathy as xs:string* := ('128209004', '357.81');
declare variable $p2t:congestive-heart-failure-class-b as xs:string* := ('67451000119104');
declare variable $p2t:congestive-heart-failure-class-c as xs:string* := ('67441000119101');
declare variable $p2t:congestive-heart-failure-class-d as xs:string* := ('67431000119105');
declare variable $p2t:congestive-heart-failure as xs:string* := ('84114007');
declare variable $p2t:COPD as xs:string* := ('490', '491', '492', '494', '495', '496', '13645005');
declare variable $p2t:crFMF as xs:string* := ('201796004', '714.3');
declare variable $p2t:cystic-fibrosis as xs:string* := ('190905008', '277.0');
declare variable $p2t:daibetes-mellitus as xs:string* := ('250', '250.0', '14669001');
declare variable $p2t:end-stage-renal-disease as xs:string* := ('46177005');
declare variable $p2t:epilepsy as xs:string* := ('345', '84757009');
declare variable $p2t:encephalopathy as xs:string* := ('572.2', '472916000');
declare variable $p2t:hemolytic-uremic-syndrome as xs:string* := ('283.11', '373422007');
declare variable $p2t:hepatitis-a as xs:string* := ('070.1', '40468003');
declare variable $p2t:hepatitis-b as xs:string* := ('070.2', '070.3', '66071002');
declare variable $p2t:hepatitis-b-no-hepatic-coma as xs:string* := ('179047012', '634614015');
declare variable $p2t:hepatitis-c as xs:string* := ('070.4', '070.5', '070.7', '50711007');
declare variable $p2t:hepatitis-d as xs:string* := ('424460009');
declare variable $p2t:hepatitis-fulminant as xs:string* := ('570', '427044009');
declare variable $p2t:hepatic-vein-thrombosis as xs:string* := ('453.0', '38739001'); 
declare variable $p2t:HIDS as xs:string* := ('403834003', '714.3');
declare variable $p2t:hiv as xs:string* := ('042', '86406008');
declare variable $p2t:inclusion-body-myositis as xs:string* := ('72315009');
declare variable $p2t:infection-p-aeruginosa as xs:string* := ('11218009');
declare variable $p2t:irritable-bowel as xs:string* := ('555', '556', '24526004');
declare variable $p2t:liver-tumors as xs:string* := ('155.0', '155.1', '155.2', '126851005');
declare variable $p2t:lupus-nephritis as xs:string* := ('68815009');
declare variable $p2t:systemic-lupus-erythematosus as xs:string* := ('55464009', '793827011', '92208011', '1231480012');
declare variable $p2t:lyme-disease as xs:string* := ('23502006', '88.81');
declare variable $p2t:macular-edema as xs:string* := ('362.01', '362.53', '37231002');
declare variable $p2t:multiple-sclerosis as xs:string* := ('340', '24700007');
declare variable $p2t:multifocal-motor-neuropathy as xs:string* := ('230591002');
declare variable $p2t:secondary-progressive-multiple-sclerosis as xs:string* := ('340', '425500002');
declare variable $p2t:relapsing-remitting-multiple-sclerosis as xs:string* := ('340', '426373005');
declare variable $p2t:myocarditis as xs:string* := ('391.2', '422', '429', '50920009');
declare variable $p2t:osteosclerotic-myeloma as xs:string* := ('425657001');
declare variable $p2t:POEMS-syndrome as xs:string* := ('79268002', '273.9');
declare variable $p2t:portal-hypertension as xs:string* := ('34742003', '572.3');
declare variable $p2t:psoriatic-arthritis as xs:string* := ('3333901');
declare variable $p2t:plaque-psoriasis as xs:string* := ('696.1', '200965009');
declare variable $p2t:pulmonary-fibrosis as xs:string* := ('686.1', '709.4', '51615001');
declare variable $p2t:rheumatoid-arthritis as xs:string* := ('714.0', '69896004');
declare variable $p2t:systemic-juvenile-idiopathic-arthritis as xs:string* := ('201796004', '714.3');
declare variable $p2t:schizophrenia as xs:string* := ('35252006', '191542003', '64905009', '26025008', '58214004', '295.1', '295.2', '295.3', '295.6', '295.9');
declare variable $p2t:schizophreniform-disorder as xs:string* := ('295.4', '88975006');
declare variable $p2t:schizoaffective as xs:string* := ('295.7', '68890003');
declare variable $p2t:scleroderma as xs:string* := ('710.1', '89155008');
declare variable $p2t:sjogrens as xs:string* := ('710.2', '83901003');
declare variable $p2t:tuberculosis as xs:string* := ('010', '011','012','013','014','015','016','017','018', '56717001');
declare variable $p2t:TRAPS as xs:string* := ('403833009', '277.31');
declare variable $p2t:ulcerative-colitis as xs:string* := ('556', '64766004');
declare variable $p2t:uveitis as xs:string* := ('364.0', '364.3', '444248002');

declare variable $p2t:dialysis as xs:string* := ('90935');
declare variable $p2t:heart-transplant as xs:string* := ('32413006');
declare variable $p2t:awating-organ-transplant-procedure as xs:string* := ('698305006');

(:
    Returns a sequence containing the most recent assessment result as an xs:decimal or the empty sequence if no values 
    were found for the assessment.
:)
declare function p2t:last-assessment-result($root as element(c:ClinicalDocument), $codes as item()*) as xs:decimal* {
  let $ordered := p2t:assessment-observations-ordered($root, $codes)
  return if (empty($ordered)) then () else (xs:decimal(normalize-space($ordered[1]/c:value/@value)))
};

declare function p2t:assessment-values($root as element(c:ClinicalDocument), $codes as item()*) as xs:decimal* {
  for $observation in p2t:assessment-observations-ordered($root, $codes)
  return xs:decimal(normalize-space($observation/c:value/@value))
};

declare function p2t:assessment-observations-ordered($root as element(c:ClinicalDocument), $codes as item()*) as item()* {
  let 
    $observations := p2t:assessment-observations($root, $codes),
    $ordered := for $observation in $observations
        order by $observation/c:effectiveTime/@value descending
        return $observation
  return $ordered
};

declare function p2t:assessment-observations($root as element(c:ClinicalDocument), $codes as item()*) as item()* {
  let $observations := $root/c:component/c:structuredBody/c:component/c:section[c:templateId[@root='2.16.840.1.113883.10.20.22.2.14']][1]/c:entry//
      c:observation[c:code[@code=$codes]]
  return $observations
};

(:
    Note results are returned ordered by effectiveTime descending.
:)
declare function p2t:assessment-observations-within-n-months($root as element(c:ClinicalDocument), $searchCodes as item()*, $months as xs:integer) as item()* {
  for $observation in p2t:assessment-observations($root, $searchCodes)
  let 
      $observationTime := $observation/c:effectiveTime/@value,
      $effectiveTime := p2t:parse-date-time($root/c:effectiveTime/@value),
      $windowTime := $effectiveTime - xs:yearMonthDuration(fn:concat('P', $months, 'M'))
  where exists($observationTime) and p2t:parse-date-time(data($observationTime)) gt $windowTime
  order by $observation/c:effectiveTime/@value descending
  return $observation
};

declare function p2t:assessment-values-within-n-months($root as element(c:ClinicalDocument), $searchCodes as item()*, $months as xs:integer) as item()* {
  for $observation in p2t:assessment-observations-within-n-months($root, $searchCodes, $months)
  return xs:decimal(normalize-space($observation/c:value/@value))
};

declare function p2t:assessment-increasing-within-n-months($root as element(c:ClinicalDocument), $searchCodes as item()*, $months as xs:integer) as xs:boolean {
  let $observations := p2t:assessment-observations-within-n-months($root, $searchCodes, $months)
  return if (exists($observations)) then xs:decimal(normalize-space($observations[1]/c:value/@value)) gt xs:decimal(normalize-space($observations[last()]/c:value/@value)) else false()
};

declare function p2t:lab-observations($root as element(c:ClinicalDocument), $codes as xs:string*) as item()* {
  let 
    $observations := $root/c:component/c:structuredBody/c:component/c:section[c:templateId[@root='2.16.840.1.113883.10.20.22.2.3.1']][1]/
            c:entry/c:organizer[c:templateId[@root='2.16.840.1.113883.10.20.22.4.1']]//c:component/
            c:observation[c:code[@code=$codes] and c:statusCode[@code eq 'completed']]
  return $observations
};

declare function p2t:lab-observations-ordered($root as element(c:ClinicalDocument), $codes as xs:string*) as item()* {
  let 
    $observations := p2t:lab-observations($root, $codes),
    $ordered := for $observation in $observations
        order by $observation/c:effectiveTime/@value descending
        return $observation
  return $ordered
};

declare function p2t:last-lab-result($root as element(c:ClinicalDocument), $codes as xs:string*) as xs:decimal? {
  let 
    $ordered := p2t:lab-observations-ordered($root, $codes)
  return xs:decimal($ordered[1]/c:value/@value)
};


declare function p2t:medication-observations($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()* {
  $root/c:component/c:structuredBody/c:component/c:section[c:code[@code='10160-0']][1]//c:entry/
        c:substanceAdministration[c:consumable/c:manufacturedProduct/c:manufacturedMaterial/c:code[@code = $searchCodes]]
};

declare function p2t:historical-prescription-for($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()* {
  p2t:medication-observations($root, $searchCodes)
};

declare function p2t:medication-codes($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()*  {
  for $observation in p2t:medication-observations($root, $searchCodes) 
  return normalize-space($observation/c:consumable/c:manufacturedProduct/c:manufacturedMaterial/c:code/@code)
};

declare function p2t:medication-observations-within-n-days($root as element(c:ClinicalDocument), $searchCodes as item()*, $days as xs:integer) as item()* {
  for $observation in p2t:medication-observations($root, $searchCodes)
  let
    $effectiveTime := fn:current-dateTime(),
    $windowTime := $effectiveTime - xs:dayTimeDuration(fn:concat('P', $days, 'D')),
    $observationTime := $observation/c:effectiveTime/c:low/@value
  where 
    ( exists($observation/c:effectiveTime/c:high/@value) 
        and p2t:parse-date-time($observation/c:effectiveTime/c:high/@value) gt $windowTime) 
    or ( not( exists($observation/c:effectiveTime/c:high/@value)) 
        and p2t:parse-date-time($observation/c:effectiveTime/c:low/@value) gt $windowTime)
  return $observation
};

declare function p2t:medication-observations-within-n-months($root as element(c:ClinicalDocument), $searchCodes as item()*, $months as xs:integer) as item()* {
  for $observation in p2t:medication-observations($root, $searchCodes)
  let
    $effectiveTime := fn:current-dateTime(),
    $windowTime := $effectiveTime - xs:yearMonthDuration(fn:concat('P', $months, 'M')),
    $observationTime := $observation/c:effectiveTime/c:low/@value
  where 
    ( exists($observation/c:effectiveTime/c:high/@value) 
        and p2t:parse-date-time($observation/c:effectiveTime/c:high/@value) gt $windowTime) 
    or ( not( exists($observation/c:effectiveTime/c:high/@value)) 
        and p2t:parse-date-time($observation/c:effectiveTime/c:low/@value) gt $windowTime)
  return $observation
};

declare function p2t:medications-before-n-months($root as element(c:ClinicalDocument), $searchCodes as item()*, $months as xs:integer) as item()* {
  for $observation in p2t:medication-observations($root, $searchCodes)
  let
    $effectiveTime := fn:current-dateTime(),
    $windowTime := $effectiveTime - xs:yearMonthDuration(fn:concat('P', $months, 'M')),
    $observationTime := $observation/c:effectiveTime/c:low/@value
  where exists($observationTime) and p2t:parse-date-time($observationTime) lt $windowTime
  return $observation
};

declare function p2t:has-n-prescriptions-for($root as element(c:ClinicalDocument), $numOccurrences as xs:integer, $searchCodes as item()*) as xs:boolean {
  let $observations := p2t:medication-observations($root, $searchCodes)
  return count($observations) ge $numOccurrences
};


(:
    Checks for an ACTIVE diagnosis for a problem or condition as defined by a given set of SNOMED and/or ICD-9 codes.
    The $searchCodes parameter is assumed to represent ONLY ONE condition and only the most recent observation for that condition
    is analyzed to determine if the problem/condition is still active.
:)
declare function p2t:has-problem($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()* {
  p2t:active-problem-observation($root, $searchCodes)
};

(:
    Returns the most recent active problem observation for a condition. 
    If the most recent problem observation indicates that the problem is resolved, returns an empty sequence ().
    
    Definition of 'active':
        - A <high> element in effective time indicates a problem that is known to be resolved (pg 448 9.c. ) 
        - The optional Problem Status template can also include a SNOMED code for active/resolved (pg 451, values on pg 310) 
        - The most recent observation for a condition does not have negationInd='true'
        
    TODO: We might want to handle the case in Figure 214. pg450 of the IG which uses @negationInd with the generic SNOMED code for 'Problem' to indicate 'No known problems'. 
:)
declare function p2t:active-problem-observation($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()* {
  let 
    $ordered := for $observation in p2t:problem-observations($root, $searchCodes)
                order by $observation/c:effectiveTime/c:low/@value descending
                return $observation,
    $resolvedByHighTime := (exists($ordered[1]) and $ordered[1]/c:effectiveTime/c:high),
    $resolvedByProblemStatus := (exists($ordered[1]) and $ordered[1]/c:entryRelationship/c:observation[c:code[@code="33999-4"]]/c:value[@code='413322009']),
    $resolvedByNegationInd := (exists($ordered[1]) and $ordered[1][exists(@negationInd) and @negationInd eq 'true'])
  return if ($resolvedByHighTime or $resolvedByProblemStatus or $resolvedByNegationInd) then () else ($ordered[1]) 
};

(: 
    - This method only looks for observations which contain an observation/code with a ProblemType value of 
        Diagnosis 282291009, Problem 55607006, or Condition 64572001. See IG page 448 #6
    - Results exclude any observations which have a @negationInd of true. This means the problem was observed not to be present. 
    - Also searches for Problem Observation templates in EncounterDiagnosis template in the Encounters section.
    - Can match against ICD-9 codes in <translation> elements.
:)
declare function p2t:problem-observations($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()* {
  let 
    $problemsSection := $root/c:component/c:structuredBody/c:component/c:section[c:code[@code eq '11450-4']][1], (: extracting problems section and using index for performance :)
    $problemObservations := $problemsSection//c:entry/c:act/c:entryRelationship/c:observation[
          c:value[@code = $searchCodes] (: SNOMED :) or c:value/c:translation[@codeSystem eq "2.16.840.1.113883.6.2"][@code = $searchCodes] (: ICD-9 :)
        ][ 
          c:code[@code eq '282291009'] or c:code[@code eq '55607006'] or c:code[@code eq '64572001'] (: ProblemTypes: Diagnosis, Problem, Condition :)
        ][
          not(@negationInd) or @negationInd != 'true'
        ],
    $encountersSection := ($root/c:component/c:structuredBody/c:component/c:section[c:code[@code eq '46240-8']])[1],
    $encountersDiagnoses := $encountersSection/c:entry/c:encounter/c:entryRelationship/c:act/c:entryRelationship/c:observation[
          c:value[@code = $searchCodes] (: SNOMED :) or c:value/c:translation[@codeSystem eq "2.16.840.1.113883.6.2"][@code = $searchCodes] (: ICD-9 :)
        ][ 
          c:code[@code eq '282291009'] or c:code[@code eq '55607006'] or c:code[@code eq '64572001'] (: ProblemTypes: Diagnosis, Problem, Condition :)
        ][
          not(@negationInd) or @negationInd != 'true'
        ]
  return ($problemObservations, $encountersDiagnoses)
};

declare function p2t:problem-observations-before-n-months($root as element(c:ClinicalDocument), $searchCodes as item()*, $months as xs:integer) as item()* {
  for $observation in p2t:active-problem-observation($root, $searchCodes)
  let
    $effectiveTime := fn:current-dateTime(),
    $windowTime := $effectiveTime - xs:yearMonthDuration(fn:concat('P', $months, 'M')),
    $observationTime := $observation/c:effectiveTime/c:low/@value
  where exists($observationTime) and p2t:parse-date-time($observationTime) lt $windowTime
  return $observation
};

declare function p2t:problem-observations-within-n-months($root as element(c:ClinicalDocument), $searchCodes as item()*, $months as xs:integer) as item()* {
  for $observation in p2t:active-problem-observation($root, $searchCodes)
  let
    $effectiveTime := fn:current-dateTime(),
    $windowTime := $effectiveTime - xs:yearMonthDuration(fn:concat('P', $months, 'M')),
    $observationTime := $observation/c:effectiveTime/c:low/@value
  where exists($observationTime) and p2t:parse-date-time($observationTime) gt $windowTime
  return $observation
};

(: May be useful for testing... :)
(:declare function p2t:problem-codes($root as element(c:ClinicalDocument))  {
  for $code in $root//c:section/c:code[@code='11450-4']/../c:entry/c:act/c:entryRelationship/c:observation/c:value/@code
    return normalize-space($code)
};:)


declare function p2t:procedure-observations($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()* {
  $root/c:component/c:structuredBody/c:component/c:section[c:code[@code='47519-4']]//c:entry/c:procedure[c:code[@code = $searchCodes]]
};

declare function p2t:has-procedure($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()*  {
  p2t:procedure-observations($root, $searchCodes)
};


declare function p2t:parse-date-time($dt as xs:string) as xs:dateTime {
  let $YYYY := fn:substring($dt, 0, 5),
      $MM := fn:substring($dt, 5, 2),
      $DD := fn:substring($dt, 7, 2),
      $hh := if ( not(fn:substring($dt, 9, 2))) then "00" else fn:substring($dt, 9, 2),
      $mm := if ( not(fn:substring($dt, 11, 2))) then "00" else fn:substring($dt, 11, 2),
      $ss := if ( not(fn:substring($dt, 13, 2))) then "00" else fn:substring($dt, 13, 2)
  return dateTime(xs:date(fn:concat($YYYY, '-', $MM, '-', $DD)),
                          xs:time(fn:concat($hh, ':', $mm, ':', $ss)))
};

(:
  TODO: This could break if birthTime has @nullFlavor='NAV' and no @value. Check for existence first.
  TODO: Seems like most methods should return item()* and use the empty sequence to indicate that the data was not present.
:)
declare function p2t:age-in-years($root as element(c:ClinicalDocument)) as xs:decimal {
  let $duration := fn:current-dateTime() - p2t:parse-date-time($root/c:recordTarget[1]/c:patientRole[1]/c:patient[1]/c:birthTime[1]/@value),
      $days := days-from-duration($duration),
      $years := $days div 365
  return $years
};

declare function p2t:gender-code($root as element(c:ClinicalDocument)) as xs:string {
  $root/c:recordTarget[1]/c:patientRole[1]/c:patient[1]/c:administrativeGenderCode[1]/@code
};

declare function p2t:is-female($root as element(c:ClinicalDocument)) as xs:boolean {
  let $code := p2t:gender-code($root)
  return $code eq 'F'
};

declare function p2t:is-male($root as element(c:ClinicalDocument)) as xs:boolean {
  let $code := p2t:gender-code($root)
  return $code eq 'M'
};

(: 
  NOTE: $estimatedDeliveryTime is an optional value in the CCDA. Erring on the side of creating false positives by only returning true 
    if the delivery time is present and in the future
  TODO: At least one of the EMERGE CCDAs did not include a Pregnancy Observation template and instead listed a Problem Observation with 
    the SNOMED code for Pregnant state, incidental.
:) 
declare function p2t:is-pregnant($root as element(c:ClinicalDocument)) as xs:boolean {
  let $pregnancyObservations := 
    for $observation in $root/c:component/c:structuredBody/c:component/c:section[c:code[@code='29762-2']][1]//
            c:entry/c:observation[c:templateId[@root='2.16.840.1.113883.10.20.15.3.8']]
      let $estimatedDeliveryTime := p2t:parse-date-time(
            $observation/c:entryRelationship/c:observation[c:templateId[@root='2.16.840.1.113883.10.20.15.3.1']]/c:value/@value),
          $currentTime := current-dateTime()
      where exists($estimatedDeliveryTime) and $estimatedDeliveryTime ge $currentTime
      return true()
   return exists($pregnancyObservations)
};

declare function p2t:last-vital-sign($code as xs:string, $root as element(c:ClinicalDocument)) as xs:decimal? {
  let $ordered := for $observation in $root/c:component/c:structuredBody/c:component/c:section[c:code[@code='8716-3']][1]//
        c:entry/c:organizer/c:component/c:observation[c:code[@code=$code]]
    order by $observation/c:effectiveTime/@value descending
    return xs:decimal($observation/c:value/@value)
  return $ordered[1]
};

declare function p2t:last-weight-measured($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-vital-sign('3141-9', $root)
};

declare function p2t:last-systolic($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-vital-sign('8480-6', $root)
};

declare function p2t:last-diastolic($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-vital-sign('8462-4', $root)
};

declare function p2t:blood-pressure-lower-than($root as element(c:ClinicalDocument), $maxSystolic as xs:decimal, $maxDiastolic as xs:decimal) as xs:boolean? {
  let $lastSystolic := p2t:last-systolic($root),
    $lastDiastolic := p2t:last-diastolic($root)
  return if (empty($lastSystolic) or empty($lastDiastolic)) then () else $lastSystolic le $maxSystolic and $lastDiastolic le $maxDiastolic
};

declare function p2t:bmi-observations($root as element(c:ClinicalDocument)) as item()* {
  $root/c:component/c:structuredBody/c:component/c:section[c:templateId[@root='2.16.840.1.113883.10.20.22.2.4.1']][1]//
      c:entry/c:organizer/c:component/c:observation[c:code[@code='39156-5']]
};

declare function p2t:avg-bmi($root as element(c:ClinicalDocument)) as xs:decimal {
  fn:avg(
    for $observation in p2t:bmi-observations($root)
    return xs:decimal($observation/c:value/@value))
};

declare function p2t:last-bmi($root as element(c:ClinicalDocument)) as xs:decimal? {
  let $ordered :=
    for $observation in p2t:bmi-observations($root)
      order by $observation/c:effectiveTime/@value descending
      return $observation/c:value/@value
  return xs:decimal($ordered[1])
};

declare function p2t:bmi-in-range($root as element(c:ClinicalDocument), $bmiMin as xs:decimal, $bmiMax as xs:decimal) as xs:boolean {
  let $bmi := p2t:last-bmi($root)
  return if (empty($bmi)) then true() else $bmi ge $bmiMin and $bmi le $bmiMax
};
