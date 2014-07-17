import module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/library.xq";

declare namespace c = 'urn:hl7-org:v3';

(: Target_Profile_Form_LDT600A2306.docx :)
declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years(xs:string($root//c:patient[1]/c:birthTime/@value)),
      $is-of-age := $age ge 2 or $age le 18,
      $has-hep-b := p2t:has-hep-b($root)
(: $has-hep-b-no-hepatic-coma := p2t:has-hep-b-no-hepatic-coma($root) :)
  return $is-of-age and $has-hep-b
    and not(p2t:has-hep-c($root)) 
    and not(p2t:has-hep-d($root))
    and not(p2t:has-hiv($root)) 
    and not(p2t:taking-famciclovir($root))
    and not(p2t:taking-acyclovir($root))
(:    and p2t:last-HBsAg($root) this lab is an indicator of hep b diagnosis and is redundant :)
};
