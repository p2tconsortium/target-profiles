(ns lilly-target-profiles.core
  (:require [saxon :as xml])
  (:use [clojure.java.io :only [resource]]))

(def _library (atom (slurp (resource "library.xq"))))

(defn reload-library []
  (reset! _library (slurp (resource "library.xq"))))

(defn run-query [tp q file] (xml/query (str @_library tp "\n" q) {:c "urn:hl7-org:v3"} (xml/compile-xml file)))
