import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at 'https://raw.github.com/Corengi/target-profiles/master/resources/library_novartis.xq';
import module namespace functx = 'http://www.functx.com' at 'https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT02015663_TBM100CUS03.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
    let $age := p2t:age-in-years($root),
      $isOfAge := $age ge 6
    return $isOfAge 
        and p2t:has-problem($root, $p2t:cystic-fibrosis)            
};


