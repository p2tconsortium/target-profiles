(:~
: This module contains variable declarations for problem diagnoses codes for use in criteria.
: @see problems.xq
: @author Jesse Clark
: @version 0.1
:)
module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";

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