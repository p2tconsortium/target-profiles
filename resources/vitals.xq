(:~
: This module contains functions related to parsing Vital Signs Observations.
:
: @author Jesse Clark
: @version 0.2
:)
module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
declare namespace c = 'urn:hl7-org:v3';
import module "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/Corengi/target-profiles/master/resources/utils.xq";

(:
  TODO: This could break if birthTime has @nullFlavor='NAV' and no @value. Check for existence first.
  TODO: Seems like most methods should return item()* and use the empty sequence to indicate that the data was not present.
:)
(:~
: Finds a patient's age in years from a CCD.
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @return integer number of years 
:)
declare function p2t:age-in-years($root as element(c:ClinicalDocument)) as xs:decimal {
  let $duration := fn:current-dateTime() - p2t:parse-date-time($root/c:recordTarget[1]/c:patientRole[1]/c:patient[1]/c:birthTime[1]/@value),
      $days := days-from-duration($duration),
      $years := $days div 365
  return $years
};

(:~
: Finds a patient's gender code from a CCD.
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @return string gender code 
:)
declare function p2t:gender-code($root as element(c:ClinicalDocument)) as xs:string {
  $root/c:recordTarget[1]/c:patientRole[1]/c:patient[1]/c:administrativeGenderCode[1]/@code
};

(:~
: Returns true() if a patient is female
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @return xs:boolean 
:)
declare function p2t:is-female($root as element(c:ClinicalDocument)) as xs:boolean {
  let $code := p2t:gender-code($root)
  return $code eq 'F'
};

(:~
: Returns true() if a patient is maile
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @return xs:boolean 
:)
declare function p2t:is-male($root as element(c:ClinicalDocument)) as xs:boolean {
  let $code := p2t:gender-code($root)
  return $code eq 'M'
};

(: 
  TODO: At least one of the EMERGE CCDAs did not include a Pregnancy Observation template and instead listed a Problem Observation with 
    the SNOMED code for Pregnant state, incidental.
:) 
(:~
: Returns true() if a patient is indicated as being pregnant by the CCD.
:
: NOTE: $estimatedDeliveryTime is an optional value in the CCDA. Erring on the side of creating false positives by only returning true 
:    if the delivery time is present and in the future
:    
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @return xs:boolean 
:)
declare function p2t:is-pregnant($root as element(c:ClinicalDocument)) as xs:boolean {
  let $pregnancyObservations := 
    for $observation in $root/c:component/c:structuredBody/c:component/c:section[c:code[@code='29762-2']][1]//
            c:entry/c:observation[c:templateId[@root='2.16.840.1.113883.10.20.15.3.8']]
      let $estimatedDeliveryTime := p2t:parse-date-time(
            $observation/c:entryRelationship/c:observation[c:templateId[@root='2.16.840.1.113883.10.20.15.3.1']]/c:value/@value),
          $currentTime := current-dateTime()
      where exists($estimatedDeliveryTime) and $estimatedDeliveryTime ge $currentTime
      return true()
   return exists($pregnancyObservations)
};

(:~
: Returns the most recent observation element for a given vital sign 
:
: NOTE: $estimatedDeliveryTime is an optional value in the CCDA. Erring on the side of creating false positives by only returning true 
:    if the delivery time is present and in the future
: @param $code the code defining the vital sign observation
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @return The most recent observation element.
:)
declare function p2t:last-vital-sign($code as xs:string, $root as element(c:ClinicalDocument)) as xs:decimal? {
  let $ordered := for $observation in $root/c:component/c:structuredBody/c:component/c:section[c:code[@code='8716-3']][1]//
        c:entry/c:organizer/c:component/c:observation[c:code[@code=$code]]
    order by $observation/c:effectiveTime/@value descending
    return xs:decimal($observation/c:value/@value)
  return $ordered[1]
};

(:~
: Returns the most recent observation element of the patient's weight measurement  
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @return The most recent observation element.
:)
declare function p2t:last-weight-measured($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-vital-sign('3141-9', $root)
};

(:~
: Returns the most recent observation element of the patient's systolic bp  
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @return The most recent observation element.
:)
declare function p2t:last-systolic($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-vital-sign('8480-6', $root)
};

(:~
: Returns the most recent observation element of the patient's diastolic bp  
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @return The most recent observation element.
:)
declare function p2t:last-diastolic($root as element(c:ClinicalDocument)) as xs:decimal? {
  p2t:last-vital-sign('8462-4', $root)
};

(:~
: Returns true if a patients most recent blood pressure readings are lower than the given values  
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $maxSystolic the maximum allowed value for systolic bp
: @param $maxDiastolic the maximum allowed value for diastolic bp
: @return xs:boolean
:)
declare function p2t:blood-pressure-lower-than($root as element(c:ClinicalDocument), $maxSystolic as xs:decimal, $maxDiastolic as xs:decimal) as xs:boolean? {
  let $lastSystolic := p2t:last-systolic($root),
    $lastDiastolic := p2t:last-diastolic($root)
  return if (empty($lastSystolic) or empty($lastDiastolic)) then () else $lastSystolic le $maxSystolic and $lastDiastolic le $maxDiastolic
};

(:~
: Returns all of the BMI observations from the CCD  
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @return The set of BMI observation elements.
:)
declare function p2t:bmi-observations($root as element(c:ClinicalDocument)) as item()* {
  $root/c:component/c:structuredBody/c:component/c:section[c:templateId[@root='2.16.840.1.113883.10.20.22.2.4.1']][1]//
      c:entry/c:organizer/c:component/c:observation[c:code[@code='39156-5']]
};


(:~
: Returns the average value of all of the BMI observations from the CCD  
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @return The average value
:)
declare function p2t:avg-bmi($root as element(c:ClinicalDocument)) as xs:decimal {
  fn:avg(
    for $observation in p2t:bmi-observations($root)
    return xs:decimal($observation/c:value/@value))
};


(:~
: Returns the most recent value of a BMI observation from the CCD  
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @return The most recent value
:)
declare function p2t:last-bmi($root as element(c:ClinicalDocument)) as xs:decimal? {
  let $ordered :=
    for $observation in p2t:bmi-observations($root)
      order by $observation/c:effectiveTime/@value descending
      return $observation/c:value/@value
  return xs:decimal($ordered[1])
};

(:~
: Returns true if the CCD's most recent value of BMI observation is within the given range  
:
: @param $root The root element (c:ClinicalDocument) of a CCD.
: @param $bmiMin
: @param $bmiMax
: @return xs:boolean
:)
declare function p2t:bmi-in-range($root as element(c:ClinicalDocument), $bmiMin as xs:decimal, $bmiMax as xs:decimal) as xs:boolean {
  let $bmi := p2t:last-bmi($root)
  return if (empty($bmi)) then true() else $bmi ge $bmiMin and $bmi le $bmiMax
};