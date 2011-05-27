# Fantomex

![](https://img.skitch.com/20110524-q4xde31yer216586t3ujumy9hy.png)

Fantomex was created by the Weapon Plus Program to serve as a super-sentinel
against Earth's mutant population. He was born in the World, a secret square
mile of experimental micro-reality built by the military industrial complex.
The Weapon Plus scientists heated up time itself until it flowed in all
directions at once. Into this pliant, fast-moving substance, they introduced
human test groups, whose genetic material was crudely spliced with adaptive
Nano-Sentinel technology, and ran the result through half a million years of
cyborg mutation in eighteen months.

## Intro

Fantomex is a lib for storing a relatively small number of background jobs in
a persistent queue.  It's designed as a way for a single Redis pub/sub or
ZeroMQ worker to store incoming messages in case of a crash.  If Fantomex is
tracking 10,000 jobs, you should probably look into fixing your workers or
adding more to handle the load.

A lot of inspiration came from the design of Resque and Delayed Job, but
there are a few key features that Fantomex needs.

* Use isolated databases scoped to the worker, not central databases
  like Redis or MySQL.  Prefer sqlite, kyoto cabinet, leveldb, etc.
* Allow the requeueing of errored jobs.  Fantomex jobs should *always*
  be run.
* Errored jobs are re-queued to be run after a delay (with exponential
  backoff).

## Usage

First, you'll want to create a Fantomex instance with a sqlite backend.

    var fantomex = require('fantomex')

    // defaults to `process.cwd() + "/queue.db"`
    var store = fantomex.sqlite("/path/to/queue.db")

Add an event listener to handle Fantomex messages (in case the worker is
restarting after a crash and there is a backlog).

    // Emits the message that was received.  Whatever happens, Fantomex
    // should either remove the message or requeue it, so it can 
    store.on("message", function(msg, next) {
      try {
        // do it for the logs
        console.time("message")
        doSomethingTo(msg)
        next() // all done!
      } catch(e) {
        console.log("Error:")
        console.log(e)
        next(e) // track the error
      } finally {
        console.timeEnd("message")
      }
    })

Next, add items to the queue as they come in from ZeroMQ (or wherever).

    // this could be a ZeroMQ socket, or some other clever lib that
    // emits messages.  Doesn't realprocess.cwd()ly matter to Fantomex.
    queue.on("message", function(msg) {
      store.push(msg) // calls toString()
    })

## TODO

* Investigate other databases (Kyoto Cabinet, LevelDB, Redis, etc).
* Investigate abstract SQL interface so sqlite support means
  mysql/postgres also work.

## Status

Alpha.

