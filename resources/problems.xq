module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
import module "https://consortium-data.lillycoi.com/target-profiles" at "utils.xq", "problem_codes.xq";

declare namespace c = 'urn:hl7-org:v3';
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/functx.xq";

declare function p2t:has-problem($root as element(c:ClinicalDocument), $search-codes as item()*)  {
  let $problem-codes := p2t:problem-codes($root)
  return exists(functx:value-intersect($problem-codes, $search-codes))
};

declare function p2t:has-problem-at-least-n-months($root as element(c:ClinicalDocument), $search-codes as item()*, $months as xs:integer) {
  let $problem-codes := p2t:problems-before-months($root, $months)
  return exists(functx:value-intersect($problem-codes, $search-codes))
};

declare function p2t:has-problem-within-n-months($root as element(c:ClinicalDocument), $search-codes as item()*, $months as xs:integer) {
  let $problem-codes := p2t:problems-within-months($root, $months)
  return exists(functx:value-intersect($problem-codes, $search-codes))
};

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

(: This is an unused example of returning more informative results rather than just pass/fail :)
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

(: Not updating Lilly TPs to use new style functions for now so leaving these functions as is :)

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
