(:~
: This is the master module for all functionality related to matching against CCDs.
: This library imports sub-modules for handling specific sections of the CCD.
:
: - vitals.xq: Functionality related to vital signs observations
: - labs.xq: Functionality related to lab results observations
: - medications.xq: Functionality related to substance administration observations
: - problems.xq: Functionality related to problem observations
: - procedures.xq: Functionality related to procedure observations
: - functional_status.xq: Functionality related to status assessment observations
:
: @author Jesse Clark
: @version 0.2
:)
module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";
declare namespace c = 'urn:hl7-org:v3';
import module namespace functx = "http://www.functx.com" at "https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq";
import module "https://consortium-data.lillycoi.com/target-profiles" at "https://raw.github.com/Corengi/target-profiles/master/resources/vitals.xq", "https://raw.github.com/Corengi/target-profiles/master/resources/labs.xq", "https://raw.github.com/Corengi/target-profiles/master/resources/medications.xq", "https://raw.github.com/Corengi/target-profiles/master/resources/problems.xq", "https://raw.github.com/Corengi/target-profiles/master/resources/procedures.xq", "https://raw.github.com/Corengi/target-profiles/master/resources/functional_status.xq";

