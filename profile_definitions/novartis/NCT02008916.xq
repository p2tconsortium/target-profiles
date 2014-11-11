import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at '../../library_novartis.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT02008916_AIN457F2314.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean { 
  let $age := p2t:age-in-years($root),
      $is-of-age := $age ge 18,
      $blood-pressure-result := p2t:blood-pressure-lower-than($root, 160, 95),
      $blood-pressure-ok := empty($blood-pressure-result) or $blood-pressure-result
  return $is-of-age and $blood-pressure-ok 
    and p2t:has-problem($root, $p2t:ankylosing-spondylitis)
    and (p2t:has-n-prescriptions-for($root, 3, $p2t:aspirin)
        or p2t:has-n-prescriptions-for($root, 3, $p2t:ibuprofen)
        or p2t:has-n-prescriptions-for($root, 3, $p2t:naproxen))
    and not(p2t:has-problem($root, $p2t:uveitis))
    and not(p2t:has-problem($root, $p2t:irritable-bowel))
    and not(p2t:has-problem($root, $p2t:hepatitis-b))
    and not(p2t:has-problem($root, $p2t:hepatitis-c))
    and not(p2t:has-problem($root, $p2t:hiv))
    and not(p2t:has-problem($root, $p2t:tuberculosis))
    and not(p2t:is-pregnant($root))
    and not(p2t:historical-prescription-for($root, $p2t:methadone))
    and not(p2t:historical-prescription-for($root, $p2t:hydromorphone))
    and not(p2t:historical-prescription-for($root, $p2t:campath))
};


