(:~
: This module contains functions related to parsing substanceAdministration observations.
: All $searchCodes are expected to be RxNORM codes.
: 
: @author Jesse Clark
: @version 0.2
:)
module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
import module "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/Corengi/target-profiles/master/resources/utils.xq", "https://raw.github.com/Corengi/target-profiles/master/resources/drug_codes.xq";

declare namespace c = 'urn:hl7-org:v3';
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq";

(:~
: Finds all substanceAdministration elements for set of medication codes
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $searchCodes A sequence of strings or elements containing strings of the codes for a set of medications.
: @return a sequence containing all substanceAdministrations as nodes or the empty sequence if no observations were found for the medications.
: @see p2t:historical-prescription-for
:)
declare function p2t:medication-observations($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()* {
  $root/c:component/c:structuredBody/c:component/c:section[c:code[@code='10160-0']][1]//c:entry/
        c:substanceAdministration[c:consumable/c:manufacturedProduct/c:manufacturedMaterial/c:code[@code = $searchCodes]]
};

(:~
: Alias for p2t:medication-observations
: Defines an 'historical prescription' as the patient having ever received the substances defined by the $searchCodes. 
:)
declare function p2t:historical-prescription-for($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()* {
  p2t:medication-observations($root, $searchCodes)
};

(:~
: Finds all substanceAdministrations occurring within N days of the current date.
: @param $root The root element (c:ClinicalDocument) of a CCD
: @param $searchCodes A sequence of strings or elements containing strings of the codes for a set of medications
: @param $days the number of days to search within
: @return a sequence containing all substanceAdministrations as nodes or the empty sequence if no observations were found for the medications
:)
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

(:~
: Finds all substanceAdministrations occurring within N months of the current date.
: @param $root The root element (c:ClinicalDocument) of a CCD
: @param $searchCodes A sequence of strings or elements containing strings of the codes for a set of medications
: @param $months the number of months to search within
: @return a sequence containing all substanceAdministrations as nodes or the empty sequence if no observations were found for the medications
:)
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

(:~
: Finds all substanceAdministrations occurring before N months of the current date.
: @param $root The root element (c:ClinicalDocument) of a CCD
: @param $searchCodes A sequence of strings or elements containing strings of the codes for a set of medications
: @param $months the number of months to search before
: @return a sequence containing all substanceAdministrations as nodes or the empty sequence if no observations were found for the medications
:)
declare function p2t:medications-before-n-months($root as element(c:ClinicalDocument), $searchCodes as item()*, $months as xs:integer) as item()* {
  for $observation in p2t:medication-observations($root, $searchCodes)
  let
    $effectiveTime := fn:current-dateTime(),
    $windowTime := $effectiveTime - xs:yearMonthDuration(fn:concat('P', $months, 'M')),
    $observationTime := $observation/c:effectiveTime/c:low/@value
  where exists($observationTime) and p2t:parse-date-time($observationTime) lt $windowTime
  return $observation
};


(:~
: Returns true if the CCD contains more than N occurences of substanceAdministrations for a given set of medications.
: @param $root The root element (c:ClinicalDocument) of a CCD
: @param $searchCodes A sequence of strings or elements containing strings of the codes for a set of medications
: @param $numOccurrences the number of occurences to search for
: @return xs:boolean
:)
declare function p2t:has-n-prescriptions-for($root as element(c:ClinicalDocument), $numOccurrences as xs:integer, $searchCodes as item()*) as xs:boolean {
  let $observations := p2t:medication-observations($root, $searchCodes)
  return count($observations) ge $numOccurrences
};

