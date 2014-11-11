import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at '../../library_novartis.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT01982292_RLX030A2209.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years($root),
      $is-of-age := $age ge 18,
      $last-weight := p2t:last-weight-measured($root),
      $is-of-weight := empty($last-weight) or $last-weight le 352.7
  return $is-of-age and $is-of-weight
    and p2t:last-lab-result($root, $p2t:NT-proBNP) ge 300
    and p2t:has-problem($root, $p2t:congestive-heart-failure)
    and not(p2t:has-problem($root, $p2t:mitral-valve-disorder))
    and not(p2t:has-problem($root, $p2t:aortic-valve-disorder))
    and not(p2t:has-problem($root, $p2t:aortic-stenosis))
};


