%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function takes the final corrections from PI-controller 
%to each pico-motor engine to move the beam to designed position
%Currently it relies on a while loop to check whether the motor is moving or not
%This is important because the limitations of the experiment
%are that only one engine can be operated at a time by the driver.
%For more information about each specific function, please
%see manual on README
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%A snappier version of move_my_beam 
%This function controls the beam and enacts the appropiate corrections
%to each engine

function move_my_beam(fcorr_vec)
for motor=1:4
    motor_str = strcat('MOTR:B244:MC01:M0:CH',int2str(motor),':MOTOR');
    %execute the motion
    % 
    lcaPutSmart(strcat(motor_str,'.TWV'), fcorr_vec(motor,1));
    lcaPutSmart(strcat(motor_str,'.TWF'), 1.0);
    
    %check if the motor is moving
    %this loop will inquire about the motor status until it finishes
	%then it breaks out and carries out the rest of the corrections.
    motor_status = lcaGetSmart(strcat(motor_str,'.MSTA'));
    while((motor_status ~= 2))
        motor_status= lcaGetSmart(strcat(motor_str,'.MSTA'));
    end
end
end


