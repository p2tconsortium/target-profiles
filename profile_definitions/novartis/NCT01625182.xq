import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at 'https://raw.github.com/Corengi/target-profiles/master/resources/library_novartis.xq';
import module namespace functx = 'http://www.functx.com' at 'https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT01625182_FTY720I2201.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
    let $age := p2t:age-in-years($root),
      $isOfAge := $age ge 18 and $age le 75
    return $isOfAge 
        and p2t:has-problem($root, $p2t:chronic-inflammatory-demyelinating-polyradiculoneuropathy)
        and not(p2t:has-problem($root, $p2t:chrons-disease))
        and not(p2t:has-problem($root, $p2t:castlemans-disease))
        and not(p2t:has-problem($root, $p2t:osteosclerotic-myeloma))
        and not(p2t:has-problem($root, $p2t:POEMS-syndrome))        
        and not(p2t:has-problem($root, $p2t:lyme-disease))        
        and not(p2t:has-problem($root, $p2t:multifocal-motor-neuropathy))        
        and not(p2t:has-problem($root, $p2t:rheumatoid-arthritis))
        and not(p2t:has-problem($root, $p2t:daibetes-mellitus))
        and not(p2t:has-problem($root, $p2t:hepatitis-a))
        and not(p2t:has-problem($root, $p2t:hepatitis-b))
        and not(p2t:has-problem($root, $p2t:hepatitis-c))
        and not(p2t:has-problem($root, $p2t:hiv))
        and not(p2t:has-problem($root, $p2t:scleroderma))
        and not(p2t:has-problem($root, $p2t:sjogrens))
        and not(p2t:has-problem($root, $p2t:ulcerative-colitis))
        and not(p2t:has-problem($root, $p2t:macular-edema))
        and not(p2t:has-problem($root, $p2t:myocarditis))
        and not(p2t:has-problem($root, $p2t:cardiomyopathy))
        and not(p2t:has-problem($root, $p2t:COPD))
        and not(p2t:has-problem($root, $p2t:pulmonary-fibrosis))
        and not(p2t:has-problem($root, $p2t:tuberculosis))
        and p2t:medication-observations-within-n-days(
                $root, 
                ($p2t:IVIg, $p2t:prednisone-ge-10mg, $p2t:clobetasone, $p2t:deflazacort, $p2t:medrysone, 
                $p2t:aldosterone, $p2t:desoxycorticosterone, $p2t:fludrocortisone), 
                84)
        and not(p2t:historical-prescription-for($root, ($p2t:cladribine, $p2t:mitoxantrone, $p2t:alemtuzumab)))
        and not(p2t:medication-observations-within-n-months($root, $p2t:rituximab, 24))
};


