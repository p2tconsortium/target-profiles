import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at 'https://raw.github.com/Corengi/target-profiles/master/resources/library_combined.xq';

declare namespace c = 'urn:hl7-org:v3';

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
    p2t:historical-prescription-for($root, $p2t:lipitor)
    and p2t:last-lab-result($root, $p2t:LDL) ge 100
    and not(p2t:has-problem($root, $p2t:congestive-heart-failure-class-d))
    and not(p2t:has-problem($root, $p2t:chronic-renal-failure)) 
    and ( not( p2t:has-problem($root, $p2t:end-stage-renal-disease) or p2t:has-procedure($root, $p2t:dialysis) ) )
    and not(p2t:has-problem($root, $p2t:hemorrhagic-cerebral-infarction))
};

for $ccda in fn:collection('../ccdas/EMERGE/?select=*.xml')
return if (local:match-result($ccda/c:ClinicalDocument)) 
then <CCDA>{base-uri($ccda)}</CCDA>
else ''
