module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
declare namespace c = 'urn:hl7-org:v3';
import module "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/procedure_codes.xq";
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/functx.xq";

declare function p2t:procedure-observations($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()* {
  $root/c:component/c:structuredBody/c:component/c:section[c:code[@code='47519-4']]//c:entry/c:procedure[c:code[@code = $searchCodes]]
};

declare function p2t:has-procedure($root as element(c:ClinicalDocument), $searchCodes as item()*) as item()*  {
  p2t:procedure-observations($root, $searchCodes)
};
