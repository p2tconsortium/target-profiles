import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at 'https://raw.github.com/Corengi/target-profiles/master/resources/library_novartis.xq';
import module namespace functx = 'http://www.functx.com' at 'https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT01544491_RAD001A2314.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
    let $age := p2t:age-in-years($root),
      $isOfAge := $age ge 1 and $age le 17
    return $isOfAge 
        and p2t:has-problem($root, ($p2t:chronic-kidney-disease-stage-4, $p2t:chronic-kidney-disease-stage-5))
        and not(p2t:has-problem($root, $p2t:hemolytic-uremic-syndrome))
        and not(p2t:has-problem($root, $p2t:hepatitis-c))
        and not(p2t:has-problem($root, $p2t:hiv))
        and not(p2t:has-problem($root, $p2t:COPD))
        and not(p2t:has-problem($root, $p2t:pulmonary-fibrosis))
};



