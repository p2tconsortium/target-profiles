import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at '../../library_novartis.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT01989468_AIN457F2318.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years($root),
      $is-of-age := $age ge 18
  return $is-of-age
    and p2t:problem-observations-before-n-months($root, $p2t:psoriatic-arthritis, 6)
    and p2t:has-problem($root, $p2t:plaque-psoriasis)
    and not(p2t:historical-prescription-for($root, $p2t:methadone))
    and not(p2t:historical-prescription-for($root, $p2t:hydromorphone))
    and not(p2t:historical-prescription-for($root, $p2t:campath))
    and not(p2t:historical-prescription-for($root, $p2t:morphine))
    and not(local:taking-more-than-three-of-these($root))
};

declare function local:taking-more-than-three-of-these($root as element(c:ClinicalDocument)) as xs:boolean {
  let $matches := (
    p2t:historical-prescription-for($root, $p2t:infliximab),
    p2t:historical-prescription-for($root, $p2t:adalimumab),
    p2t:historical-prescription-for($root, $p2t:certolizumab),
    p2t:historical-prescription-for($root, $p2t:golimumab),
    p2t:historical-prescription-for($root, $p2t:entanercept),
    p2t:historical-prescription-for($root, $p2t:bupoprion))
  return count(index-of($matches, true())) ge 4
};


