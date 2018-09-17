# Fmethod: The FACET-II Beam Stabilization Algorithm
This is a beam stabilization algorithm implemented to mitigate the effects of slow drift on the FACET-II laser transport. 

We have accomplished this by simulating the FACET-II beamline using ZEMAX, https://en.wikipedia.org/wiki/Zemax, testing a first-principle model of laser transport using Lasers by Siegman.

https://www.osapublishing.org/books/bookshelf/lasers.cfm. 

From that simulation results, we have built a two-mirror-two-camera system to test the effectiveness of this method. 

Here's the resulting code. This code is a PID-controller using that method - a 12x12 matrix for the final system, a 4x4 for this current system. 

This controller was implemented using SLAC's code base http://www.slac.stanford.edu/grp/lcls/controls/systems/xray_transport/EPICS%20Manuals/Motor%20Record.pdf to interact and control cameras and pico-motors present on the transport.

A more complete documentation can be found here: 

http://www.slac.stanford.edu/grp/lcls/controls/systems/xray_transport/

Currently working on: 

1. Improving tuning parameters. 
2. Improving code's efficiency with respect to noise present in experiment. 
3. Adding safeguards to enhance the robustness of the algorithm. 
4. Implementing this algorithm on the FACET-II beamline to test its effectiveness on the intended experimental setup.

For Simulations, we relied on ZEMAX's python API libraries, and MATLAB to design, implement, and optimize the controller. 



