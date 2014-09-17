module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
import module "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/utils.xq", "https://raw.github.com/p2tconsortium/target-profiles/master/resources/lab_codes.xq";
declare namespace c = 'urn:hl7-org:v3';
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/p2tconsortium/target-profiles/master/resources/functx.xq";

declare function p2t:lab-observations($root as element(c:ClinicalDocument), $codes as xs:string*) as item()* {
  let 
    $observations := $root/c:component/c:structuredBody/c:component/c:section[c:templateId[@root='2.16.840.1.113883.10.20.22.2.3.1']][1]/
            c:entry/c:organizer[c:templateId[@root='2.16.840.1.113883.10.20.22.4.1']]//c:component/
            c:observation[c:code[@code=$codes] and c:statusCode[@code eq 'completed']]
  return $observations
};

declare function p2t:lab-observations-ordered($root as element(c:ClinicalDocument), $codes as xs:string*) as item()* {
  let 
    $observations := p2t:lab-observations($root, $codes),
    $ordered := for $observation in $observations
        order by $observation/c:effectiveTime/@value descending
        return $observation
  return $ordered
};

declare function p2t:last-lab-result($root as element(c:ClinicalDocument), $codes as xs:string*) as xs:decimal? {
  let 
    $ordered := p2t:lab-observations-ordered($root, $codes)
  return xs:decimal($ordered[1]/c:value/@value)
};

