(:~
: This module contains functions related to parsing Problem Observations.
: All $searchCodes are expected to be SNOMED CT and/or ICD-9 codes.
: 
: @author Jesse Clark
: @version 0.2
:)
module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";

declare namespace c = 'urn:hl7-org:v3';
import module "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/Corengi/target-profiles/master/resources/utils.xq", "https://raw.github.com/Corengi/target-profiles/master/resources/problem_codes.xq";
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq";

(:~
: Checks for an ACTIVE diagnosis for a problem or condition as defined by a given set of SNOMED and/or ICD-9 codes.
: NOTE: The $searchCodes parameter is assumed to represent ONLY ONE condition and only the most recent observation for that condition
: is analyzed to determine if the problem/condition is still active.
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $searchCodes A sequence of strings or elements containing strings of the codes for a set of problems.
: @return a sequence containing the most recent active Problem Observation as a node or the empty sequence if no observations were found for the problem.
: @see p2t:active-problem-observation
:)
declare function p2t:has-problem($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()* {
  p2t:active-problem-observation($root, $searchCodes)
};

(:~
: Finds the most recent active problem observation for a condition. 
:  
: Definition of 'active':
:   - A <high> element in effective time indicates a problem that is known to be resolved (pg 448 9.c. ) 
:   - The optional Problem Status template can also include a SNOMED code for active/resolved (pg 451, values on pg 310) 
:   - The most recent observation for a condition does not have negationInd='true'
:        
: TODO: We might want to handle the case in Figure 214. pg450 of the IG which uses @negationInd with the generic SNOMED code for 'Problem' to indicate 'No known problems'. 
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $searchCodes A sequence of strings or elements containing strings of the codes for a set of problems.
: @return a sequence containing the most recent active Problem Observation as a node or the empty sequence
:         if no observations were found for the problem OR if the most recent problem observation indicates that the problem is resolved.
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

(:~
: Finds the set of Problem Observations for a given set of problem codes
: 
: NOTES:
:   - This method only looks for observations which contain an observation/code with a ProblemType value of 
:      Diagnosis 282291009, Problem 55607006, or Condition 64572001. See IG page 448 #6
:   - Results exclude any observations which have a @negationInd of true. This means the problem was observed not to be present. 
:   - Also searches for Problem Observation templates in EncounterDiagnosis template in the Encounters section.
:   - Can match against ICD-9 codes in <translation> elements.
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $searchCodes A sequence of strings or elements containing strings of the codes for a set of problems.
: @return a sequence containing Problem Observations as nodes or the empty sequence if no observations were found for the problem(s).
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

(:~
: Finds the set of Problem Observations for a given set of problem codes which were observed N months before the current date.
: 
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $searchCodes A sequence of strings or elements containing strings of the codes for a set of problems.
: @param $months the number of months to search before
: @return a sequence containing Problem Observations as nodes or the empty sequence if no observations were found for the problem(s).
:)
declare function p2t:problem-observations-before-n-months($root as element(c:ClinicalDocument), $searchCodes as item()*, $months as xs:integer) as item()* {
  for $observation in p2t:active-problem-observation($root, $searchCodes)
  let
    $effectiveTime := fn:current-dateTime(),
    $windowTime := $effectiveTime - xs:yearMonthDuration(fn:concat('P', $months, 'M')),
    $observationTime := $observation/c:effectiveTime/c:low/@value
  where exists($observationTime) and p2t:parse-date-time($observationTime) lt $windowTime
  return $observation
};

(:~
: Finds the set of Problem Observations for a given set of problem codes which were observed within N months of the current date.
: 
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $searchCodes A sequence of strings or elements containing strings of the codes for a set of problems.
: @param $months the number of months to search within
: @return a sequence containing Problem Observations as nodes or the empty sequence if no observations were found for the problem(s).
:)
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

