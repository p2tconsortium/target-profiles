(defproject lilly-target-profiles "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.5.1"]
                 [org.clojure/data.xml "0.0.7"]
                 [clojure-saxon "0.9.3"]]
  :profiles {:dev {:dependencies [[midje "1.6.2"]
                                  [midje-junit-formatter "0.1.0-SNAPSHOT"]
                                  [org.clojars.runa/conjure "2.2.0"]]
                   :plugins [[lein-midje "3.1.3"]]
                   :resource-paths ["sample_ccdas/EMERGE"]}}  )
