= javascript boids is a programmers toy
==  it uses coffeescript and html5 canvas to implement the boids alogrithm

I plan to tinker with the code enough to produce an implementation that would be worth distributing a single js file from it as a jquery plugin.

Please feel free to reuse and redistribute under terms of the apache license.

Its original purpose was for me to learn coffee script, and it filled that purpose.   Next up, I'll add backbone or meteor into this and get the full one page app experience going.

see it in action http://boids.herokuapp.com

== status and a few TODOs

it has unit tests and passes them.

the boids really do flock.

the ui is no longer horribly ugly, but not completed, and some parts are unexplained, unintuitive, or broken.  

goal seeking behavior is not implemented.

boids avoid each other but there is no support for obstacles.

It should have the ability to fill the viewport dynamically and add boids to reach a certain density per pixel.

It should be easy to use, with sane defaults for 

    $("#foo").flock()

