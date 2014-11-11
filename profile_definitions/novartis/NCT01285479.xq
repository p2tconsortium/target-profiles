import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at 'https://raw.github.com/Corengi/target-profiles/master/resources/library_novartis.xq';
import module namespace functx = 'http://www.functx.com' at 'https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT01285479_FTY720D2404.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
    let $age := p2t:age-in-years($root),
      $isOfAge := $age ge 18 and $age le 45
    return $isOfAge 
        and p2t:historical-prescription-for($root, $p2t:fingolimod)
        and p2t:has-problem($root, $p2t:multiple-sclerosis)
        and p2t:is-pregnant($root)
        and p2t:is-female($root)
};

(:
Must have a first prescription, not older than 6 months, for any of the following treatments:
If no such prescription is in the health record, exclude the patient.
If there exists a prescription for any of these treatments which is older than 6 months, exclude the patient.
:)


