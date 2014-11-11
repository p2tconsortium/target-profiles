import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at '../../library_novartis.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT01291511_ILO522D2301.docx :)
 
declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years($root),
      $is-of-age := $age ge 18 and $age le 65
  return $is-of-age and p2t:bmi-in-range($root, 17, 40)
    and p2t:problem-observations-before-n-months($root, $p2t:schizophrenia, 12)
    and not(p2t:has-problem($root, $p2t:schizophreniform-disorder))
    and not(p2t:has-problem($root, $p2t:schizoaffective))
    and not(p2t:has-problem($root, $p2t:epilepsy))
    and not(p2t:has-problem($root, $p2t:hepatitis-b))
    and not(p2t:has-problem($root, $p2t:hepatitis-c))
    and not(p2t:is-pregnant($root))
};


