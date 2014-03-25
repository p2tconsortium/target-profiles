import module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/Corengi/target-profiles/master/resources/library.xq";

declare namespace c = 'urn:hl7-org:v3';

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := p2t:age-in-years(xs:string($root//c:patient[1]/c:birthTime/@value)),
      $is-of-age := $age ge 21,
      $is-type2 := p2t:is-type2($root),
      $is-not-renal := not(p2t:is-renal-disease($root) or p2t:acute-renal-failure($root)),
      $no-insulin := not(p2t:taking-medication($root, '847207')),
      $bmi-ok := p2t:bmi-in-range($root, 23, 45),
      $a1c-ok := p2t:a1c-in-range($root, 7.0, 10.5)
  return $is-of-age and $is-type2 and $is-not-renal and $bmi-ok and $a1c-ok and $no-insulin
         and not(p2t:acute-myocardial-infarction-past-6-months($root))
         and not(p2t:acute-q-wave-myocardial-infarction-past-6-months($root))
         and not(p2t:malignant-prostate-tumor-past-60-months($root))
         and not(p2t:tumor-stage-t1c-past-60-months($root))
         and not(p2t:secondary-malignant-neoplasm-of-bone-past-60-months($root))
         and not(p2t:neoplasm-of-colon-past-60-months($root))
         and not(p2t:malignant-neoplasm-of-female-breast-past-60-months($root))
         and not(p2t:hormone-receptor-positive-tumor-past-60-months($root))
         and not(p2t:tumor-stage-t2c-past-60-months($root))
};
