import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at '../../library_novartis.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT01770379_AIN457F2311.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years($root),
      $is-of-age := $age ge 18
  return $is-of-age 
    and p2t:has-problem($root, $p2t:rheumatoid-arthritis)
    and not(p2t:has-problem($root, $p2t:uveitis))
    and not(p2t:has-problem($root, $p2t:irritable-bowel))
    and not(p2t:has-problem($root, $p2t:hepatitis-b))
    and not(p2t:has-problem($root, $p2t:hepatitis-c))
    and not(p2t:has-problem($root, $p2t:hiv))
    and not(p2t:has-problem($root, $p2t:tuberculosis))
    and local:taking-medications($root)
    and not(p2t:historical-prescription-for($root, $p2t:ustekinumab))
    and not(p2t:historical-prescription-for($root, $p2t:methadone))
    and not(p2t:historical-prescription-for($root, $p2t:hydromorphone))
    and not(p2t:historical-prescription-for($root, $p2t:morphine))
};

declare function local:taking-medications($root as element(c:ClinicalDocument)) as xs:boolean {
  let $values := (
    p2t:historical-prescription-for($root, $p2t:infliximab),
    p2t:historical-prescription-for($root, $p2t:adalimumab),
    p2t:historical-prescription-for($root, $p2t:certolizumab),
    p2t:historical-prescription-for($root, $p2t:golimumab),
    p2t:historical-prescription-for($root, $p2t:entanercept),
    p2t:historical-prescription-for($root, $p2t:bupoprion)),
    $taking-two-or-more-of := count( index-of($values, true()) ) ge 2
  return $taking-two-or-more-of and p2t:historical-prescription-for($root, $p2t:methotrexate)
};


