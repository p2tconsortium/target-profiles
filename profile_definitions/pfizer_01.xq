import module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/library.xq";

declare namespace c = 'urn:hl7-org:v3';

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years(xs:string($root//c:patient[1]/c:birthTime/@value)),
      $is-of-age := $age ge 18 or $age le 75
  return $is-of-age
    and p2t:has-systemic-lupus-erythematosus($root)
    and not(p2t:has-hep-b($root))
    and not(p2t:has-hep-c($root)) 
    and not(p2t:has-hiv($root))
    and not(p2t:has-multiple-sclerosis($root))
    and not(p2t:has-tuberculosis($root))
    and not(p2t:has-lupus-nephritis($root))
    and not(p2t:has-congestive-heart-failure-class-d($root))
    and not(p2t:has-congestive-heart-failure-class-c($root))
    and not(p2t:has-acute-coronary-syndrome($root))
    and not(p2t:taking-cyclophosphamide-last-180-days($root))
};
