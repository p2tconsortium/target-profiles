declare function local:lmrb($root as element(c:ClinicalDocument)) as xs:boolean {
  let $age := local:age-in-years(xs:string($root//c:patient[1]/c:birthTime/@value)),
      $is-of-age := $age ge 21,
      $is-type2 := local:is-type2($root),
      $is-not-renal := not(local:is-renal-disease($root) or local:acute-renal-failure($root)),
      $no-insulin := not(local:taking-medication($root, '847207')),
      $bmi-ok := local:bmi-in-range($root, 23, 45),
      $a1c-ok := local:a1c-in-range($root, 7.0, 10.5)
  return $is-of-age and $is-type2 and $is-not-renal and $bmi-ok and $a1c-ok and $no-insulin
         and not(local:acute-myocardial-infarction-past-6-months($root))
         and not(local:acute-q-wave-myocardial-infarction-past-6-months($root))
         and not(local:malignant-prostate-tumor-past-60-months($root))
         and not(local:tumor-stage-t1c-past-60-months($root))
         and not(local:secondary-malignant-neoplasm-of-bone-past-60-months($root))
         and not(local:neoplasm-of-colon-past-60-months($root))
         and not(local:malignant-neoplasm-of-female-breast-past-60-months($root))
         and not(local:hormone-receptor-positive-tumor-past-60-months($root))
         and not(local:tumor-stage-t2c-past-60-months($root))
};