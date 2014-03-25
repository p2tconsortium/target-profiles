import module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/library.xq";

declare namespace c = 'urn:hl7-org:v3';

declare function local:match-result($root as element(c:ClinicalDocument)) {
  let $is-type2 := p2t:is-type2($root),
      $age := p2t:age-in-years(xs:string($root//c:patient[1]/c:birthTime/@value)),
      $min-age := $age ge 50,
      $a1c-ok := p2t:a1c-in-range($root, 0, 9.5),
      $no-insulin := not(p2t:taking-medication($root, '847207')),
      $glp-1-agonists := p2t:glp-1-agonists($root),
      $dialysis-excl := p2t:recent-diagnosis($root, 'Dialysis procedure', '598677011', 999, xs:boolean('true')),
      $pancreatitis-excl := p2t:recent-diagnosis($root, 'Pancreatitis', '75694006', 999, xs:boolean('true')),
      $thyroid-excl := p2t:recent-diagnosis($root, 'C-cell thyroid disorder', '2461417011', 999, xs:boolean('true')),
      $renal-disease-excl := p2t:recent-diagnosis($root, 'Acute renal disease', '46177005', 999, xs:boolean('true')),
      $pregnancy-excl := p2t:recent-diagnosis($root, 'Pregnancy', '315903005', 9, xs:boolean('true')),
      $ami2-excl := p2t:recent-diagnosis($root, 'Acute Myocardial Infarction', '57054005', 2, xs:boolean('true')),
      $stroke-excl := p2t:recent-diagnosis($root, 'Stroke, cerebrovascular accident', '230690007', 2, xs:boolean('true')),
      $hypoglycemia-excl := p2t:recent-diagnosis($root, 'Severe hypoglycemia', '302866003', 12, xs:boolean('true'))
      
  return $is-type2 and $min-age and $a1c-ok and $no-insulin and not($glp-1-agonists) 
         and $dialysis-excl and $pancreatitis-excl and $thyroid-excl and $renal-disease-excl
         and $pregnancy-excl and $ami2-excl and $stroke-excl and $hypoglycemia-excl
};