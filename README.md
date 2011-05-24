# Fantomex

![](https://img.skitch.com/20110524-q4xde31yer216586t3ujumy9hy.png)

Fantomex was created by the Weapon Plus Program to serve as a super-sentinel against Earth's mutant population. Through experimentation with human-machine hybridization, Weapon Plus created a population of technorganic organisms whose living tissue was fused with Sentinel nanotechnology at the cellular level.

## Intro

Fantomex is a lib for storing a relatively small number of background jobs in
a persistent queue.  It's designed as a way for a single ZeroMQ worker to store
incoming messages in case of a crash.  If Fantomex is tracking 10,000
jobs, you should probably look into fixing your workers or adding more
to handle the load.

A lot of inspiration came from the design of Resque and Delayed Job, but
there are a few key features that Fantomex needs.

* Use isolated databases scoped to the worker, not central databases
  like Redis or MySQL.
* Allow the requeueing of errored jobs.  Fantomex jobs should *always*
  be run.

