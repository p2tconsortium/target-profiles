import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at '../../library_novartis.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT02058108_LDT600A2306.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years($root),
      $is-of-age := $age ge 2 and $age le 18,
      $has-hep-b := p2t:has-problem($root, $p2t:hepatitis-b)
  return $is-of-age and $has-hep-b
    and not(p2t:has-problem($root, $p2t:hepatitis-c))
    and not(p2t:has-problem($root, $p2t:hepatitis-d))
    and not(p2t:has-problem($root, $p2t:hiv))
    and not(p2t:historical-prescription-for($root, $p2t:famciclovir))
    and not(p2t:historical-prescription-for($root, $p2t:acyclovir))
};


