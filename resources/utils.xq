(:~
: This module contains utility functions for parsing CCDs.
:
: @author Jesse Clark && LillyCOI development team
: @version 0.2
:)
module namespace p2t = "https://consortium-data.lillycoi.com/target-profiles";

declare function p2t:parse-date-time($dt as xs:string) as xs:dateTime {
  let $YYYY := fn:substring($dt, 0, 5),
      $MM := fn:substring($dt, 5, 2),
      $DD := fn:substring($dt, 7, 2),
      $hh := if ( not(fn:substring($dt, 9, 2))) then "00" else fn:substring($dt, 9, 2),
      $mm := if ( not(fn:substring($dt, 11, 2))) then "00" else fn:substring($dt, 11, 2),
      $ss := if ( not(fn:substring($dt, 13, 2))) then "00" else fn:substring($dt, 13, 2)
  return dateTime(xs:date(fn:concat($YYYY, '-', $MM, '-', $DD)),
                          xs:time(fn:concat($hh, ':', $mm, ':', $ss)))
};

