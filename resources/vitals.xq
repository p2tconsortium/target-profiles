module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
declare namespace c = 'urn:hl7-org:v3';
import module "https://consortium-data.lillycoi.com/target-profiles" at "utils.xq";

declare function p2t:age-in-years($birth as xs:string) as xs:decimal {
  let $duration := fn:current-dateTime() - p2t:parse-date-time($birth),
      $days := days-from-duration($duration),
      $years := $days div 365
  return $years
};

declare function p2t:is-female($patient as element(c:patient)) as xs:boolean {
  let $code := xs:string($patient/c:administrativeGenderCode/@code)
    return $code eq 'F'
};

declare function p2t:is-male($patient as element(c:patient)) as xs:boolean {
  let $code := xs:string($patient/c:administrativeGenderCode/@code)
    return $code eq 'M'
};

(: 
  $estimatedDeliveryTime is an optional value in the CCDA. Erring on the side of creating false positives by only returning true 
  if the delivery time is present and in the future
:) 
declare function p2t:is-pregnant($root as element(c:ClinicalDocument)) as xs:boolean {
  let $pregnancyObservations := 
    for $observation in $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.17']/../c:entry/c:observation/c:templateId[@root='2.16.840.1.113883.10.20.15.3.8']/..
      let $estimatedDeliveryTime := p2t:parse-date-time($observation/c:entryRelationship/c:observation/c:templateId[@root='2.16.840.1.113883.10.20.15.3.1']/../c:value),
          $currentTime := current-dateTime()
      where not(empty($estimatedDeliveryTime)) and $estimatedDeliveryTime ge $currentTime
      return true()
   return not(empty($pregnancyObservations))
};

declare function p2t:last-vital-sign($code as xs:string, $root as element(c:ClinicalDocument)) as xs:decimal? {
  let $ordered :=
    for $observation in $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.4.1']/../c:entry/c:organizer/c:component/c:observation
      where $observation/c:code[@code=$code]
      order by $observation/c:effectiveTime/@value descending
      return xs:decimal($observation/c:value/@value)
  return $ordered[1]
};

declare function p2t:last-weight-measured($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-vital-sign('3141-9', $root)
};

declare function p2t:last-systolic($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-vital-sign('8480-6', $root)
};

declare function p2t:last-diastolic($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-vital-sign('8462-4', $root)
};

declare function p2t:blood-pressure-lower-than($root as element(c:ClinicalDocument), $max-systolic as xs:decimal, $max-diastolic as xs:decimal) as xs:boolean? {
  let $last-systolic := p2t:last-systolic($root),
    $last-diastolic := p2t:last-diastolic($root)
  return if (empty($last-systolic) or empty($last-diastolic)) then () else $last-systolic le $max-systolic and $last-diastolic le $max-diastolic
};

declare function p2t:avg-bmi($root as element(c:ClinicalDocument)) as xs:decimal {
  fn:avg(for $observation in
    $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.4.1']/../c:entry/c:organizer/c:component/c:observation/c:code[@code='39156-5']/..
    return xs:decimal($observation/c:value/@value))
};

declare function p2t:last-bmi($root as element(c:ClinicalDocument)) as xs:decimal? {
  let $ordered :=
    for $observation in $root//c:section/c:templateId[@root='2.16.840.1.113883.10.20.22.2.4.1']/../c:entry/c:organizer/c:component/c:observation
      where $observation/c:code[@code='39156-5']
      order by $observation/c:effectiveTime/@value descending
      return xs:decimal($observation/c:value/@value)
  return $ordered[1]
};

declare function p2t:bmi-in-range($root as element(c:ClinicalDocument),
                                    $bmi-min as xs:decimal, $bmi-max as xs:decimal) as xs:boolean {
  let $bmi := p2t:last-bmi($root)
  return if (empty($bmi)) then true() else $bmi ge $bmi-min and $bmi le $bmi-max
};