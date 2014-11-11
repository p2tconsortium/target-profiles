import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at 'https://raw.github.com/Corengi/target-profiles/master/resources/library_combined.xq';

declare namespace c = 'urn:hl7-org:v3';

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years($root),
      $is-of-age := $age ge 18 or $age le 75
  return $is-of-age
    and p2t:has-problem($root, $p2t:systemic-lupus-erythematosus)
    and not(p2t:has-problem($root, $p2t:hepatitis-b))
    and not(p2t:has-problem($root, $p2t:hepatitis-c))
    and not(p2t:has-problem($root, $p2t:hiv))
    and not(p2t:has-problem($root, $p2t:multiple-sclerosis))
    and not(p2t:has-problem($root, $p2t:lupus-nephritis))
    and not(p2t:has-problem($root, $p2t:congestive-heart-failure-class-d))
    and not(p2t:has-problem($root, $p2t:congestive-heart-failure-class-c))
    and not(p2t:has-problem($root, $p2t:acute-coronary-syndrome))
    and not(p2t:has-problem($root, $p2t:tuberculosis))
    and not(p2t:medication-observations-within-n-days($root, $p2t:cyclophosamide, 180))
};

for $ccda in fn:collection('../ccdas/EMERGE/?select=*.xml')
return if (local:match-result($ccda/c:ClinicalDocument))
then <CCDA>{base-uri($ccda)}</CCDA>
else ''
