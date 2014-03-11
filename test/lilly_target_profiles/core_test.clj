(ns lilly-target-profiles.core-test
  (:require [clojure.test :refer :all]
            [lilly-target-profiles.core :refer :all]
            [saxon :as xml])
  (:use [clojure.java.io :only [resource]]
        [conjure.core :only [stubbing]]
        [midje.sweet]
        ))

(reload-library)

(fact "ensure sample_ccdas available"
       (let [ccda (resource "Patient-409.xml")]
         (nil? ccda) => false))

(fact "ensure lmrb profile"
      (nil? (resource "lmrb.xq")) => false)

(defn lmrb-match [f expected]
  (let [ccda (resource f)
        lmrb (slurp (resource "lmrb.xq"))]
    (fact (str "Assert " expected " LMRB match for " f)
          (run-query lmrb "local:lmrb(/c:ClinicalDocument)" ccda) => expected)))



(lmrb-match "Patient-129.xml" true)
(lmrb-match "Patient-143.xml" true)
(lmrb-match "Patient-181.xml" true)
(lmrb-match "Patient-209.xml" true)
(lmrb-match "Patient-229.xml" true)
(lmrb-match "Patient-255.xml" true)
(lmrb-match "Patient-258.xml" true)
(lmrb-match "Patient-263.xml" true)
(lmrb-match "Patient-357.xml" true)
(lmrb-match "Patient-372.xml" true)
(lmrb-match "Patient-398.xml" true)
(lmrb-match "Patient-404.xml" true)
(lmrb-match "Patient-409.xml" true)
(lmrb-match "Patient-498.xml" true)
(lmrb-match "Patient-513.xml" true)
(lmrb-match "Patient-517.xml" true)
(lmrb-match "Patient-557.xml" true)
(lmrb-match "Patient-84.xml" true)
(lmrb-match "Patient-90.xml" true)

(lmrb-match "Patient-128.xml" false)
(lmrb-match "Patient-142.xml" false)
(lmrb-match "Patient-180.xml" false)
(lmrb-match "Patient-208.xml" false)
(lmrb-match "Patient-228.xml" false)
(lmrb-match "Patient-254.xml" false)
(lmrb-match "Patient-257.xml" false)
(lmrb-match "Patient-262.xml" false)
(lmrb-match "Patient-356.xml" false)
(lmrb-match "Patient-371.xml" false)
(lmrb-match "Patient-397.xml" false)
(lmrb-match "Patient-403.xml" false)
(lmrb-match "Patient-407.xml" false)
(lmrb-match "Patient-410.xml" false)
(lmrb-match "Patient-499.xml" false)
(lmrb-match "Patient-512.xml" false)
(lmrb-match "Patient-516.xml" false)
(lmrb-match "Patient-556.xml" false)
(lmrb-match "Patient-83.xml" false)
(lmrb-match "Patient-91.xml" false)
