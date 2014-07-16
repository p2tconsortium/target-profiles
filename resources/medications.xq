module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
import module "https://consortium-data.lillycoi.com/target-profiles" at "utils.xq", "drug_codes.xq";

declare namespace c = 'urn:hl7-org:v3';
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/functx.xq";

declare function p2t:medications($root as element(c:ClinicalDocument))  {
  for $code in $root//c:section/c:code[@code='10160-0']/../c:entry/c:substanceAdministration/c:consumable/c:manufacturedProduct/c:manufacturedMaterial/c:code/@code
  return normalize-space($code)
};

(: TODO: refactor TPs to use taking-medications instead. Leaving here for now because still used in Lilly TPs :)
declare function p2t:taking-medication($root as element(c:ClinicalDocument), $med-code as xs:string) as xs:boolean {
  let $codes := p2t:medications($root)
  return exists(index-of($codes, $med-code))
};

declare function p2t:taking-medications($root as element(c:ClinicalDocument), $med-codes as item()*) as xs:boolean {
  let $codes := p2t:medications($root)
  return exists(functx:value-intersect($codes, $med-codes))
};

declare function p2t:medications-within-days($root as element(c:ClinicalDocument),
                                             $days as xs:integer) {
  let $effectiveTime := p2t:parse-date-time($root/c:effectiveTime/@value), 
      $windowTime := $effectiveTime - xs:dayTimeDuration(fn:concat('P', $days, 'D'))
  for $substanceAdministration in $root//c:section/c:code[@code='10160-0']/../c:entry/c:substanceAdministration     
  where 
    ( exists($substanceAdministration/c:effectiveTime/c:high/@value) 
        and p2t:parse-date-time($substanceAdministration/c:effectiveTime/c:high/@value) gt $windowTime) 
    or ( not( exists($substanceAdministration/c:effectiveTime/c:high/@value)) 
        and p2t:parse-date-time($substanceAdministration/c:effectiveTime/c:low/@value) gt $windowTime)
  return normalize-space($substanceAdministration/c:consumable/c:manufacturedProduct/c:manufacturedMaterial/c:code/@code)
};

declare function p2t:has-n-prescriptions-for($root as element(c:ClinicalDocument), $num-occurrences as xs:integer, $med-codes as item()*) as xs:boolean* {
  let $ccda-med-codes := p2t:medications($root)
  for $ccda-code in $ccda-med-codes,
    $code in $med-codes[. eq $ccda-code]
  where count($ccda-med-codes[. eq $code]) ge $num-occurrences
  return true()
};

(: 
  TODO: Refactor all taking-foo methods pulling the RxNorm codes out into global variables and call p2t:taking-medications($root, [GLOBAL])
        from target profile definitions.
:)

declare function p2t:glp-1-agonists($root as element(c:ClinicalDocument)) as xs:boolean {
  p2t:taking-medications($root, ('744863'))
};

declare function p2t:taking-cyclophosphamide-last-180-days($root as element(c:ClinicalDocument)) as xs:boolean {
  let $med-codes := p2t:medications-within-days($root, 180)
  return exists(functx:value-intersect($med-codes, $p2t:cyclophosamide))
};
