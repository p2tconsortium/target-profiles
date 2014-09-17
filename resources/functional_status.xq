(:~
: This module contains functions to return values and xml fragments related to C-CDA Functional Status Observations.
: @author Jesse Clark
: @version 0.1
:)
module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
declare namespace c = 'urn:hl7-org:v3';
import module "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/Corengi/target-profiles/master/resources/utils.xq", "https://raw.github.com/Corengi/target-profiles/master/resources/assessment_scale_codes.xq";
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq";

(:~
: Finds the most recent result for a functional assessment.
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $codes A sequence of strings or elements containing strings of the codes that define a functional assessment.
: @return a sequence containing the most recent assessment result as an xs:decimal or the empty sequence if no values were found for the assessment.
:)
declare function p2t:last-assessment-result($root as element(c:ClinicalDocument), $codes as item()*) as xs:decimal* {
  let $ordered := p2t:assessment-observations-ordered($root, $codes)
  return if (empty($ordered)) then () else (xs:decimal(normalize-space($ordered[1]/c:value/@value)))
};

(:~
: Finds all values for a functional assessment.
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $codes A sequence of strings or elements containing strings of the codes that define a functional assessment.
: @return a sequence containing all assessment results as xs:decimals or the empty sequence if no values were found for the assessment.
:)
declare function p2t:assessment-values($root as element(c:ClinicalDocument), $codes as item()*) as xs:decimal* {
  for $observation in p2t:assessment-observations-ordered($root, $codes)
  return xs:decimal(normalize-space($observation/c:value/@value))
};

(:~
: Finds all observation elements for a functional assessment ordered by date descending.
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $codes A sequence of strings or elements containing strings of the codes that define a functional assessment.
: @return a sequence containing all assessment observations as nodes or the empty sequence if no observations were found for the assessment.
:)
declare function p2t:assessment-observations-ordered($root as element(c:ClinicalDocument), $codes as item()*) as item()* {
  let 
    $observations := p2t:assessment-observations($root, $codes),
    $ordered := for $observation in $observations
        order by $observation/c:effectiveTime/@value descending
        return $observation
  return $ordered
};

(:~
: Finds all observation elements for a functional assessment.
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $codes A sequence of strings or elements containing strings of the codes that define a functional assessment.
: @return a sequence containing all assessment observations as nodes or the empty sequence if no observations were found for the assessment.
:)
declare function p2t:assessment-observations($root as element(c:ClinicalDocument), $codes as item()*) as item()* {
  let $observations := $root/c:component/c:structuredBody/c:component/c:section[c:templateId[@root='2.16.840.1.113883.10.20.22.2.14']][1]/c:entry//
      c:observation[c:code[@code=$codes]]
  return $observations
};

(:~
: Finds all observation elements for a functional assessment that were completed within the last N months ordered by effectiveTime descending.
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $searchCodes A sequence of strings or elements containing strings of the codes that define a functional assessment.
: @param number of months to search within
: @return a sequence containing all assessment observations as nodes or the empty sequence if no observations were found for the assessment.
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

(:~
: Finds all values for a functional assessment that were completed within the last N months ordered by effectiveTime descending.
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $searchCodes A sequence of strings or elements containing strings of the codes that define a functional assessment.
: @param number of months to search within
: @return a sequence containing all values as xs:decimals or the empty sequence if no observations were found for the assessment.
:)
declare function p2t:assessment-values-within-n-months($root as element(c:ClinicalDocument), $searchCodes as item()*, $months as xs:integer) as item()* {
  for $observation in p2t:assessment-observations-within-n-months($root, $searchCodes, $months)
  return xs:decimal(normalize-space($observation/c:value/@value))
};

(:~
: Checks if a there are two values for a given assessment within the given period of months and returns true if the
: assessment value increased between the first and last measurement
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $searchCodes A sequence of strings or elements containing strings of the codes that define a functional assessment.
: @param number of months to search within
: @return xs:boolean 
:)
declare function p2t:assessment-increasing-within-n-months($root as element(c:ClinicalDocument), $searchCodes as item()*, $months as xs:integer) as xs:boolean {
  let $observations := p2t:assessment-observations-within-n-months($root, $searchCodes, $months)
  return if (exists($observations) and (fn:count($observations) >= 2)) then xs:decimal(normalize-space($observations[1]/c:value/@value)) gt xs:decimal(normalize-space($observations[last()]/c:value/@value)) else false()
};
