import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at '../../library_novartis.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT02059291_ACZ885N2301.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years($root),
      $is-of-age := $age ge 2
  return $is-of-age
    and (
        p2t:has-problem($root, $p2t:TRAPS)
        or p2t:has-problem($root, $p2t:HIDS)
        or p2t:has-problem($root, $p2t:crFMF)
        )  
};


