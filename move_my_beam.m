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