(:~
: This module contains functions to return values and xml fragments related to labratory test Results Observations.
: @author Jesse Clark
: @version 0.1
:)
module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
import module "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/Corengi/target-profiles/master/resources/utils.xq", "https://raw.github.com/Corengi/target-profiles/master/resources/lab_codes.xq";
declare namespace c = 'urn:hl7-org:v3';
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq";


(:~
: Finds all Result Observations for a lab test.
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $codes A sequence of strings or elements containing strings of the codes that define a lab test (or tests).
: @return a sequence containing all assessment observations as nodes or the empty sequence if no observations were found for the lab.
:)
declare function p2t:lab-observations($root as element(c:ClinicalDocument), $codes as xs:string*) as item()* {
  let 
    $observations := $root/c:component/c:structuredBody/c:component/c:section[c:templateId[@root='2.16.840.1.113883.10.20.22.2.3.1']][1]/
            c:entry/c:organizer[c:templateId[@root='2.16.840.1.113883.10.20.22.4.1']]//c:component/
            c:observation[c:code[@code=$codes] and c:statusCode[@code eq 'completed']]
  return $observations
};

(:~
: Finds all Result Observations for a lab test or tests ordered by date descending.
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $codes A sequence of strings or elements containing strings of the codes that define a lab test (or tests).
: @return a sequence containing all assessment observations as nodes or the empty sequence if no observations were found for the lab.
:)
declare function p2t:lab-observations-ordered($root as element(c:ClinicalDocument), $codes as xs:string*) as item()* {
  let 
    $observations := p2t:lab-observations($root, $codes),
    $ordered := for $observation in $observations
        order by $observation/c:effectiveTime/@value descending
        return $observation
  return $ordered
};

(:~
: Finds the value for the most recent observation for a lab test or tests.
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $codes A sequence of strings or elements containing strings of the codes that define a lab test (or tests).
: @return a xs:decimal value
:)
declare function p2t:last-lab-result($root as element(c:ClinicalDocument), $codes as xs:string*) as xs:decimal? {
  let 
    $ordered := p2t:lab-observations-ordered($root, $codes)
  return xs:decimal($ordered[1]/c:value/@value)
};

