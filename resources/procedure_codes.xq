(:~
: This module contains variable declarations for procedure codes for use in criteria.
: @see procedures.xq
: @author Jesse Clark
: @version 0.1
:)
module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";

declare variable $p2t:dialysis as xs:string* := ('90935');
declare variable $p2t:heart-transplant as xs:string* := ('32413006');
declare variable $p2t:awating-organ-transplant-procedure as xs:string* := ('698305006');
