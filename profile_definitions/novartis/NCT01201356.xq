import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at 'https://raw.github.com/Corengi/target-profiles/master/resources/library_novartis.xq';
import module namespace functx = 'http://www.functx.com' at 'https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT01201356_FTY720D2399.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years($root),
      $isOfAge := $age ge 18
  return $isOfAge
    and p2t:problem-observations-before-n-months($root, $p2t:relapsing-remitting-multiple-sclerosis, 10)
    and p2t:historical-prescription-for($root, $p2t:fingolimod)
};


