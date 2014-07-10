module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";

declare namespace c = 'urn:hl7-org:v3';
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/functx.xq";

declare function p2t:parse-date-time($dt as xs:string) as xs:dateTime {
  let $YYYY := fn:substring($dt, 0, 5),
      $MM := fn:substring($dt, 5, 2),
      $DD := fn:substring($dt, 7, 2),
      $hh := fn:substring($dt, 9, 2),
      $mm := fn:substring($dt, 11, 2),
      $ss := fn:substring($dt, 13, 2)
  return dateTime(xs:date(fn:concat($YYYY, '-', $MM, '-', $DD)),
                          xs:time(fn:concat($hh, ':', $mm, ':', $ss)))
};

declare function p2t:age-in-years($birth as xs:string) as xs:decimal {
  let $duration := fn:current-dateTime() - p2t:parse-date-time($birth),
      $days := days-from-duration($duration),
      $years := $days div 365
  return $years
};

declare function p2t:is-female($patient as element(c:patient)) as xs:boolean {
  let $code := xs:string($patient/c:administrativeGender-code/@code)
    return $code eq 'F'
};

declare function p2t:is-male($patient as element(c:patient)) as xs:boolean {
  let $code := xs:string($patient/c:administrativeGender-code/@code)
    return $code eq 'M'
};

(: 
  $estimatedDeliveryTime is an optional value in the CCDA. Erring on the side of creating false positives by only returning true 
  if the delivery time is present and in the future
:) 
declare function p2t:is-pregnant($root as element(c:ClinicalDocument)) as xs:boolean {
  let $pregnancyObservations := 
    for $observation in $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.17']/../c:entry/c:observation/c:templateId[@root='2.16.840.1.113883.10.20.15.3.8']/..
      let $estimatedDeliveryTime := p2t:parse-date-time($observation/c:entryRelationship/c:observation/c:templateId[@root='2.16.840.1.113883.10.20.15.3.1']/../c:value),
          $currentTime := current-dateTime()
      where not(empty($estimatedDeliveryTime)) and $estimatedDeliveryTime ge $currentTime
      return true()
   return not(empty($pregnancyObservations))
};

declare function p2t:last-vital-sign($code as xs:string, $root as element(c:ClinicalDocument)) as xs:decimal? {
  let $ordered :=
    for $observation in $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.4.1']/../c:entry/c:organizer/c:component/c:observation
      where $observation/c:code[@code=$code]
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

declare function p2t:blood-pressure-lower-than($root as element(c:ClinicalDocument), $max-systolic as xs:decimal, $max-diastolic as xs:decimal) as xs:boolean? {
  let $last-systolic := p2t:last-systolic($root),
    $last-diastolic := p2t:last-diastolic($root)
  return if (empty($last-systolic) or empty($last-diastolic)) then () else $last-systolic le $max-systolic and $last-diastolic le $max-diastolic
};

declare function p2t:avg-bmi($root as element(c:ClinicalDocument)) as xs:decimal {
  fn:avg(for $observation in
    $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.4.1']/../c:entry/c:organizer/c:component/c:observation/c:code[@code='39156-5']/..
    return xs:decimal($observation/c:value/@value))
};

declare function p2t:last-bmi($root as element(c:ClinicalDocument)) as xs:decimal? {
  let $ordered :=
    for $observation in $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.4.1']/../c:entry/c:organizer/c:component/c:observation
      where $observation/c:code[@code='39156-5']
      order by $observation/c:effectiveTime/@value descending
      return xs:decimal($observation/c:value/@value)
  return $ordered[1]
};

declare function p2t:bmi-in-range($root as element(c:ClinicalDocument),
                                    $bmi-min as xs:decimal, $bmi-max as xs:decimal) as xs:boolean {
  let $bmi := p2t:last-bmi($root)
  return if (empty($bmi)) then true() else $bmi ge $bmi-min and $bmi le $bmi-max
};

declare function p2t:last-a1c($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-lab-result('4548-4', $root)
};

declare function p2t:a1c-in-range($root as element(c:ClinicalDocument),
                                    $a1c-min as xs:decimal, $a1c-max as xs:decimal) as xs:boolean {
  let $a1c := p2t:last-a1c($root)
    return if (empty($a1c)) then true() else $a1c ge $a1c-min and $a1c le $a1c-max
};

declare function p2t:last-lab-result($code as xs:string, $root as element(c:ClinicalDocument)) as xs:decimal? {
  let $ordered :=
    for $observation in $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.3.1']/..//c:observation
    where $observation/c:code[@code=$code]
    order by $observation/c:effectiveTime/@value descending
    return xs:decimal($observation/c:value/@value)
  return $ordered[1]
};

declare function p2t:last-HBsAg($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-lab-result('22322-2', $root)
};

(: There are (at least) 2 codes that could represent this lab test :)
declare function p2t:last-NT-proBNP($root as element(c:ClinicalDocument)) as xs:decimal? {
  let 
    $code1 := p2t:last-lab-result('71425-3', $root),
    $code2 := p2t:last-lab-result('33762-6', $root)
  return
    if (not(empty($code1))) then $code1 else (if (not(empty($code2))) then $code2 else ())
};

declare function p2t:last-LDL($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-lab-result('2089-1', $root)
};

(: TODO: Modify condition detection methods to follow the same pattern as medications: define globals and call p2t:has-condition($root, [GLOBAL]) from TPs :)
(: TODO: Add support for ICD-9/10 codes :)
declare function p2t:problem-codes($root as element(c:ClinicalDocument))  {
  for $code in $root//c:section/c:code[@code='11450-4']/../c:entry/c:act/c:entryRelationship/c:observation/c:value/@code
    return normalize-space($code)
};

declare function p2t:problems-within-months($root as element(c:ClinicalDocument),
                                             $months as xs:integer) {
  let $effectiveTime := p2t:parse-date-time($root/c:effectiveTime/@value),
      $windowTime := $effectiveTime - xs:yearMonthDuration(fn:concat('P', $months, 'M')),
      $observations := $root//c:section/c:code[@code='11450-4']/../c:entry/c:act/c:entryRelationship/c:observation/c:code[@code='282291009']/..
  for $observation in $observations
    let $observationTime := $observation/c:effectiveTime/c:low/@value
    where not(empty($observationTime)) and p2t:parse-date-time($observationTime) gt $windowTime
    return normalize-space($observation/c:value/@code)
};

declare function p2t:problems-before-months($root as element(c:ClinicalDocument),
                                             $months as xs:integer) {
  let $effectiveTime := fn:current-dateTime(),
      $windowTime := $effectiveTime - xs:yearMonthDuration(fn:concat('P', $months, 'M')),
      $observations := $root//c:section/c:code[@code='11450-4']/../c:entry/c:act/c:entryRelationship/c:observation/c:code[@code='282291009']/..
  for $observation in $observations
    let $observationTime := $observation/c:effectiveTime/c:low/@value
    where not(empty($observationTime)) and p2t:parse-date-time($observationTime) lt $windowTime
    return normalize-space($observation/c:value/@code)
};

declare function p2t:hemorrhagic-cerebral-infarction($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '230706003'))
};

declare function p2t:is-type2($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '44054006'))
};

declare function p2t:is-renal-disease($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '46177005'))
};

declare function p2t:acute-renal-failure($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '14669001'))
};

declare function p2t:chronic-renal-failure($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '14669001'))
};

declare function p2t:end-stage-renal-disease($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '46177005'))
};

declare function p2t:has-hep-b-no-hepatic-coma($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '179047012')) or exists(index-of($codes, '634614015'))
};

declare function p2t:has-hep-b($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root),
    $med-codes := ('070.2', '070.3', '66071002')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:has-hep-c($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root),
    $med-codes := ('070.4', '070.5', '070.7', '50711007')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:has-hep-d($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '424460009'))
};

declare function p2t:has-epilepsy($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root),
    $med-codes := ('345', '84757009')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:has-hiv($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root),
    $med-codes := ('042', '86406008')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:has-congestive-heart-failure-class-b($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '67451000119104'))
};

declare function p2t:has-congestive-heart-failure-class-c($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '67441000119101'))
};

declare function p2t:has-congestive-heart-failure-class-d($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '67431000119105'))
};

declare function p2t:has-heart-failure($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '84114007'))
};

declare function p2t:has-acute-coronary-syndrome($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '394659003'))
};

declare function p2t:has-multiple-sclerosis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
(:  There are other synonyms for this in snomed :)
  return exists(index-of($codes, '24700007'))
};

declare function p2t:has-tuberculosis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root),
    $med-codes := ('010', '011','012','013','014','015','016','017','018', '86406008')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:has-rheumatoid-arthritis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root),
    $med-codes := ('714.0', '69896004')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:has-lupus-nephritis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '68815009'))
};

declare function p2t:has-systemic-lupus-erythematosus($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
(:  Checking for primary code and 3 synonyms :)
  return exists(index-of($codes, '55464009')) or exists(index-of($codes, '793827011')) 
  or exists(index-of($codes, '92208011')) or exists(index-of($codes, '1231480012'))
};

declare function p2t:has-psoriatic-arthritis-at-least-six-months($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problems-before-months($root, 6)
  return exists(index-of($codes, '3333901'))
};

declare function p2t:has-plaque-psoriasis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root),
    $med-codes := ('696.1', '200965009')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:has-plaque-psoriasis-at-least-six-months($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problems-before-months($root, 6),
    $med-codes := ('696.1', '200965009')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:novartis-has-other-psoriasis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root),
    $med-codes := ('696.0', '200973000', '27520001', '200977004', '37042000')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:has-inclusion-body-myositis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '72315009'))
};

declare function p2t:has-mitral-valve-disorder($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '11851006'))
};

declare function p2t:has-aortic-valve-disorder($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '8722008'))
};

declare function p2t:has-aortic-stenosis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '60573004'))
};

declare function p2t:has-systemic-juvenile-idiopathic-arthritis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '201796004')) or exists(index-of($codes, '714.3')) (:Including ICD-9 code:)
};

declare function p2t:has-TRAPS($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '403833009')) or exists(index-of($codes, '277.31')) (:Including ICD-9 code:)
};

declare function p2t:has-HIDS($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '403834003')) or exists(index-of($codes, '714.3')) (:Including ICD-9 code:)
};

declare function p2t:has-crFMF($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '201796004')) or exists(index-of($codes, '714.3')) (:Including ICD-9 code:)
};

declare function p2t:acute-myocardial-infarction-past-6-months($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problems-within-months($root, 6)
  return exists(index-of($codes, '57054005'))
};

declare function p2t:acute-q-wave-myocardial-infarction-past-6-months($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problems-within-months($root, 6)
  return exists(index-of($codes, '304914007'))
};

declare function p2t:malignant-prostate-tumor-past-60-months($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problems-within-months($root, 60)
  return exists(index-of($codes, '399068003'))
};

declare function p2t:tumor-stage-t1c-past-60-months($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problems-within-months($root, 60)
  return exists(index-of($codes, '261650005'))
};

declare function p2t:secondary-malignant-neoplasm-of-bone-past-60-months($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problems-within-months($root, 60)
  return exists(index-of($codes, '94222008'))
};

declare function p2t:neoplasm-of-colon-past-60-months($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problems-within-months($root, 60)
  return exists(index-of($codes, '126838000'))
};

declare function p2t:malignant-neoplasm-of-female-breast-past-60-months($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problems-within-months($root, 60)
  return exists(index-of($codes, '188161004'))
};

declare function p2t:hormone-receptor-positive-tumor-past-60-months($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problems-within-months($root, 60)
  return exists(index-of($codes, '417742002'))
};

declare function p2t:tumor-stage-t2c-past-60-months($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problems-within-months($root, 60)
  return exists(index-of($codes, '261653007'))
};

declare function p2t:has-schizophrenia-at-least-1-year($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problems-before-months($root, 12),
    $med-codes := ('35252006', '191542003', '64905009', '26025008', '58214004', '295.1', '295.2', '295.3', '295.6', '295.9')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:has-schizophreniform-disorder($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root),
    $med-codes := ('295.4', '88975006')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:has-schizoaffective($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root),
    $med-codes := ('295.7', '68890003')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:has-ankylosing-spondylitis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root),
    $med-codes := ('720.0', '9631008')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:has-uveitis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root),
    $med-codes := ('364.0', '364.3', '444248002')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:has-irritable-bowel($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:problem-codes($root),
    $med-codes := ('555', '556', '24526004')
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:recent-diagnosis($root as element(c:ClinicalDocument), $condition as xs:string,
                                        $code as xs:string, $months as xs:integer, $exclude as xs:boolean) {
  let $effectiveTime := p2t:parse-date-time($root/c:effectiveTime/@value), 
      $windowTime := $effectiveTime - xs:yearMonthDuration(fn:concat('P', $months, 'M')),
      $diagnosis := for $observation in $root//c:section/c:code[@code='11450-4']/../c:entry/c:act/c:entryRelationship/c:observation/c:code[@code='282291009']/.. 
  where not(empty($observation/c:effectiveTime/c:low/@value))
    and $observation/c:value[@code=$code]
    return if(p2t:parse-date-time($observation/c:effectiveTime/c:low/@value) gt $windowTime) then
             if($exclude) then
               concat("Patient not eligible due to diagnosis of ", $observation/c:value/@displayName, 
                      " on ", p2t:parse-date-time($observation/c:effectiveTime/c:low/@value),
                      " within last ", $months, " months.")
             else concat("Patient is eligible with diagnosis of ", $observation/c:value/@displayName, " on ",
                  p2t:parse-date-time($observation/c:effectiveTime/c:low/@value), ".")
           else ()
  return if(exists($diagnosis) and not(empty($diagnosis))) 
    then not($exclude)
    else xs:boolean('true')
}; 

declare function p2t:medications($root as element(c:ClinicalDocument))  {
  for $code in $root//c:section/c:code[@code='10160-0']/../c:entry/c:substanceAdministration/c:consumable/c:manufacturedProduct/c:manufacturedMaterial/c:code/@code
  return normalize-space($code)
};

(: TODO: refactor TPs to use taking-medications instead. :)
declare function p2t:taking-medication($root as element(c:ClinicalDocument), $med-code as xs:string) as xs:boolean {
  let $codes := p2t:medications($root)
  return exists(index-of($codes, $med-code))
};

declare function p2t:taking-medications($root as element(c:ClinicalDocument), $med-codes as item()*) as xs:boolean {
  let $codes := p2t:medications($root)
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:has-n-prescriptions-for($root as element(c:ClinicalDocument), $num-occurrences as xs:integer, $med-codes as item()*) as xs:boolean* {
  let $ccda-med-codes := p2t:medications($root)
  for $ccda-code in $ccda-med-codes,
    $code in $med-codes[. eq $ccda-code]
  where count($ccda-med-codes[. eq $code]) ge $num-occurrences
  return true()
};
(: 
  TODO: Refactor all taking-foo methods pulling the RxNorm codes out into global variables and call p2t:taking-medications($root, [GLOBAL])
        from target profile definitions.
:)
declare variable $p2t:aspirin as xs:string* := ('226718','17315','353447','353452','1242565','866776','1053104','404840','1053122','701317','215256','721973','724441','1303154','1372693','18385','1245474','202546','215431','1361397','215568','1193079','702317','1297834','1302796','1247393','1247398','1312950','215770','227773','92318','202554','1001473','216883','848763','216919','24292','1358848','217020','707765','747233','25027','217127','1363743','763112','763117','217481','545872','1039496','847088','218776','218783','219010','1359078','1052413','848769','1046795','1147493','168020','1241517','219779','219980','220011','796658','1053324','220112','220143','1437476','1438292','220751','1537032','1536501','724444','1358853','210864','213290','1101754','723533','1303159','1361402','1302801','209468','209470','1359083','1052416','1241522','1438297','723530','545875','1188388','1188440','763115','1147496','1247397','1362082','213371','994239','994277','211333','994228','1536937','1536874','1536680','1537012','1536673','209823','209867','848928','1234976','1192980','211292','211297','212989','608696','702320','1304215','1536818','1537203','1536996','1536835','1536507','1250909','797053','1053327','830530','830525','1537024','853501','1293665','387090','211874','1052982','211887','211902','825180','794229','825181','806450','1247402','260847','848166','979118','857531','212086','1189776','1189781','1001476','211878','747236','211310','1363748','211822','211835','1039499','1052678','994530','994537','211881','211891','848772','211832','749795','359221','308278','308281','647869','308287','205251','243694','827318','308297','432638','545871','763116','307677','692836','763111','1147492','900470','685589','994430','1433630','198461','876666','103863','891134','198477','308403','688214','198463','853499','259081','205281','647976','996988','433353','104899','199274','199281','198464','891136','435517','994237','238134','238135','308363','1312713','994226','197447','1111706','243011','1537029','1536840','1536871','1536467','1536675','996989','996991','996994','1536498','1536670','1291868','857525','197930','197945','724614','637540','848768','1049691','312287','849316','849315','646434','198467','198466','1050241','212033','198468','1234872','313806','863184','647984','994528','828585','828594','654251','1192977','243683','198479','863186','243685','994810','308366','198470','435504','235945','198480','1297833','702316','1537019','1536815','806446','1537200','1536993','1536833','1536503','1250907','1092398','106809','857121','308410','435521','308409','246460','1052980','198471','333834','198472','198473','243663','410205','695963','197429','308370','797050','605252','1312718','308411','308412','247137','198475','198474','896884','876667','308414','103954','104475','104474','994535','198476','252380','432389','197374','349516','318272','403924','308416','747211','1537021','392294','1535484','243670','994435','900528','994811','308417','308418','391930','892160');
declare variable $p2t:ibuprofen as xs:string* := ('900431','153010','1310504','404831','702198','215041','993800','643061','902630','854184','578410','1101916','603609','1100067','702240','217324','217693','1372755','850404','1359092','165786','202488','284787','895656','637194','1429982','219128','1300262','579458','1151095','1191701','900435','220826','643099','1090447','900434','731536','731535','206878','731533','153008','731531','731529','1310509','1297371','1297392','1310489','1299020','1299022','1369777','901818','902633','854187','1049591','1101919','1310491','1100070','702243','206886','206905','206913','206917','859317','858780','850424','1359097','854760','1190622','792242','806013','544393','606990','201126','854762','201142','201152','202098','1310494','895666','637197','1429987','1232135','206876','1300267','859331','858772','858784','1151098','1190626','1191706','900438','858838','644386','643102','1299089','1297390','1310503','1297369','997164','997165','997280','1292323','895664','901814','1100066','859315','858770','858778','858798','392668','141997','389244','1362736','637193','1310487','310963','198405','748641','197803','854183','1369775','1299018','1299021','227159','310964','310965','141993','401976','380813','197804','1049589','197805','314047','204442','141998','226617','142102','197806','250418','197807');
declare variable $p2t:naproxen as xs:string* := ('352399','215101','1494155','849730','202399','603347','218599','203012','1117224','880900','794765','1372705','643130','1116331','1116341','1116351','849578','1112233','849728','1494160','1367428','849400','849438','849752','207093','105898','608793','105914','835560','105899','1117370','1117227','1373034','849452','994007','994010','849737','994005','994008','1494652','245420','311913','1114869','105918','198013','603103','1116320','198012','1116339','311915','198014','199490','1116349','849574','1367426','1112231','849398','849450','849431');
declare variable $p2t:campath as xs:string* := ('828265');
declare variable $p2t:methadone as xs:string* := ('991147','1361710','864706','864769','864714','864751','864984','864794','864978','864718','864761','864828');
declare variable $p2t:hydromorphone as xs:string* := ('1233859', '1233863', '1012656', '1012667', '1012666', '1012678', '1247421',
      '1014218', '1012679', '1247434', '1010898', '1250433', '1233856', '1242551', '897767', '1010897', '897771',
      '897756', '1433251', '1192498', '897653', '898004', '1013725', '1233700');
declare variable $p2t:morphine as xs:string* := ('1292838','894911','1234301','1115483','894912','1232113','998212','1303841','998213','1442790','894914','1312991','894915','891883','891878','894918','891885','891890','1241711','1306278','894926','894930','892297','894932','894938','894941','892342','894942','894969','892349','894970','894971','892355','1234294','1234295','1234291','1234292','1234297','1234293','1234298','1234290','1234299','1234300','1234296','1190775','1190785','895867','895927','894976','1247720','892365','892477','894997','892494','895014','892516','892531','895016','863845','892554','891874','895022','1303729','895027','891881','892579','892582','895185','895194','894933','895200','892589','895199','863848','892596','895201','892603','895202','892625','892643','892646','895206','895861','892650','895209','895208','863850','892345','891888','892669','892672','892678','895213','895215','895216','894780','1303736','895217','895869','894807','895220','895219','863852','894801','895221','895227','895229','895871','895237','895238','895233','895240','863854','892352','891893','895247','1303740','895248','895249','863856','894814');
declare variable $p2t:infliximab as xs:string* := ('310994');
declare variable $p2t:adalimumab as xs:string* := ('763564','727703','351290');
declare variable $p2t:certolizumab as xs:string* := ('849597','795081');
declare variable $p2t:golimumab as xs:string* := ('1482813','848160','1431642');
declare variable $p2t:entanercept as xs:string* := ('253014','809158','727757','582671');
declare variable $p2t:bupoprion as xs:string* := ('993550','993567','993681','993503','993687','993518','993536','1232585','993697','993691','993541','993557');
declare variable $p2t:methotrexate as xs:string* := ('1441407','1441418','105586','1441402','105589','311626','283510','1441411','105585','315148','1441416','1441422','311627','283511','311625','283671','1441403','1441413','1441424','491604','579782','284900','284593','284595','284592','284594');
declare variable $p2t:ustekinumab as xs:string* := ('853351','853354','853356','865174','865172','853350','853355');
declare variable $p2t:famciclovir as xs:string* := ('199192', '199193', '198382');
declare variable $p2t:acyclovir as xs:string* := ('307730', '1250667', '998422', '141859', '197312', '313812', '415660',
    '197310', '199524', '197311', '1423662', '197313');
declare variable $p2t:canakinumab as xs:string* := ('853494', '853498', '853495');
declare variable $p2t:lipitor as xs:string* := ('617314'); (:Incomplete set of codes here :)
declare variable $p2t:cyclophosamide as xs:string* := ('1156181', '1156182', '1156183', '1437967', '1437968', '1437969', '197549', '1437968', '1437969', '197550', '315746', '315747', '329664', '371664', '376666', '637543');

declare function p2t:glp-1-agonists($root as element(c:ClinicalDocument)) as xs:boolean {
  p2t:taking-medication($root, '744863')
};

(:
declare function p2t:on-lipid-lowering-treatment($root as element(c:ClinicalDocument)) as xs:boolean {
(\: Faking this by using the code for Lipitor which was the only prescribed statin in the EMERGE data set :\)
  p2t:taking-medication($root, )
};:)

declare function p2t:taking-cyclophosphamide-last-180-days($root as element(c:ClinicalDocument)) as xs:boolean {
  let $med-codes := p2t:medications-within-days($root, 180)
  return exists(functx:value-intersect($med-codes, $p2t:cyclophosamide))
};

declare function p2t:medications-within-days($root as element(c:ClinicalDocument),
                                             $days as xs:integer) {
  let $effectiveTime := p2t:parse-date-time($root/c:effectiveTime/@value), 
      $windowTime := $effectiveTime - xs:dayTimeDuration(fn:concat('P', $days, 'D'))
  for $substanceAdministration in $root//c:section/c:code[@code='10160-0']/../c:entry/c:substanceAdministration     
  where 
    ( exists($substanceAdministration/c:effectiveTime/c:high/@value) 
        and p2t:parse-date-time($substanceAdministration/c:effectiveTime/c:high/@value) gt $windowTime) 
    or ( not( exists($substanceAdministration/c:effectiveTime/c:high/@value)) 
        and p2t:parse-date-time($substanceAdministration/c:effectiveTime/c:low/@value) gt $windowTime)
  return normalize-space($substanceAdministration/c:consumable/c:manufacturedProduct/c:manufacturedMaterial/c:code/@code)
};

declare function p2t:procedure-codes($root as element(c:ClinicalDocument))  {
  for $code in $root//c:section/c:code[@code='47519-4']/../c:entry/c:procedure/c:code/@code
  return normalize-space($code)
};

declare function p2t:on-dialysis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:procedure-codes($root)
  return exists(index-of($codes, '90935'))
};

declare function p2t:had-heart-transplant($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:procedure-codes($root)
  return exists(index-of($codes, '32413006'))
};
