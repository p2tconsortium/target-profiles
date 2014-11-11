import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at 'https://raw.github.com/Corengi/target-profiles/master/resources/library_novartis.xq';
import module namespace functx = 'http://www.functx.com' at 'https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT01633112_FTY720D2312.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years($root),
      $isOfAge := $age ge 18 and $age le 65
  return $isOfAge
    and p2t:problem-observations-before-n-months($root, $p2t:relapsing-remitting-multiple-sclerosis, 10)
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
    and not(p2t:historical-prescription-for($root, $p2t:rituximab))
    and not(p2t:historical-prescription-for($root, $p2t:ofatumumab))
    and not(p2t:historical-prescription-for($root, $p2t:cladribine))
    and not(p2t:historical-prescription-for($root, $p2t:alemtuzumab))
    and not(p2t:historical-prescription-for($root, $p2t:fingolimod))
    and not(p2t:historical-prescription-for($root, $p2t:mitoxantrone))
    and local:has-EDSS-values($root)
};

declare function local:has-EDSS-values($root as element(c:ClinicalDocument)) as xs:boolean {
  let $values := p2t:last-assessment-result($root, $p2t:EDSS)
  return if (empty($values)) then true() else $values[1] ge 0 and $values[1] le 6.0
};



