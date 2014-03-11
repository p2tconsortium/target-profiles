Lilly-target-profiles
======================

Collaboration on creating and testing XQuery-based target profiles to run against CCDA documents. This respository is meant to capture work and documentation on the implementation and challenges on creating Target Profiles against CCDA documents. 


p2tconsortium
=============

https://sites.google.com/site/p2tconsortium/

Developing new treatments for diseases depends on clinical research studies, but studies often struggle to recruit patients. According to Centerwatch, 94% of people recognize the importance of participating in clinical research in order to assist in the advancement of medical science. Yet 75% of the general public state they have little to no knowledge about the clinical research enterprise and the participation process. As a consequence, almost half of all trials never reach their recruitment targets. To address this problem Lilly, Novartis, and Pfizer, are partnering in the US to provide a new platform to improve access to information about clinical trials for patients and providers. At the heart of the project is the goal is to enable patients to find, understand and “match” to clinical studies that meet their needs.

## About This Repository

This project is a place to demonstrate a library of XQuery functions.

The library is found in the file:

```
/resources/library.xq
```

To show how the target profile can be constructed, leveraging the
functions declared in the XQuery library, the project utilizes unit
tests written for the
[Clojure programming language](http://www.clojure.org).

An example target profile that the tests will utilize is found in:

```
/resources/lmrb.xq
```


### Getting started with the unit tests

1) Clone this github repo:
 ```
 $ git clone git@github.com:p2tconsortium/Lilly-target-profiles.git
 ```
2) We have forked
 [the sample_ccdas repository from Boston Children's Hospital](https://github.com/chb/sample_ccdas)
 and are including that fork as a git submodule. After cloning the
 Lilly-target-profiles project, you will need to execute the following
 commands as well:

 ```
 $ cd Lilly-target-profiles
 $ git submodule init
 $ git submodule update
 ```
3) We leverage the
[popular build tool, Leiningen](https://github.com/technomancy/leiningen)
to manage dependencies and run the tests. Follow the
[Installation instructions](https://github.com/technomancy/leiningen#installation)

4) Execute the tests! You should see a result similar to:

 ```
 $ lein midje :autotest

 ======================================================================
 Loading (lilly-target-profiles.core lilly-target-profiles.core-test)
 All checks (41) succeeded.
 [Completed at 16:02:11]

 ```
