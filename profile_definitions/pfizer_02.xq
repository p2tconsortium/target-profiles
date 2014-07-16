import module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/library.xq";

declare namespace c = 'urn:hl7-org:v3';

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $on-lipid := p2t:on-lipid-lowering-treatment($root)
  return $on-lipid
    and p2t:last-LDL($root) ge 100
    and not(p2t:has-congestive-heart-failure-class-d($root))
    and not(p2t:chronic-renal-failure($root)) and (not(p2t:end-stage-renal-disease($root) or p2t:on-dialysis($root)))
    and not(p2t:hemorrhagic-cerebral-infarction($root))
};
