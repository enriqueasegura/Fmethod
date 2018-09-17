function [cm, hm] = new_callibration()

%This is the chosen arbitrary at target position for the beam to be at all
%times in both cameras. 
pos_i_want = [646; 425; 646; 425];

%This is an alignment function that does not show all diagnostics
facet_control(pos_i_want, 0.25, .54/7);

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
disp(centroid_pixels(c1,c2)')


%each engine represents the degrees of freedom for eacgh mirror
%For mirror 1: engine-1: 1X, engine-2: 1Y.
%For mirror 2, same engine values respectively. 

%The order of callibration is axis-wise
%First callinbration measurements are done for Engines 1X, 2X, then 1Y, 2Y 
%The final matrix, the callibration matrix (c_m)
%is represented by: 
% [ engine-1x callibration;
%   engine-1y callibration;
%   engine-2x callibration;
%   engine-2y callibration];
for engine=1:4
    if engine == 1
        
        c1_s = profmon_grab('EXPT:LI20:3309');
        c2_s = profmon_grab('EXPT:LI20:3310');
        initial_p= centroid_pixels(c1_s,c2_s);
        
        %lcaPutSmart('MOTR:B244:MC01:M0:CH1:MOTOR.TWV',-10)%
        %This is a MATLAB function that takes the address of the motor
        % and adds the revolution steps size to move
        %Followed by a second command, 'PV_ADDRESS.TWF', which moves the 
        %motor by the request revolutions. 
        
        lcaPutSmart('MOTR:B244:MC01:M0:CH1:MOTOR.TWV',-10)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH1:MOTOR.TWF',-10)%
        disp('warm up run!!')  
        
        motor_stat_1x = lcaGetSmart('MOTR:B244:MC01:M0:CH1:MOTOR.MSTA');
        
        %This is a loop that checks whether the motor is still moving using
        %This is done in order to prevent one motor to overstep on the
        %motion of another, which effectively would disrupt the
        %callibration process
        
        while((motor_stat_1x ~= 2))
            motor_stat_1x = lcaGetSmart('MOTR:B244:MC01:M0:CH1:MOTOR.MSTA');
        end
        %%%%%%
        pause(2)
        
        lcaPutSmart('MOTR:B244:MC01:M0:CH1:MOTOR.TWV',5)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH1:MOTOR.TWF',5)%
        disp('warm up run!!')
        motor_stat_1x = lcaGetSmart('MOTR:B244:MC01:M0:CH1:MOTOR.MSTA');
        while((motor_stat_1x ~= 2))
            motor_stat_1x = lcaGetSmart('MOTR:B244:MC01:M0:CH1:MOTOR.MSTA');
        end
        %%%%%%

        %move that  you want to capture!
        cam2=profmon_grab('EXPT:LI20:3309');
        cam1 = profmon_grab('EXPT:LI20:3310');
        
        disp('start point')
        before_move =centroid_pixels(cam1,cam2);
        disp(before_move')
        
        lcaPutSmart('MOTR:B244:MC01:M0:CH1:MOTOR.TWV',10)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH1:MOTOR.TWF',10)%
        
        motor_stat_1x = lcaGetSmart('MOTR:B244:MC01:M0:CH1:MOTOR.MSTA');
        measure_before = centroid_pixels(cam1,cam2);
        while((motor_stat_1x ~= 2))
            motor_stat_1x = lcaGetSmart('MOTR:B244:MC01:M0:CH1:MOTOR.MSTA');
        end
        
        cam2_after = profmon_grab('EXPT:LI20:3309');
        cam1_after = profmon_grab('EXPT:LI20:3310');
        
        
        after_move = centroid_pixels(cam1_after,cam2_after);
        
        diff = after_move - measure_before;
        disp('1X:')
        disp(diff)
        c_m(1,:) = diff;
        
        %go back to the initial position
        lcaPutSmart('MOTR:B244:MC01:M0:CH1:MOTOR.TWV',-5)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH1:MOTOR.TWF',-5)%
        motor_stat_1x = lcaGetSmart('MOTR:B244:MC01:M0:CH1:MOTOR.MSTA');
        while((motor_stat_1x ~= 2))
            motor_stat_1x = lcaGetSmart('MOTR:B244:MC01:M0:CH1:MOTOR.MSTA');
        end
        
        c1_f = profmon_grab('EXPT:LI20:3309');
        c2_f = profmon_grab('EXPT:LI20:3310');
        final_p= centroid_pixels(c1_f,c2_f);
        
        diff = final_p - initial_p;
        hm(:,1) = diff;
    end
    
    %callibrate again
    facet_control(pos_i_want, 0.25, .54/7);
    c1_a1x = profmon_grab('EXPT:LI20:3309');
    c2_a1x = profmon_grab('EXPT:LI20:3310');
    disp('loc before starting (must be aligned!):')
    disp(centroid_pixels(c1_a1x,c2_a1x)')
    
    if engine == 2
        
        c1_s = profmon_grab('EXPT:LI20:3309');
        c2_s = profmon_grab('EXPT:LI20:3310');
        initial_p= centroid_pixels(c1_s,c2_s);
        
        lcaPutSmart('MOTR:B244:MC01:M0:CH3:MOTOR.TWV',-10)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH3:MOTOR.TWF',-10)%
        disp('warm up run!!')
        motor_stat_2x = lcaGetSmart('MOTR:B244:MC01:M0:CH3:MOTOR.MSTA');
        while((motor_stat_2x ~= 2))
            motor_stat_2x = lcaGetSmart('MOTR:B244:MC01:M0:CH3:MOTOR.MSTA');
        end
        %%%%%%

        
        lcaPutSmart('MOTR:B244:MC01:M0:CH3:MOTOR.TWV',5)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH3:MOTOR.TWF',5)%
        disp('warm up run!!')
        motor_stat_2x = lcaGetSmart('MOTR:B244:MC01:M0:CH3:MOTOR.MSTA');
        while((motor_stat_2x ~= 2))
            motor_stat_2x = lcaGetSmart('MOTR:B244:MC01:M0:CH3:MOTOR.MSTA');
        end

        
        %move that  you want to capture!
        cam2=profmon_grab('EXPT:LI20:3309');
        cam1 = profmon_grab('EXPT:LI20:3310');
        
        disp('start point')
        before_move =centroid_pixels(cam1,cam2);
        disp(before_move')
        pause(2)
        
        lcaPutSmart('MOTR:B244:MC01:M0:CH3:MOTOR.TWV',10)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH3:MOTOR.TWF',10)%
        
        motor_stat_2x = lcaGetSmart('MOTR:B244:MC01:M0:CH3:MOTOR.MSTA');
        while((motor_stat_2x ~= 2))
            motor_stat_2x = lcaGetSmart('MOTR:B244:MC01:M0:CH3:MOTOR.MSTA');
        end
        pause(2)
        cam2_after = profmon_grab('EXPT:LI20:3309');
        cam1_after = profmon_grab('EXPT:LI20:3310');
        
        
        after_move = centroid_pixels(cam1_after,cam2_after);
        
        diff = after_move - before_move;
        disp('2X:')
        disp(diff)
        c_m(3,:) = diff;
        %go back to the initial position
        lcaPutSmart('MOTR:B244:MC01:M0:CH3:MOTOR.TWV',-5)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH3:MOTOR.TWF',-5)%
        
        
        motor_stat_2x = lcaGetSmart('MOTR:B244:MC01:M0:CH3:MOTOR.MSTA');
        while((motor_stat_2x ~= 2))
            motor_stat_2x = lcaGetSmart('MOTR:B244:MC01:M0:CH3:MOTOR.MSTA');
        end
        pause(2)
        
        c1_f = profmon_grab('EXPT:LI20:3309');
        c2_f = profmon_grab('EXPT:LI20:3310');
        final_p= centroid_pixels(c1_f,c2_f);
        diff = final_p - initial_p;
        hm(:,3) = diff;
    end
    facet_control(pos_i_want, 0.25, .54/7);
    c1_a2x = profmon_grab('EXPT:LI20:3309');
    c2_a2x = profmon_grab('EXPT:LI20:3310');
    disp('loc before starting (must be aligned!):')
    disp(centroid_pixels(c1_a2x,c2_a2x)')
    
    
    if engine ==3
        
                
        c1_s = profmon_grab('EXPT:LI20:3309');
        c2_s = profmon_grab('EXPT:LI20:3310');
        initial_p= centroid_pixels(c1_s,c2_s);
        
        lcaPutSmart('MOTR:B244:MC01:M0:CH2:MOTOR.TWV',-10)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH2:MOTOR.TWF',-10)%
        disp('warm up run!!')
        motor_stat_1y = lcaGetSmart('MOTR:B244:MC01:M0:CH2:MOTOR.MSTA');
        while((motor_stat_1y ~= 2))
            motor_stat_1y = lcaGetSmart('MOTR:B244:MC01:M0:CH2:MOTOR.MSTA');
        end
        pause(2)
        %%%%%%
        lcaPutSmart('MOTR:B244:MC01:M0:CH2:MOTOR.TWV',5)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH2:MOTOR.TWF',5)%
        
        motor_stat_1y = lcaGetSmart('MOTR:B244:MC01:M0:CH2:MOTOR.MSTA');
        while((motor_stat_1y ~= 2))
            motor_stat_1y = lcaGetSmart('MOTR:B244:MC01:M0:CH2:MOTOR.MSTA');
        end
        
        pause(2)
        %move that you want to capture!
        cam2=profmon_grab('EXPT:LI20:3309');
        cam1 = profmon_grab('EXPT:LI20:3310');
        
        disp('start point')
        before_move =centroid_pixels(cam1,cam2);
        disp(before_move')
        pause(2)
        
        lcaPutSmart('MOTR:B244:MC01:M0:CH2:MOTOR.TWV',10)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH2:MOTOR.TWF',10)%
        
        motor_stat_1y = lcaGetSmart('MOTR:B244:MC01:M0:CH2:MOTOR.MSTA');
        while((motor_stat_1y ~= 2))
            motor_stat_1y = lcaGetSmart('MOTR:B244:MC01:M0:CH2:MOTOR.MSTA');
        end
        pause(2)
        
        cam2_after = profmon_grab('EXPT:LI20:3309');
        cam1_after = profmon_grab('EXPT:LI20:3310');
        
        after_move = centroid_pixels(cam1_after,cam2_after);
        
        diff = after_move - before_move;
        disp('1Y:')
        disp(diff)
        c_m(2,:) = diff;
        
        lcaPutSmart('MOTR:B244:MC01:M0:CH2:MOTOR.TWV',-5)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH2:MOTOR.TWF',-5)%
        
        motor_stat_1y = lcaGetSmart('MOTR:B244:MC01:M0:CH2:MOTOR.MSTA');
        while((motor_stat_1y ~= 2))
            motor_stat_1y = lcaGetSmart('MOTR:B244:MC01:M0:CH2:MOTOR.MSTA');
        end
        
        c1_f = profmon_grab('EXPT:LI20:3309');
        c2_f = profmon_grab('EXPT:LI20:3310');
        final_p= centroid_pixels(c1_f,c2_f);
        
        diff = final_p - initial_p;
        hm(:,2) = diff;
        
        pause(2)
        
    end
    %callibrate again
    facet_control(pos_i_want, 0.25, .54/7);
    c1_a1y = profmon_grab('EXPT:LI20:3309');
    c2_a1y = profmon_grab('EXPT:LI20:3310');
    disp('loc before starting (must be aligned!):')
    disp(centroid_pixels(c1_a1y,c2_a1y)')
    if engine ==4
        
                        
        c1_s = profmon_grab('EXPT:LI20:3309');
        c2_s = profmon_grab('EXPT:LI20:3310');
        initial_p= centroid_pixels(c1_s,c2_s);
        
        
        lcaPutSmart('MOTR:B244:MC01:M0:CH4:MOTOR.TWV',-10)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH4:MOTOR.TWF',-10)%
        disp('warm up run!!')
        motor_stat_2y = lcaGetSmart('MOTR:B244:MC01:M0:CH4:MOTOR.MSTA');
        while((motor_stat_2y ~= 2))
            motor_stat_2y = lcaGetSmart('MOTR:B244:MC01:M0:CH4:MOTOR.MSTA');
        end
        pause(2)
        %%%%%%
        lcaPutSmart('MOTR:B244:MC01:M0:CH4:MOTOR.TWV',5)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH4:MOTOR.TWF',5)%
        
        motor_stat_2y = lcaGetSmart('MOTR:B244:MC01:M0:CH4:MOTOR.MSTA');
        while((motor_stat_2y ~= 2))
            motor_stat_2y = lcaGetSmart('MOTR:B244:MC01:M0:CH4:MOTOR.MSTA');
        end
        
        pause(2)
        %move that  you want to capture!
        cam2=profmon_grab('EXPT:LI20:3309');
        cam1 = profmon_grab('EXPT:LI20:3310');
        
        before_move =centroid_pixels(cam1,cam2);
        pause(2)
        lcaPutSmart('MOTR:B244:MC01:M0:CH4:MOTOR.TWV',10)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH4:MOTOR.TWF',10)%
        
        motor_stat_2y = lcaGetSmart('MOTR:B244:MC01:M0:CH4:MOTOR.MSTA');
        while((motor_stat_2y ~= 2))
            motor_stat_2y = lcaGetSmart('MOTR:B244:MC01:M0:CH4:MOTOR.MSTA');
        end
        pause(2)
        cam2_after = profmon_grab('EXPT:LI20:3309');
        cam1_after = profmon_grab('EXPT:LI20:3310');
        
        after_move = centroid_pixels(cam1_after,cam2_after);
        
        diff = after_move - before_move;
        disp('2Y:')
        disp(diff)
        c_m(4,:) = diff;
        lcaPutSmart('MOTR:B244:MC01:M0:CH4:MOTOR.TWV',-5)%
        lcaPutSmart('MOTR:B244:MC01:M0:CH4:MOTOR.TWF',-5)%
        
        motor_stat_2y = lcaGetSmart('MOTR:B244:MC01:M0:CH4:MOTOR.MSTA');
        while((motor_stat_2y ~= 2))
            motor_stat_2y = lcaGetSmart('MOTR:B244:MC01:M0:CH4:MOTOR.MSTA');
        end
        pause(2)
        
        c1_f = profmon_grab('EXPT:LI20:3309');
        c2_f = profmon_grab('EXPT:LI20:3310');
        final_p= centroid_pixels(c1_f,c2_f);
        
        diff = final_p - initial_p;
        hm(:,4) = diff;
        
    end
    
end
cm = c_m;
disp('c_m: (Measured Callibration Matrix for Laser Transport)')
disp(cm)
disp('h_m (Diff between final position after 20 revs and its original starting point)' )
disp(hm)
calidata_name = ['/u1/facet/matlab/data/2018/data_dump/newcalidata', datestr(now, 'mm-dd-yy HH-MM-SS'), '.csv'];
csvwrite(calidata_name, cm);
end