# Fmethod: The FACET-II Beam Stabilization Algorithm

This is a beam stabilization algorithm implemented to mitigate the effects of slow drift on the FACET-II laser transport. 

https://facet.slac.stanford.edu

We have accomplished this by simulating the FACET-II beamline using ZEMAX, https://en.wikipedia.org/wiki/Zemax, testing a first-principle model of laser transport implemented using Lasers by Siegman as well as research papers on Ray Tracing Optics:

https://www.osapublishing.org/books/bookshelf/lasers.cfm

https://link.springer.com/article/10.1007/BF00619988

https://www.osapublishing.org/josaa/abstract.cfm?uri=josaa-11-10-2633)


For Simulations, we rely ZEMAX's python API libraries, and MATLAB to design, implement, and optimize the controller. From these results, we have built a two-mirror-two-camera system to test the effectiveness of this method against experimental data.  In order to this, a PID-controller was implemented.

An introduction to the fundamentals of a PID controller: 

https://en.wikipedia.org/wiki/PID_controller#Integral_term

# More documentation can be found here: 

The bread and butter of experimental physics software at SLAC: https://en.wikipedia.org/wiki/EPICS
A Python library to get started with the nuts and bolts of EPICS: 

https://www.slac.stanford.edu/grp/ssrl/spear/epics/extensions/pyepics/pyepics.pdf

MATLAB Programmer’s Guide for FACET physicists: 

https://portal.slac.stanford.edu/sites/ard_public/facet/faq/Documents/programming_guide_matlab_facet.pdf 

This controller was implemented using SLAC's code base to interact and control cameras and pico-motors present on the transport: 

http://www.slac.stanford.edu/grp/lcls/controls/systems/xray_transport/EPICS%20Manuals/Motor%20Record.pdf
http://www.slac.stanford.edu/grp/lcls/controls/systems/xray_transport/

# Currently working on: 

1. Improving tuning parameters. 
2. Improving code's efficiency with respect to noise present in experiment. 
3. Adding safeguards to enhance the robustness of the algorithm. 
4. Implementing this algorithm on the FACET-II beamline to test its effectiveness on the intended experimental setup.

#Still on the list before end of fellowship: 

The current system experiences severe coupling issues. Currently working on adding decoupling capabilities to the algorithm. It still aligns and keeps the beam on a given target position but it does so by following a parabolic trajectory rather than a linear trajectory.





