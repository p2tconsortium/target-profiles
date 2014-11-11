import module namespace p2t = 'https://consortium-data.lillycoi.com/target-profiles' at 'https://raw.github.com/Corengi/target-profiles/master/resources/library_novartis.xq';
import module namespace functx = 'http://www.functx.com' at 'https://raw.github.com/Corengi/target-profiles/master/resources/functx.xq';

declare namespace c = 'urn:hl7-org:v3';

(: NCT01598987_RAD001H2305.docx :)

declare function local:match-result($root as element(c:ClinicalDocument)) as xs:boolean {
    let $age := p2t:age-in-years($root),
      $isOfAge := $age ge 0 and $age le 17
    return $isOfAge 
        and (
            (
                p2t:has-problem($root, $p2t:cholestatis)
                and p2t:has-problem($root, $p2t:portal-hypertension)
                and p2t:has-problem($root, $p2t:cholangitis)
                and p2t:has-problem($root, $p2t:ascites)
                and p2t:has-problem($root, $p2t:encephalopathy)
            ) or (
                (
                    p2t:has-problem($root, $p2t:cholestatis) 
                    or p2t:has-problem($root, $p2t:portal-hypertension)
                    or p2t:has-problem($root, $p2t:cholangitis)
                    or p2t:has-problem($root, $p2t:cholangitis)
                    or p2t:has-problem($root, $p2t:ascites)
                    or p2t:has-problem($root, $p2t:encephalopathy)
                )
                and p2t:has-problem($root, $p2t:awating-organ-transplant-diagnosis)
            ) or (
                p2t:has-procedure($root, $p2t:awating-organ-transplant-procedure)
            )
        )
        and not( p2t:has-problem( $root, ($p2t:acute-rejection-of-organ-transplant, $p2t:liver-tumors, $p2t:hepatitis-fulminant, $p2t:hepatic-vein-thrombosis) ) )
};


