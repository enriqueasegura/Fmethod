function [variables, track_data, pv_data, corr_data, int_data, total_rev, int_diff, time_arr, aligntime, callibration_memory ]=facet_align(target, kp, ki, kd, k_u, answer, long_scale_flag)
disp('kp, ki, ku:')
ki = ki*k_u;
kp= kp*k_u;
kd = kd*k_u;
variables = [kp,ki, k_u];
disp(variables);
it_fterm = 400;
track_data = zeros(4,it_fterm);
pv_data= zeros(4,it_fterm);
corr_data = zeros(4,it_fterm);
int_data = zeros(4,it_fterm);
total_rev = zeros(4,it_fterm);
aligntime= zeros(1, it_fterm);

int_diff = zeros(4,400);

abs_diffx=zeros(1,400);
abs_diffy=zeros(1,400);

derivative = zeros(4,400);
delta_corr = zeros(4,400);

time_arr = zeros(1,400);
it_arr = zeros(1,400);
i = 1;
curr_total_runtime = zeros(1,400);
callibration_memory = zeros(it_fterm, 4,4);
on_the_fly_memory = zeros(it_fterm, 4,4);

status = 'not done';


while isequal(status, 'not done')

    % Grab the beam position on each camera
    cam2_c = profmon_grab('EXPT:LI20:3309');
    cam1_c = profmon_grab('EXPT:LI20:3310');
    beam_vec = centroid_pixels(cam1_c, cam2_c);
    % Record the iteration number
    it_arr(i) =i;
    % Record the current beam position
    track_data(:,i) = beam_vec';
    disp('Current Position')
    disp(beam_vec);
    
    % Calculate the error: current position - desired position
    err = target - transpose(beam_vec);
    %err = target - check_pos;
    %err = (transpose(beam_vec) - target);
%     flipper = 1.0*[ 1.00, 0, 0, 0; ... %originally -1 in first two rows
%                 0, 1.00, 0, 0;...
%                 0, 0, 1.00 0;...
%                 0, 0, 0, 1.00];
%     err = flipper * err;
    % Record the error  
    pv_data(:,i) = err;
    % Calculate the proportional corrections
    corr = rev_move(err);

    % Keep track of the integral of the errors
    if i>=2
        int_diff(:,i) = int_diff(:,i-1) + err;
        %in case of PID 
        derivative(:,i) = err - derivative(:,i-1);
    end
    
    int_rev = rev_move( int_diff(:,i) );
    delta_rev = rev_move(derivative(:,i));
    % Record the proportional correction and the integral correction
    corr_data(:,i) = kp*corr;
    int_data(:,i) = ki*int_rev;
    delta_corr(:,i) = kd*delta_rev;
    current_total_rev = kp*corr+ ki*int_rev + (kd)*delta_rev;
    
    if abs(total_rev(1,1)) >= 10 || abs(total_rev(2,1)) >= 10 || abs(total_rev(3,1)) >= 10 || abs(total_rev(4,1)) >= 10
        disp('This correction might be push the beam off the mirror')
        disp('Stopping Algorithm')
        break;
    end
    
    total_rev(:,i) = current_total_rev;
    
    
    disp('final rev:')
    disp(total_rev(:,i)');
    
    %time the corrections
    time_rev_start = tic;
    %execute the corrections
    callibration_memory(i,:,:)  = move_my_beam(total_rev(:,i));
    t_rev_elapsed = toc(time_rev_start);
    time_arr(i) = (t_rev_elapsed);
    disp('Time elapsed:')
    disp((t_rev_elapsed));
    
    %use on the fly callibration
    if i > 1
        change_in_beam_pos = track_data(:,i) - track_data(:,i-1);
        on_the_fly_memory(i,:,:)= on_the_fly_response(change_in_beam_pos, total_rev(:,i-1));
    end
    % Only plots below here.
    
        
    c_track1x ='-.rs';
    c_track1y = ':b^';
    c_pv1x =  '-.gd';
    c_pv1y =  ':ro';
    curr_pos = track_data(:,i);
    abs_diffx(i) = abs(curr_pos(1,1) - curr_pos(3,1));
    abs_diffy(i) = abs(curr_pos(2,1) - curr_pos(4,1));

    figure(3)
    plot(it_arr(1:i), abs_diffx(1:i), ':r^', it_arr(1:i), abs_diffy(1:i), ':cs')
    xlabel('F method Iterations num')
    ylabel('abs(\Delta) )(pix)')
    set(gcf, 'Position' , [600,200,400,400])
    set(gcf, 'Color', 'w')
    title('Relative Alignment on Both Dimensions', 'Fontsize', 25)
    
    drawnow
    
    figure(4)
    subplot(121)
    plot(it_arr(1:i), track_data(1,1:i), '-.mo',it_arr(1:i), track_data(3,1:i), '-.co',it_arr(1:i),abs_diffx(1:i), ':r^')
    xlabel('F method Iterations num')
    ylabel('Beam X (pix)')
    title('Relative Alignment on X', 'Fontsize', 25)
    
    subplot(122)
    plot(it_arr(1:i), track_data(2,1:i), '-.mo',it_arr(1:i), track_data(4,1:i), '-.co', it_arr(1:i),abs_diffy(1:i), ':r^')
    xlabel('F method Iterations num')
    ylabel('Beam Y (pix)')
    set(gcf, 'Position' , [600,200,300,300])
    set(gcf, 'Color', 'w')
    title('Relative Alignment on Y', 'Fontsize', 25)

    drawnow   
    
    figure(19)
    subplot(2,3,1)
    plot(track_data(1,1:i), track_data(2,1:i), ':ro')
    xlabel('Beam 1X (pix)')
    ylabel('Beam 1Y (pix)')
    title('Mirror 1','Fontsize',15)
    
    subplot(2,3,2)
    plot(track_data(3,1:i), track_data(4,1:i), ':bo')
    xlabel('Beam 2X (pix)')
    ylabel('Beam 2Y (pix)')
    title('Mirror 2','Fontsize',15)
    
    subplot(2,3,3)
    plot(track_data(3,1:i), track_data(4,1:i), ':bo', track_data(1,1:i), track_data(2,1:i), ':r^')
    xlabel('Beam X (pix)')
    ylabel('Beam Y (pix)')
    title('Comparison of Trajectories','Fontsize',15)
    
    subplot(2,3,4)
    plot(pv_data(1,1:i), pv_data(2,1:i), ':ro')
    xlabel('\Delta_{x1} (pix)')
    ylabel('\Delta_{y1} (pix)')
    subplot(2,3,5)
    plot(pv_data(3,1:i), pv_data(4,1:i), ':bo')
    xlabel('\Delta_{x2} (pix)')
    ylabel('\Delta_{y2} (pix)')
    subplot(2,3,6)
    plot(pv_data(1,1:i), pv_data(2,1:i), ':ro',pv_data(3,1:i), pv_data(4,1:i), ':bo')
    xlabel('\Delta_{X} (pix)')
    ylabel('\Delta_{Y} (pix)')
    
    set(gcf, 'Position' , [800,900,800,400])
    set(gcf, 'Color', 'w')
    drawnow
    
    figure(735)
    subplot(2,2,1)
    plot(it_arr(1:i), track_data(1,1:i), c_track1x)
    title('Beam 1X-Coordinate')
    xlabel('F method iteration', 'Fontsize',10)
    ylabel('Beam Position (pix)', 'Fontsize', 10)
    set(gcf, 'Color', 'w')
    
    
    subplot(2,2,2)
    plot(it_arr(1:i), track_data(2,1:i), c_track1y)
    title('Beam 1Y-Coordinate')
    xlabel('F method iteration', 'Fontsize',10)
    ylabel('Beam Position (pix)', 'Fontsize', 10)
    set(gcf, 'Color', 'w')
    
    
    subplot(2,2,3)
    plot(it_arr(1:i), track_data(3,1:i), c_track1x)
    title('Beam 2X-Coordinate')
    xlabel('F method iteration', 'Fontsize',10)
    ylabel('Beam Position (pix)', 'Fontsize', 10)
    set(gcf, 'Color', 'w')
    
    subplot(2,2,4)
    plot(it_arr(1:i), track_data(4,1:i), c_track1y)
    title('Beam 2Y-Coordinate')
    xlabel('F method iteration', 'Fontsize',10)
    ylabel('Beam Position (pix)', 'Fontsize', 10)
    set(gcf, 'Position' , [600,200,400,300])
    set(gcf, 'Color', 'w')
    drawnow;
    
    figure(935)
    subplot(2,2,1)
    plot(it_arr(1:i), pv_data(1, 1:i), c_pv1x)
    title('Beam 1X-Coordinate')
    xlabel('F method iteration num', 'Fontsize',10)
    ylabel('\Delta (pix)', 'Fontsize', 15)
    set(gcf, 'Color', 'w')
    
    subplot(2,2,2)
    plot(it_arr(1:i), pv_data(2, 1:i), c_pv1y)
    title('Beam 1Y-Coordinate')
    xlabel('F method iteration num', 'Fontsize',10)
    ylabel('\Delta (pix)', 'Fontsize', 15)
    
    subplot(2,2,3)
    plot(it_arr(1:i), pv_data(3, 1:i), c_pv1x)
    title('Beam 2X-Coordinate')
    xlabel('F method iteration num', 'Fontsize',10)
    ylabel('\Delta (pix)', 'Fontsize', 15)
    
    subplot(2,2,4)
    plot(it_arr(1:i),pv_data(4, 1:i),c_pv1y)
    title('Beam 2Y-Coordinate')
    xlabel('F method iteration num', 'Fontsize',10)
    ylabel('\Delta (pix)', 'Fontsize', 15)
    set(gcf, 'Position' , [200,200,400,300])
    set(gcf, 'Color', 'w')
    
    drawnow;
    
    figure(065)
    subplot(221)
    plot(it_arr(1:i), total_rev(1,1:i), ':ro',it_arr(1:i), int_data(1,1:i), ':mo',it_arr(1:i), corr_data(1,1:i), '-.bs');
    xlabel('F method iteration num', 'Fontsize',10)
    ylabel('Total Corr 1X (rev)')
    title('Final Corrections Mirror 1-X')
    subplot(222)
    plot(it_arr(1:i), total_rev(2,1:i), ':ro',it_arr(1:i), int_data(2,1:i), ':mo',it_arr(1:i), corr_data(2,1:i), '-.bs');
    xlabel('F method iteration num', 'Fontsize',10)
    ylabel('Total Corr 1Y (rev)')
    title('Final Corrections Mirror 1-Y')
    subplot(223)
    plot(it_arr(1:i), total_rev(3,1:i), ':ro',it_arr(1:i), int_data(4,1:i), ':mo',it_arr(1:i), corr_data(3,1:i), '-.bs');
    xlabel('F method iteration num', 'Fontsize',10)
    ylabel('Total Corr 2X (rev)')
    title('Final Corrections Mirror 2-X')
    subplot(224)
    plot(it_arr(1:i), total_rev(4,1:i), ':ro',it_arr(1:i), int_data(4,1:i), ':mo',it_arr(1:i), corr_data(4,1:i), '-.bs');
    xlabel('F Method Iteration Num','Fontsize',10)
    ylabel('Total Corr 2Y (rev)')
    set(gcf, 'Position' , [600,200,400,400])
    set(gcf, 'Color', 'w')
    title('Final Corrections Mirror 2-Y')
    newpos = [0.9, 0.45, 0.1, 0.1];
    hl = legend('Total Rev', 'Int Cont', 'Prop Cont');
    set(hl, 'Position', newpos, 'Units', 'normalized')
    drawnow
    
    figure(218)
    subplot(121)
    plot(target(1), target(2), 'bx', 'MarkerSize', 20)
    quiver(track_data(1,1:i), track_data(2,1:i), total_rev(1,1:i), total_rev(2,1:i), '-r')
    xlabel('Beam 1X (pix)')
    ylabel('Beam 1Y (pix)')
    title('Mirror 1')
    subplot(122)
    plot(target(3), target(4), 'bx', 'MarkerSize', 20)
    quiver(track_data(3,1:i), track_data(4,1:i), total_rev(3,1:i), total_rev(4,1:i), '-b')
    xlabel('Beam 2X (pix)')
    ylabel('Beam 2Y (pix)')
    title('Mirror 2')
    set(gcf, 'Position' , [1200,200,400,400])
    set(gcf, 'Color', 'w')
        
    drawnow

    
    %check distance (very basic proportional control).
    if abs(err(1,1)) < 1 && abs(err(2,1))  < 1 && abs(err(3,1))  < 1 && abs(err(4,1))  < 1
        disp('it aligned')
        disp(beam_vec)
        disp('it num:')
        disp(i);
        aligntime(i) = i;
        disp('Time to align (min)')
        disp(sum(time_arr(1:i)/60))
        if isequal(long_scale_flag, 'no')
            status = 'done';
            disp(aligntime(:,i));
        end
    end
    curr_total_runtime = sum(time_arr(1:i)/60);
    aligntime(i) = sum(time_arr(1:i)/60);
    
<<<<<<< HEAD
    %in case of longer than 20 minutes run, stop feedback. 
    if i >= it_fterm && isequal(long_scale_flag, 'yes')
=======
    %in case of longer than 20 minutes run, stop feedback.  
    if curr_total_runtime > 20 || i >= it_fterm
>>>>>>> de1b25d0d1e75e6ba1139d31458ded0789976aa9
        disp('total time run:')
        disp(curr_total_runtime(:,i));
        status = 'done';
    end
    i=i+1;
    
    
end

disp('algo finished')

if isequal(answer, 'Yes') || isequal(answer, 'yes')

    disp('saving data!')
    
    diffx_name = ['/u1/facet/matlab/data/2018/data_facet_align/diffx_data', datestr(now, 'mm-dd-yy HH-MM-SS'), '.csv'];
    csvwrite(diffx_name, abs_diffx);
    diffy_name = ['/u1/facet/matlab/data/2018/data_facet_align/diffy_data', datestr(now, 'mm-dd-yy HH-MM-SS'), '.csv'];
    csvwrite(diffy_name, abs_diffy);
    
    pv_name = ['/u1/facet/matlab/data/2018/data_facet_align/pv_data', datestr(now, 'mm-dd-yy HH-MM-SS'), '.csv'];
    csvwrite(pv_name, pv_data);
    
    track_name = ['/u1/facet/matlab/data/2018/data_facet_align/track_data', datestr(now, 'mm-dd-yy HH-MM-SS'), '.csv'];
    csvwrite(track_name, track_data);
    
    pcorr_name =['/u1/facet/matlab/data/2018/data_facet_align/corrdata', datestr(now, 'mm-dd-yy HH-MM-SS'), '.csv'];
    csvwrite(pcorr_name, corr_data);
    
    icorr_name = ['/u1/facet/matlab/data/2018/data_facet_align/icorrdata', datestr(now, 'mm-dd-yy HH-MM-SS'), '.csv'];
    csvwrite(icorr_name, int_data);
    
    fcorr_name = ['/u1/facet/matlab/data/2018/data_facet_align/fcorrdata', datestr(now, 'mm-dd-yy HH-MM-SS'), '.csv'];
    csvwrite(fcorr_name, total_rev);
    
    timestamp =['/u1/facet/matlab/data/2018/data_facet_align/timecorrdata', datestr(now, 'mm-dd-yy HH-MM-SS'), '.csv'];
    csvwrite(timestamp, time_arr);
    
    aligntime_stamp =['/u1/facet/matlab/data/2018/data_facet_align/aligntimecorrdata', datestr(now, 'mm-dd-yy HH-MM-SS'), '.csv'];
    csvwrite(aligntime_stamp, aligntime);
    
    calimemory_stamp =['/u1/facet/matlab/data/2018/data_facet_align/calimemory', datestr(now, 'mm-dd-yy HH-MM-SS'), '.csv'];
    csvwrite(calimemory_stamp, callibration_memory);
    
    on_the_fly_calimemory_stamp =['/u1/facet/matlab/data/2018/data_facet_align/onthefly_calimemory', datestr(now, 'mm-dd-yy HH-MM-SS'), '.csv'];
    csvwrite(on_the_fly_calimemory_stamp, on_the_fly_memory);
    
    
    
end
