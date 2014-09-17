(:~
: This module contains functions related to parsing Procedure Observations.
:
: @author Jesse Clark
: @version 0.2
:)
module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";

declare namespace c = 'urn:hl7-org:v3';
import module "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/Corengi/target-profiles/master/resources/procedure_codes.xq";
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq";

(:~
: Finds the set of Procedure Observations for a given set of procedure codes
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $searchCodes A sequence of strings or elements containing strings of the codes for a set of procedures.
: @return a sequence containing Procedure Observations as nodes or the empty sequence if no observations were found for the procedure(s).
:)
declare function p2t:procedure-observations($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()* {
  $root/c:component/c:structuredBody/c:component/c:section[c:code[@code='47519-4']]//c:entry/c:procedure[c:code[@code = $searchCodes]]
};

(:~
: Returns true() if a Procedure Observations is found in the CCD for a given set of procedure codes
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $searchCodes A sequence of strings or elements containing strings of the codes for a set of medications.
: @return xs:boolean
:)
decla
declare function p2t:has-procedure($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()*  {
  p2t:procedure-observations($root, $searchCodes)
};
