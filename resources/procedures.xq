module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
declare namespace c = 'urn:hl7-org:v3';

declare function p2t:procedure-codes($root as element(c:ClinicalDocument))  {
  for $code in $root//c:section/c:code[@code='47519-4']/../c:entry/c:procedure/c:code/@code
  return normalize-space($code)
};

declare function p2t:on-dialysis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:procedure-codes($root)
  return exists(index-of($codes, '90935'))
};

declare function p2t:had-heart-transplant($root as element(c:ClinicalDocument)) as xs:boolean {
  let $codes := p2t:procedure-codes($root)
  return exists(index-of($codes, '32413006'))
};