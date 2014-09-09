module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
import module "https://consortium-data.lillycoi.com/target-profiles" at "utils.xq", "drug_codes.xq";

declare namespace c = 'urn:hl7-org:v3';
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq";


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

