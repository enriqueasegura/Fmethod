%This function measures the experimental
%laser transport matrix used to determine
%the appropiate corrections to effectively move
%a misaligned beam to its target position. 
%The system we are working on rely on pico-motors which
%are prone to latch back (hysteresis). 
%Thus, we measured this matrix by deliberating target the center
%More about hysteresis can be found here:
%https://en.wikipedia.org/wiki/Hysteresis
%In our system the Y-direction in the cameras are flipped
%which is why for the X-direction we are measuring the positive 
%direction from left to right (positive x vector)
%but in Y-direction we measure it as the standard positive y vector. 
%Hence, why the measurements in Y-direction are negative. 
%This matrix has been tested against the experimental model
%and has a 1:1 relation between theory and experiment on its
%diagonal entries.

%arguments returned:
%cm: the callibration matrix
%hm: measuring the difference at the end of each set of motions 

%Something to keep in mind: this system is non-reversible. 
%which is why this callibration is so important.
%Without an accurate measurement of this system, 
%experiment will be prone to wrong error corrections.

%variable_distance: a given step size (revolution) to each engine
%to extract the pixel difference per revolution.
%This was done to determine whether latchback was dependant on stepsize. 
%It was not.

function [cm, hm] = facet_callibration(variable_distance_vector)

%This is the chosen arbitrary at target position for the beam to be at all
%times in both cameras. 
pos_i_want = [646; 425; 646; 425];

%This is an alignment function that does not show all diagnostics
facet_align(pos_i_want, 0.50, .0, 0, 1, 'no', 'no');

%data structures to hold output of measuremennt process.
c_m = ones(4,4);
hm = ones(4,4);

disp('loc before starting (must be aligned!):')

% profmon_grab(PV_ADDRESS);
% This function is a matlab command that
% interacts with the CCD camera given by
% The PV_ADDRESS. 
% It extracts an image array 

% centroid_pixels(c1,c2)
% This function executes a projection of the camera data
% to find the centroid position
% and implements a gaussian fitting to reduce noise effects 
% on the centroid. 

c1 = profmon_grab('EXPT:LI20:3309');
c2 = profmon_grab('EXPT:LI20:3310');
disp(centroid_pixels(c1,c2))


%each engine represents the degrees of freedom for each mirror
%For mirror 1: engine-1: 1X, engine-2: 1Y.
%For mirror 2, same engine values respectively. 

%The order of callibration is axis-wise
%First callinbration measurements are done for Engines 1X, 1Y, then 2X, 2Y 
%The final matrix, the callibration matrix (c_m)
%is represented by: 
% [ engine-1x callibration;
%   engine-1y callibration;
%   engine-2x callibration;
%   engine-2y callibration];
for engine=1:4
    if engine == 1 || engine == 3
        
        motor_str = strcat('MOTR:B244:MC01:M0:CH',int2str(engine),':MOTOR');
        
        pause(2)
        
        c1_s = profmon_grab('EXPT:LI20:3309');
        c2_s = profmon_grab('EXPT:LI20:3310');
        initial_p= centroid_pixels(c1_s,c2_s);
        
        %This is a MATLAB function that takes the address of the motor
        % and adds the revolution steps size to move
        %Followed by a second command, 'PV_ADDRESS.TWF', which moves the 
        %motor by the request revolutions. 
        
        lcaPutSmart(strcat(motor_str,'.TWV'),-variable_distance_vector(engine,1))
        lcaPutSmart(strcat(motor_str,'.TWF'),-variable_distance_vector(engine,1))
        disp('warm up run!!')  
        
        motor_status = lcaGetSmart(strcat(motor_str,'.MSTA'));
        
        %This is a loop that checks whether the motor is still moving using
        %This is done in order to prevent one motor to overstep on the
        %motion of another, which effectively would disrupt the
        %callibration process
        
        while((motor_status ~= 2))
            motor_status= lcaGetSmart(strcat(motor_str,'.MSTA'));
        end
        %%%%%%
        lcaPutSmart(strcat(motor_str,'.TWV'), 10 - variable_distance_vector(engine,1)/2)%
        lcaPutSmart(strcat(motor_str,'.TWF'),10 - variable_distance_vector(engine,1)/2)
        disp('warm up run!!')
        
        motor_status = lcaGetSmart(strcat(motor_str,'.MSTA'));
        
        while((motor_status ~= 2))
            motor_status= lcaGetSmart(strcat(motor_str,'.MSTA'));
        end
        %%%%%%

        %move that you want to capture!
        pause(2)
        
        cam2=profmon_grab('EXPT:LI20:3309');
        cam1= profmon_grab('EXPT:LI20:3310');
        
        disp('start point')
        before_move =centroid_pixels(cam1,cam2);
        disp(before_move)
        
        lcaPutSmart(strcat(motor_str,'.TWV'),variable_distance_vector(engine,1))%
        lcaPutSmart(strcat(motor_str,'.TWF'),variable_distance_vector(engine,1))
        
        motor_status = lcaGetSmart(strcat(motor_str,'.MSTA'));
        
        while((motor_status ~= 2))
            motor_status= lcaGetSmart(strcat(motor_str,'.MSTA'));
        end
        
        pause(2)
        
        cam2_after = profmon_grab('EXPT:LI20:3309');
        cam1_after = profmon_grab('EXPT:LI20:3310');
        
        
        after_move = centroid_pixels(cam1_after,cam2_after);
        
        diff = after_move - before_move;
        disp(strcat('engine: ', int2str(engine),' X:'))
        disp(diff)
        c_m(:,engine) = diff/variable_distance_vector(engine,1);
        
        %go back to the initial position
        lcaPutSmart(strcat(motor_str,'.TWV'),-variable_distance_vector(engine,1)/2)%
        lcaPutSmart(strcat(motor_str,'.TWF'),-variable_distance_vector(engine,1)/2)
        
        motor_status = lcaGetSmart(strcat(motor_str,'.MSTA'));
        
        while((motor_status ~= 2))
            motor_status= lcaGetSmart(strcat(motor_str,'.MSTA'));
        end
        
        pause(2)
        c1_f = profmon_grab('EXPT:LI20:3309');
        c2_f = profmon_grab('EXPT:LI20:3310');
        final_p= centroid_pixels(c1_f,c2_f);
        
        diff_h = final_p - initial_p;
        hm(:,engine) = diff_h;
    end
    
    facet_align(pos_i_want, 0.50, .0, 0, 1, 'no', 'no');
    
    if engine == 2 || engine == 4
        
        motor_str = strcat('MOTR:B244:MC01:M0:CH',int2str(engine),':MOTOR');
        
        pause(2)
        c1_s = profmon_grab('EXPT:LI20:3309');
        c2_s = profmon_grab('EXPT:LI20:3310');
        initial_p= centroid_pixels(c1_s,c2_s);
        
        lcaPutSmart(strcat(motor_str,'.TWV'),-variable_distance_vector(engine,1))
        lcaPutSmart(strcat(motor_str,'.TWF'),-variable_distance_vector(engine,1))
        disp('warm up run!!')
        
        motor_status = lcaGetSmart(strcat(motor_str,'.MSTA'));
        
        %This is a loop that checks whether the motor is still moving using
        %This is done in order to prevent one motor to overstep on the
        %motion of another, which effectively would disrupt the
        %callibration process
        
        while((motor_status ~= 2))
            motor_status= lcaGetSmart(strcat(motor_str,'.MSTA'));
        end
        
        %%%%%%
        lcaPutSmart(strcat(motor_str,'.TWV'), 10 -variable_distance_vector(engine,1)/2)
        lcaPutSmart(strcat(motor_str,'.TWF'),10 - variable_distance_vector(engine,1)/2)
        disp('warm up run!!')
        
        motor_status = lcaGetSmart(strcat(motor_str,'.MSTA'));
        
        while((motor_status ~= 2))
            motor_status= lcaGetSmart(strcat(motor_str,'.MSTA'));
        end
        %%%%%%
        
        pause(2)
        %move that  you want to capture!
        cam2=profmon_grab('EXPT:LI20:3309');
        cam1= profmon_grab('EXPT:LI20:3310');
        
        disp('start point')
        
        before_move =centroid_pixels(cam1,cam2);
        disp(before_move)
        
        lcaPutSmart(strcat(motor_str,'.TWV'),variable_distance_vector(engine,1))
        lcaPutSmart(strcat(motor_str,'.TWF'),variable_distance_vector(engine,1))
        
        motor_status = lcaGetSmart(strcat(motor_str,'.MSTA'));
        
        while((motor_status ~= 2))
            motor_status= lcaGetSmart(strcat(motor_str,'.MSTA'));
        end
        
        pause(2)
        cam2_after = profmon_grab('EXPT:LI20:3309');
        cam1_after = profmon_grab('EXPT:LI20:3310');
        
        after_move = centroid_pixels(cam1_after,cam2_after);
        
        diff = after_move - before_move;
        disp(strcat('engine: ', int2str(engine),' Y:'))
        disp(diff)
        c_m(:,engine) = diffvariable_distance_vector(engine,1);
        
        %go back to the initial position
        lcaPutSmart(strcat(motor_str,'.TWV'),-variable_distance_vector(engine,1)/2)
        lcaPutSmart(strcat(motor_str,'.TWF'),-variable_distance_vector(engine,1)/2)
        
        motor_status = lcaGetSmart(strcat(motor_str,'.MSTA'));
        
        while((motor_status ~= 2))
            motor_status= lcaGetSmart(strcat(motor_str,'.MSTA'));
        end
        
        pause(2)
        c1_f = profmon_grab('EXPT:LI20:3309');
        c2_f = profmon_grab('EXPT:LI20:3310');
        final_p= centroid_pixels(c1_f,c2_f);
        
        diff_h = final_p - initial_p;
        hm(:,engine) = diff_h;
    end
    
    facet_align(pos_i_want, 0.50, .0, 0, 1, 'no', 'no');
end
cm = c_m;
disp('c_m: (Measured Callibration Matrix for Laser Transport) (pix per revolution)')
disp(cm)
calidata_name = ['/u1/facet/matlab/data/2018/data_dump/newcalidata', datestr(now, 'mm-dd-yy HH-MM-SS'), '.csv'];
csvwrite(calidata_name, cm);
end