% ==========
% Theoretical Fmethod response matrix (with no rotations or angle-orientations) 
% 
% [[1550.000000 0.000000 750.000000 0.000000]
%  [0.000000 1550.000000 0.000000 750.000000]
%  [2700.000000 0.000000 1900.000000 0.000000]
%  [0.000000 2700.000000 0.000000 1900.000000]]
%
% The cam matrix for this system is: 
% 
% [[297.820000 10.188000 145.560000 -6.109500]
%  [6.456900 -218.970000 2.376800 -109.560000]
%  [574.870000 12.515000 427.560000 -7.836500]
%  [8.524900 -423.290000 2.991200 -314.130000]]
% 
%This matrix is in pixels only.
% 
% The missing component to establish a relationship between an experimental response matrix and 
% the theoretical method is from a missing component: the contributions of a mirror orientation
%
% Ratios between experimental response matrix and fmethod (this needs to be converted into radians by taking the arc cos of this matrix)
% 
% [[0.500031 -inf 0.518376 inf]
%  [inf 0.500017 inf 0.531044]
%  [0.460966 -inf 0.500030 inf]
%  [inf 0.461630 inf 0.500016]]
% =====
% Relative orientation of each mirror according to fmethod (taking the arc cos of the previous matrix and converting to degrees)
% 
% [[59.997925 nan 58.776615 nan]
%  [nan 59.998878 nan 57.923965]
%  [62.550520 nan 59.998030 nan]
%  [nan 62.507643 nan 59.998937]]
% 
% This means that indeed, the response matrix needs to be transposed, as observed on F-method, mirror-1
%  elements (the first two columns) are the dominant terms of the matrix.
% 
% 
% =====
% 
% This is the ratio between the experimental response matrix  and the fmethod theoretical matrix adjusted
%  by the relative orientation angles: 
% 
% [[0.999999 -inf 1.036690 inf]
%  [inf 1.000000 inf 1.062054]
%  [0.921874 -inf 1.000000 inf]
%  [inf 0.923229 inf 1.000000]]
% 
% And finally, using this data, the angles on the diagonal elements, we obtain the following theoretical
%  matrix: 
% 
% fmethod:
% [[775.049064 0.000000 375.022441 0.000000]
%  [0.000000 775.026244 0.000000 375.012049]
%  [1350.085466 0.000000 950.056852 0.000000]
%  [0.000000 1350.045716 0.000000 950.030525]]
% 
% which compares to the experimental response matrix adjusted by the pixel to um factors to: 
% 
% camfmethod
% [[775.048618 -36.059587 388.782058 22.209848]
%  [16.803477 775.026283 6.348291 398.283159]
%  [1244.609081 -36.851138 950.056577 23.700106]
%  [18.456639 1246.401761 6.646574 950.030540]]
% 
% With, reiterating again, the following ratio:
% 
% [[0.999999 -inf 1.036690 inf]
%  [inf 1.000000 inf 1.062054]
%  [0.921874 -inf 1.000000 inf]
%  [inf 0.923229 inf 1.000000]]
% 
% This validates the theoretical method developed and how it stacks up to the experimental system.
