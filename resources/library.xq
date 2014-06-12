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
  let $code := xs:string($patient/c:administrativeGenderCode/@code)
    return $code eq 'F'
};

declare function p2t:is-male($patient as element(c:patient)) as xs:boolean {
  let $code := xs:string($patient/c:administrativeGenderCode/@code)
    return $code eq 'M'
};

declare function p2t:last-weight-measured($root as element(c:ClinicalDocument)) as xs:decimal {
  let $ordered :=
    for $observation in $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.4.1']/../c:entry/c:organizer/c:component/c:observation
      where $observation/c:code[@code='3141-9']
      order by $observation/c:effectiveTime/@value descending
      return xs:decimal($observation/c:value/@value)
  return if(not(empty($ordered))) then $ordered[1] else -1
};

declare function p2t:avg-bmi($root as element(c:ClinicalDocument)) as xs:decimal {
  fn:avg(for $observation in
    $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.4.1']/../c:entry/c:organizer/c:component/c:observation/c:code[@code='39156-5']/..
    return xs:decimal($observation/c:value/@value))
};

(: This will break when no bmi value found :)
declare function p2t:last-bmi($root as element(c:ClinicalDocument)) as xs:decimal {
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
  return $bmi ge $bmi-min and $bmi le $bmi-max
};

declare function p2t:last-a1c($root as element(c:ClinicalDocument)) as xs:decimal {
  p2t:last-lab-result('4548-4', $root)
};

declare function p2t:last-lab-result($code as xs:string, $root as element(c:ClinicalDocument)) as xs:decimal {
  let $ordered :=
    for $observation in $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.3.1']/..//c:observation
    where $observation/c:code[@code=$code]
    order by $observation/c:effectiveTime/@value descending
    return xs:decimal($observation/c:value/@value)
  return if(not(empty($ordered))) then $ordered[1] else 0
};

declare function p2t:last-HBsAg($root as element(c:ClinicalDocument)) as xs:decimal {
  p2t:last-lab-result('22322-2', $root)
};

declare function p2t:last-NT-proBNP($root as element(c:ClinicalDocument)) as xs:decimal {
  let 
    $code1 := p2t:last-lab-result('71425-3', $root),
    $code2 := p2t:last-lab-result('33762-6', $root)
  return
    if (not(empty($code1))) then $code1 else (if (not(empty($code2))) then $code2 else 0)
};

declare function p2t:last-LDL($root as element(c:ClinicalDocument)) as xs:decimal {
  p2t:last-lab-result('2089-1', $root)
};

declare function p2t:a1c-in-range($root as element(c:ClinicalDocument),
                                    $a1c-min as xs:decimal, $a1c-max as xs:decimal) as xs:boolean {
  let $a1c := p2t:last-a1c($root)
    return $a1c ge $a1c-min and $a1c le $a1c-max
};

declare function p2t:medications($root as element(c:ClinicalDocument))  {
for $code in $root//c:section/c:code[@code='10160-0']/../c:entry/c:substanceAdministration/c:consumable/c:manufacturedProduct/c:manufacturedMaterial/c:code/@code
 return normalize-space($code)
};

declare function p2t:taking-medication($root as element(c:ClinicalDocument), $med-code as xs:string) as xs:boolean {
  let $codes := p2t:medications($root)
  return exists(index-of($codes, $med-code))
};

declare function p2t:taking-medications($root as element(c:ClinicalDocument), $med-codes as item()*) as xs:boolean {
  let $codes := p2t:medications($root)
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:problem-codes($root as element(c:ClinicalDocument))  {
  for $code in $root//c:section/c:code[@code='11450-4']/../c:entry/c:act/c:entryRelationship/c:observation/c:value/@code
    return normalize-space($code)
};

declare function p2t:problems-within-months($root as element(c:ClinicalDocument),
                                             $months as xs:integer) {
  let $effectiveTime := p2t:parse-date-time($root/c:effectiveTime/@value),
      $windowTime := $effectiveTime - xs:yearMonthDuration(fn:concat('P', $months, 'M'))
  for $observation in $root//c:section/c:code[@code='11450-4']/../c:entry/c:act/c:entryRelationship/c:observation/c:code[@code='282291009']/..
  where p2t:parse-date-time($observation/c:effectiveTime/c:low/@value) gt $windowTime
    return normalize-space($observation/c:value/@code)
};

declare function p2t:hemorrhagic-cerebral-infarction($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '230706003'))
};

declare function p2t:is-type2($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '44054006'))
};

declare function p2t:is-renal-disease($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '46177005'))
};

declare function p2t:acute-renal-failure($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '14669001'))
};

declare function p2t:chronic-renal-failure($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '14669001'))
};

declare function p2t:end-stage-renal-disease($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '46177005'))
};

declare function p2t:has-hep-b-no-hepatic-coma($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '179047012')) or exists(index-of($codes, '634614015'))
};

declare function p2t:has-hep-b($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '66071002'))
};

declare function p2t:has-hep-c($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '50711007'))
};

declare function p2t:has-hep-d($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '424460009'))
};

declare function p2t:has-hiv($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '86406008'))
};


declare function p2t:has-congestive-heart-failure-class-b($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '67451000119104'))
};

declare function p2t:has-congestive-heart-failure-class-c($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '67441000119101'))
};

declare function p2t:has-congestive-heart-failure-class-d($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '67431000119105'))
};

declare function p2t:has-heart-failure($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '84114007'))
};

declare function p2t:has-acute-coronary-syndrome($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '394659003'))
};

declare function p2t:has-multiple-sclerosis($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
(:  There are other synonyms for this in snomed :)
  return exists(index-of($codes, '24700007'))
};

declare function p2t:has-tuberculosis($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '56717001'))
};

declare function p2t:has-lupus-nephritis($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '68815009'))
};

declare function p2t:has-systemic-lupus-erythematosus($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
(:  Checking for primary code and 3 synonyms :)
  return exists(index-of($codes, '55464009')) or exists(index-of($codes, '793827011')) 
  or exists(index-of($codes, '92208011')) or exists(index-of($codes, '1231480012'))
};

declare function p2t:has-psoriatic-arthritis($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '3333901'))
};

declare function p2t:has-plaque-psoriasis($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '200965009'))
};

declare function p2t:has-inclusion-body-myositis($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '72315009'))
};

declare function p2t:has-mitral-valve-disorder($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '11851006'))
};

declare function p2t:has-aortic-valve-disorder($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '8722008'))
};

declare function p2t:has-aortic-stenosis($root as element(c:ClinicalDocument))  {
  let $codes := p2t:problem-codes($root)
  return exists(index-of($codes, '60573004'))
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

declare function p2t:glp-1-agonists($root as element(c:ClinicalDocument)) as xs:boolean {
  p2t:taking-medication($root, '744863')
};

declare function p2t:on-lipid-lowering-treatment($root as element(c:ClinicalDocument)) as xs:boolean {
(: Faking this by using the code for Lipitor which was the only prescribed statin in the EMERGE data set :)
  p2t:taking-medication($root, '617314')
};

declare function p2t:taking-methadone($root as element(c:ClinicalDocument)) as xs:boolean {
  p2t:taking-medications($root, ('991147', '1361710', '864706', '864769', '864714', '864751', '864984', 
    '864794', '864978', '864718', '864761', '864828'))
};

declare function p2t:taking-hydromorphone($root as element(c:ClinicalDocument)) as xs:boolean {
    p2t:taking-medications($root, ('1233859', '1233863', '1012656', '1012667', '1012666', '1012678', '1247421',
      '1014218', '1012679', '1247434', '1010898', '1250433', '1233856', '1242551', '897767', '1010897', '897771',
      '897756', '1433251', '1192498', '897653', '898004', '1013725', '1233700'))
};
    
declare function p2t:taking-famciclovir($root as element(c:ClinicalDocument)) as xs:boolean {
  let $taking-med := p2t:taking-medications($root, ('199192', '199193', '198382'))
  return $taking-med
};

declare function p2t:taking-acyclovir($root as element(c:ClinicalDocument)) as xs:boolean {
  let $taking-med := p2t:taking-medications($root, ('307730', '1250667', '998422', '141859', '197312', '313812', '415660',
    '197310', '199524', '197311', '1423662', '197313'))
  return $taking-med
};

(:declare function p2t:taking-cyclophosphamide($root as element(c:ClinicalDocument)) as xs:boolean {
  let $taking-med := p2t:taking-medications($root, ('1156181', '1156182', '1156183', '1437967', '1437968', 
    '1437969', '197549', '1437968', '1437969', '197550', '315746', '315747', '329664', '371664', '376666', '637543'))
  return $taking-med 
};:)

declare function p2t:taking-cyclophosphamide-last-180-days($root as element(c:ClinicalDocument)) as xs:boolean {
  let $med-codes := p2t:medications-within-days($root, 180), 
    $cyclophosamide-codes := ('1156181', '1156182', '1156183', '1437967', '1437968', '1437969', '197549', '1437968', '1437969', '197550', '315746', '315747', '329664', '371664', '376666', '637543')     
  return exists(functx:value-intersect($med-codes, $cyclophosamide-codes))
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

declare function p2t:on-dialysis($root as element(c:ClinicalDocument))  {
  let $codes := p2t:procedure-codes($root)
  return exists(index-of($codes, '90935'))
};

declare function p2t:had-heart-transplant($root as element(c:ClinicalDocument))  {
  let $codes := p2t:procedure-codes($root)
  return exists(index-of($codes, '32413006'))
};
