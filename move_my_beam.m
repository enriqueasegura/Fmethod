%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function takes the final corrections from PI-controller 
%to each pico-motor engine to move the beam to designed position
%Currently it relies on a while loop to check whether the motor is moving or not
%This is important because the limitations of the experiment
%are that only one engine can be operated at a time by the driver.
%For more information about each specific function, please
%see manual on README
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function move_my_beam(rev_arr)

lcaPutSmart('MOTR:B244:MC01:M0:CH1:MOTOR.TWV', rev_arr(1,1));
lcaPutSmart('MOTR:B244:MC01:M0:CH1:MOTOR.TWF', 1.0);

motor_stat_1x = lcaGetSmart('MOTR:B244:MC01:M0:CH1:MOTOR.MSTA');

%this loop will inquire about the motor status until it finishes
%then it breaks out and carries out the rest of the corrections.
while((motor_stat_1x ~= 2))
    motor_stat_1x = lcaGetSmart('MOTR:B244:MC01:M0:CH1:MOTOR.MSTA');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%next engine

lcaPutSmart('MOTR:B244:MC01:M0:CH2:MOTOR.TWV', rev_arr(2,1));
lcaPutSmart('MOTR:B244:MC01:M0:CH2:MOTOR.TWF', 1.0);

motor_stat_1y = lcaGetSmart('MOTR:B244:MC01:M0:CH2:MOTOR.MSTA');

%this loop will inquire about the motor status until it finishes
%then it breaks out and carries out the rest of the corrections.
while((motor_stat_1y ~= 2))
    motor_stat_1y = lcaGetSmart('MOTR:B244:MC01:M0:CH2:MOTOR.MSTA');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%next engine
lcaPutSmart('MOTR:B244:MC01:M0:CH3:MOTOR.TWV', rev_arr(3,1));
lcaPutSmart('MOTR:B244:MC01:M0:CH3:MOTOR.TWF', 1.0)

motor_stat_2x = lcaGetSmart('MOTR:B244:MC01:M0:CH3:MOTOR.MSTA');


%this loop will inquire about the motor status until it finishes
%then it breaks out and carries out the rest of the corrections.
while((motor_stat_2x  ~= 2))
    motor_stat_2x = lcaGetSmart('MOTR:B244:MC01:M0:CH3:MOTOR.MSTA');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%next engine

lcaPutSmart('MOTR:B244:MC01:M0:CH4:MOTOR.TWV', rev_arr(4,1));
lcaPutSmart('MOTR:B244:MC01:M0:CH4:MOTOR.TWF', 1.0)

motor_stat_2y = lcaGetSmart('MOTR:B244:MC01:M0:CH4:MOTOR.MSTA');

%this loop will inquire about the motor status until it finishes
%then it breaks out and carries out the rest of the corrections.
while((motor_stat_2y ~= 2))
    motor_stat_2y = lcaGetSmart('MOTR:B244:MC01:M0:CH4:MOTOR.MSTA');
end

end
