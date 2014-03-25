module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";

declare namespace c = 'urn:hl7-org:v3';

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

declare function p2t:avg-bmi($root as element(c:ClinicalDocument)) as xs:decimal {
  fn:avg(for $observation in
    $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.4.1']/../c:entry/c:organizer/c:component/c:observation/c:code[@code='39156-5']/..
    return xs:decimal($observation/c:value/@value))
};

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
  let $ordered :=
  for $observation in $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.3.1']/..//c:observation
  where $observation/c:code[@code='4548-4']
  order by $observation/c:effectiveTime/@value descending
  return xs:decimal($observation/c:value/@value)
 return if(not(empty($ordered))) then $ordered[1] else 0
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