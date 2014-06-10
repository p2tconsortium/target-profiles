import module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/library.xq";

declare namespace c = 'urn:hl7-org:v3';

(: Target_Profile_Form_RLX030A2209.docx :)
declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years(xs:string($root//c:patient[1]/c:birthTime/@value)),
      $is-of-age := $age ge 18,
      $is-of-weight := p2t:last-weight-measured($root) ne -1 and p2t:last-weight-measured($root) ge 352.7
  return $is-of-age and $is-of-weight
    and p2t:has-heart-failure($root) 
    and not(p2t:has-mitral-valve-disorder($root)) 
    and not(p2t:has-aortic-valve-disorder($root)) 
    and not(p2t:has-aortic-stenosis($root))
    and p2t:last-NT-proBNP($root) ge 300
};
