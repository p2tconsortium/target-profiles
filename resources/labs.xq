module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
import module "https://consortium-data.lillycoi.com/target-profiles" at "utils.xq";

declare namespace c = 'urn:hl7-org:v3';
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/functx.xq";

declare function p2t:last-lab-result($code as xs:string, $root as element(c:ClinicalDocument)) as xs:decimal? {
  let $ordered :=
    for $observation in $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.3.1']/..//c:observation
    where $observation/c:code[@code=$code]
    order by $observation/c:effectiveTime/@value descending
    return xs:decimal($observation/c:value/@value)
  return $ordered[1]
};

declare function p2t:last-a1c($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-lab-result('4548-4', $root)
};

declare function p2t:a1c-in-range($root as element(c:ClinicalDocument), $a1c-min as xs:decimal, $a1c-max as xs:decimal) as xs:boolean {
  let $a1c := p2t:last-a1c($root)
  return if (empty($a1c)) then true() else $a1c ge $a1c-min and $a1c le $a1c-max
};

declare function p2t:last-HBsAg($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-lab-result('22322-2', $root)
};

(: There are (at least) 2 codes that could represent this lab test :)
declare function p2t:last-NT-proBNP($root as element(c:ClinicalDocument)) as xs:decimal? {
  let 
    $code1 := p2t:last-lab-result('71425-3', $root),
    $code2 := p2t:last-lab-result('33762-6', $root)
  return
    if (not(empty($code1))) then $code1 else (if (not(empty($code2))) then $code2 else ())
};

declare function p2t:last-LDL($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-lab-result('2089-1', $root)
};
