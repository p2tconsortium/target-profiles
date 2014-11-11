import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at '../../library_novartis.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT01676948_ACZ885G2306.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years($root),
      $is-of-age := $age ge 2 and $age le 20
  return $is-of-age
    and p2t:has-problem($root, $p2t:systemic-juvenile-idiopathic-arthritis)
    and not(p2t:historical-prescription-for($root, $p2t:canakinumab))
};


