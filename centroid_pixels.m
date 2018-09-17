%This function takes the input each of each camera
%projects the image data, creates the distribution 
%which is fitted on a gaussian distribution
%to reduce the effects on noise in the image.
%The resulting fitted max is the centroid's position
%which is used to generate corrections for beam alignment.

function [beamvec] = centroid_pixels(cam1, cam2)

cam1_inty = zeros(1,(cam1.nRow));
cam1_intx = zeros(1,(cam1.nCol));
cam2_inty = zeros(1,(cam2.nRow));
cam2_intx = zeros(1,(cam2.nCol));

pix_1x = zeros(1,(cam1.nCol));
pix_1y = zeros(1,(cam1.nRow));
pix_2x = zeros(1,(cam2.nCol));
pix_2y = zeros(1,(cam2.nRow));

for i=1:cam1.nRow
   cam1_inty(i)=sum(cam1.img(i,:));
   pix_1y(i) = i; 
end

for j=1:cam1.nCol
    cam1_intx(j)=sum(cam1.img(:,j));
    pix_1x(j) = j; 
end

for i=1:cam2.nRow
   cam2_inty(i)=sum(cam2.img(i,:));
   pix_2y(i) = i;
end

for j=1:cam2.nCol
    cam2_intx(j)=sum(cam2.img(:,j));
    pix_2x(j) = j; 
end

[cam1xmax, indx1]= max(cam1_intx);
[cam1ymax, indy1]=max(cam1_inty);
[cam2xmax, indx2]= max(cam2_intx);
[cam2ymax, indy2]=max(cam2_inty);

[cam1xfit, Q1x] = gauss_fit(pix_1x,cam1_intx/cam1xmax);
[cam1yfit, Q1y] = gauss_fit(pix_1y,cam1_inty/cam1ymax);
[cam2xfit, Q2x] = gauss_fit(pix_2x,cam2_intx/cam2xmax);
[cam2yfit, Q2y] = gauss_fit(pix_2y,cam2_inty/cam2ymax);

x1 = Q1x(1,3);
y1 = Q1y(1,3);
x2 = Q2x(1,3);
y2 = Q2y(1,3);
beamvec=[x1,y1,x2,y2];
