import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at 'https://raw.github.com/Corengi/target-profiles/master/resources/library_novartis.xq';
import module namespace functx = 'http://www.functx.com' at 'https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT01442194_FTY720D2403.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
    let 
        $searchCodes := ($p2t:fingolimod, $p2t:aubagio, $p2t:avonex, $p2t:betaseron, $p2t:copaxone, $p2t:extavia, $p2t:rebif, $p2t:tecfidera),
        $hasScriptLongerThan6Months := exists(p2t:medications-before-n-months($root, $searchCodes, 6))
    return p2t:has-problem($root, $p2t:multiple-sclerosis)
        and not($hasScriptLongerThan6Months) 
        and p2t:historical-prescription-for($root, $searchCodes)
        and not(p2t:historical-prescription-for($root, $p2t:cladribine))
        and not(p2t:historical-prescription-for($root, $p2t:mitoxantrone))
        and not(p2t:historical-prescription-for($root, $p2t:alemtuzumab))
        and not(p2t:historical-prescription-for($root, $p2t:natalizumab))
};

(:
Must have a first prescription, not older than 6 months, for any of the following treatments:
If no such prescription is in the health record, exclude the patient.
If there exists a prescription for any of these treatments which is older than 6 months, exclude the patient.
:)


