import module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/library.xq";

declare namespace c = 'urn:hl7-org:v3';

(: Target_Profile_Form_BYM338B2203.docx :)
declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years(xs:string($root//c:patient[1]/c:birthTime/@value)),
      $is-of-age := $age ge 36 and $age le 85
  return $is-of-age
    and p2t:has-inclusion-body-myositis($root) 
    and not(p2t:has-hep-b($root)) 
    and not(p2t:has-hep-c($root)) 
    and not(p2t:has-hiv($root)) 
    and not(p2t:has-tuberculosis($root))
};
