(:~
: This module contains variable declarations of assessment scale codes for use in criteria containing
: the results of functional assessments.
: @see functional_status.xq
: @author Jesse Clark
: @version 0.1
:)
module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";

declare variable $p2t:EDSS as xs:string* := ('273554001'); (: Does not have a LOINC code :)