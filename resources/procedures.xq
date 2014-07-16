module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
declare namespace c = 'urn:hl7-org:v3';
import module "https://consortium-data.lillycoi.com/target-profiles" at "procedure_codes.xq";
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/functx.xq";

declare function p2t:procedure-codes($root as element(c:ClinicalDocument))  {
  for $code in $root//c:section/c:code[@code='47519-4']/../c:entry/c:procedure/c:code/@code
  return normalize-space($code)
};

declare function p2t:had-procedure($root as element(c:ClinicalDocument), $search-codes as item()*)  {
  let $procedure-codes := p2t:procedure-codes($root)
  return exists(functx:value-intersect($procedure-codes, $search-codes))
};

(: TODO: Refactor target profiles to use has-procedure() and the variables from prodcedure_codes :)
declare function p2t:on-dialysis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:procedure-codes($root)
  return exists(index-of($codes, '90935'))
};

declare function p2t:had-heart-transplant($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:procedure-codes($root)
  return exists(index-of($codes, '32413006'))
};