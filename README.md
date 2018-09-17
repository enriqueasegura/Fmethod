# Fmethod
This is a beam stabilization algorithm implemented to mitigate the effects of slow drift on the FACET-II laser transport. 

We have accomplished this by simulating the FACET-II beamline using ZEMAX, testing a first-principle model of laser transport using Lasers by Siegman. 

From that simulation results, we have built a two-mirror-two-camera system to test the effectiveness of this method. 

Here's the resulting code. This code is a PID-controller using that method - a 12x12 matrix for the final system, a 4x4 for this current system. 


