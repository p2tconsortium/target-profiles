import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at '../../library_novartis.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT01925209_BYM338B2203.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years($root),
      $is-of-age := $age ge 36 and $age le 85
  return $is-of-age 
    and p2t:has-problem($root, $p2t:inclusion-body-myositis)
    and not(p2t:has-problem($root, $p2t:hepatitis-b))
    and not(p2t:has-problem($root, $p2t:hepatitis-c))
    and not(p2t:has-problem($root, $p2t:hiv))
    and not(p2t:has-problem($root, $p2t:tuberculosis))
};


