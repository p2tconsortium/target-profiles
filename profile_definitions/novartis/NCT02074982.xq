import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at '../../library_novartis.xq';
import module namespace functx = 'http://www.functx.com' at 'https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT02074982_AIN457F2317.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years($root),
      $is-of-age := $age ge 18,
      $blood-pressure-result := p2t:blood-pressure-lower-than($root, 160, 95), 
      $blood-pressure-ok := empty($blood-pressure-result) or $blood-pressure-result
  return $is-of-age and $blood-pressure-ok
    and p2t:problem-observations-before-n-months($root, $p2t:plaque-psoriasis, 6)
    and not(local:novartis-has-other-psoriasis($root))
    and not(p2t:has-problem($root, $p2t:hepatitis-b))
    and not(p2t:has-problem($root, $p2t:hepatitis-c))
    and not(p2t:has-problem($root, $p2t:hiv))
    and not(p2t:historical-prescription-for($root, $p2t:ustekinumab))
};

declare function local:novartis-has-other-psoriasis($root as element(c:ClinicalDocument)) as xs:boolean {
  let $searchCodes := ('696.0', '200973000', '27520001', '200977004', '37042000')
  return exists(p2t:problem-observations($root, $searchCodes))
};


