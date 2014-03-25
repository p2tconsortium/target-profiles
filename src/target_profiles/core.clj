(ns target-profiles.core
  (:require [saxon :as xml])
  (:use [clojure.java.io :only [resource]]))

(defn run-query [tp file] (xml/query (str tp "\n" "local:match-result(/c:ClinicalDocument)") {:c "urn:hl7-org:v3"} (xml/compile-xml file)))
