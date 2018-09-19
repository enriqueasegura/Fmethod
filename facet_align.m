function [variables, track_data, pv_data, corr_data, int_data, total_rev, int_diff, time_arr, aligntime]=facet_align(target, kp, ki, k_d, k_u, it_fterm)
disp('kp, ki, kd, ku:')
ki = ki*k_u;
kp= kp*k_u;
kd = k_d*k_u
%storing the PID parameters
variables = [kp,ki, k_d, k_u];
disp('PID Tuning Parameters')
disp(variables);

%it_fterm are the max iterations allowed

track_data = zeros(4,it_fterm);
pv_data= zeros(4,it_fterm);

corr_data = zeros(4,it_fterm);
int_data = zeros(4,it_fterm);

total_rev = zeros(4,it_fterm);

aligntime= zeros(1,it_fterm);
int_diff = zeros(4,it_fterm);

abs_diffx=zeros(1,it_fterm);
abs_diffy=zeros(1,it_fterm);

derivative = zeros(4,it_fterm);
derivative_corr = zeros(4,it_fterm);
derv_data =  zeros(4,it_fterm);

time_arr = zeros(1,it_fterm);
it_arr = zeros(1,it_fterm);

%dummy variable to track iterations of the algorithm
i = 1;
status = 'not done';
aligntime(i) = 0;
while isequal(status, 'not done')
    
    cam2_c = profmon_grab('EXPT:LI20:3309');
    cam1_c = profmon_grab('EXPT:LI20:3310');
    beam_vec = centroid_pixels(cam1_c,cam2_c);
    it_arr(i) =i;
    track_data(:,i) = beam_vec';
    
    
    err = transpose(beam_vec) - target;
    
    % diff = target - transpose(beam_vec);
    
    pv_data(:,i) = err;
    corr= rev_move(err);
    c_track1x ='-.rs';
    c_track1y = ':b^';
    c_pv1x =  '-.gd';
    c_pv1y =  ':ro';
    
    %tracking current difference to estimate alignment
    %respect to each dimension
    
    curr_pos = track_data(:,i);
    abs_diffx(i) = abs(curr_pos(1,1) - curr_pos(3,1));
    abs_diffy(i) = abs(curr_pos(2,1) - curr_pos(4,1));

    %plots to serve as diagnostic updates as the F-method runs
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
    
    figure(735)
    subplot(2,2,1)
    plot(it_arr(1:i), track_data(1,1:i), c_track1x)
    title('Beam 1X-Coordinate')
    xlabel('F method iteration (sec)', 'Fontsize',10)
    ylabel('Beam Position (pix)', 'Fontsize', 10)
    set(gcf, 'Color', 'w')
    
    
    subplot(2,2,2)
    plot(it_arr(1:i), track_data(2,1:i), c_track1y)
    title('Beam 1Y-Coordinate')
    xlabel('F method iteration (sec)', 'Fontsize',10)
    ylabel('Beam Position (pix)', 'Fontsize', 10)
    set(gcf, 'Color', 'w')
    
    
    subplot(2,2,3)
    plot(it_arr(1:i), track_data(3,1:i), c_track1x)
    title('Beam 2X-Coordinate')
    xlabel('F method iteration (sec)', 'Fontsize',10)
    ylabel('Beam Position (pix)', 'Fontsize', 10)
    set(gcf, 'Color', 'w')
    
    subplot(2,2,4)
    plot(it_arr(1:i), track_data(4,1:i), c_track1y)
    title('Beam 2Y-Coordinate')
    xlabel('F method iteration (sec)', 'Fontsize',10)
    ylabel('Beam Position (pix)', 'Fontsize', 10)
    set(gcf, 'Position' , [600,200,400,300])
    set(gcf, 'Color', 'w')
    drawnow;
    
    figure(935)
    subplot(2,2,1)
    plot(it_arr(1:i), pv_data(1, 1:i), c_pv1x)
    title('Beam 1X-Coordinate')
    xlabel('F method iteration num', 'Fontsize',10)
    ylabel('\Delta (pix)', 'Fontsize', 10)
    set(gcf, 'Color', 'w')
    
    subplot(2,2,2)
    plot(it_arr(1:i), pv_data(2, 1:i), c_pv1y)
    title('Beam 1Y-Coordinate')
    xlabel('F method iteration num', 'Fontsize',10)
    ylabel('\Delta (pix)', 'Fontsize', 10)
    
    subplot(2,2,3)
    plot(it_arr(1:i), pv_data(3, 1:i), c_pv1x)
    title('Beam 2X-Coordinate')
    xlabel('F method iteration num', 'Fontsize',10)
    ylabel('\Delta (pix)', 'Fontsize', 10)
    
    subplot(2,2,4)
    plot(it_arr(1:i),pv_data(4, 1:i),c_pv1y)
    title('Beam 2Y-Coordinate')
    xlabel('F method iteration num', 'Fontsize',10)
    ylabel('\Delta (pix)', 'Fontsize', 10)
    set(gcf, 'Position' , [200,200,400,300])
    set(gcf, 'Color', 'w')
    
    drawnow;
    
    if isequal(i,1)
        %this keeps track of all the errors
        %and will be used to calculate integral corrections
        %to adjust
        int_diff(:, i) =err;
        derivative(:,i) = err;
    else
        int_diff(:,i) = int_diff(:,i-1)+err;
        %in case of PID 
        derivative(:,i) = err - derivative(:,end);
    end
    
    %calculate necessary adjustments due to Integral and Derivative Components
    int_rev = rev_move(int_diff(:,i));
    derivative_corr(:,i) = rev_move(derivative(:,i));

    %Adjusted by Tuning Parameters (User input)
    corr_data(:,i) = kp*corr;
    int_data(:,i) = ki*int_rev;
    derv_data(:,i) = kd*derivative_corr(:,i);
    
    %Calculate Total Correction
    total_rev(:,i)= kp*corr+ ki*int_rev + (kd)*derivative_rev;
    disp('final rev:')
    disp(total_rev(:,i)');
    
    %Diagnostics Display of Real Time Corrections 
    
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
    quiver(track_data(1,1:i), track_data(2,1:i), total_rev(1,1:i), total_rev(2,1:i), '-r')
    xlabel('Beam 1X (pix)')
    ylabel('Beam 1Y (pix)')
    title('Mirror 1')
    subplot(122)
    quiver(track_data(3,1:i), track_data(4,1:i), total_rev(3,1:i), total_rev(4,1:i), '-.b')
    xlabel('Beam 2X (pix)')
    ylabel('Beam 2Y (pix)')
    title('Mirror 2')
    set(gcf, 'Position' , [1200,200,400,400])
    set(gcf, 'Color', 'w')
        
    drawnow
    
    %time the corrections 
    
    time_rev_start = tic;
    
    %execute the corrections
    %This function sends corrections to pico-motors to execute the motions
    %to rectify the beam.
    move_my_beam(total_rev(:,i));
    
    t_rev_elapsed = toc(time_rev_start);
    
    %Feed timestamp of each correction's time
    %This will be used to assert any correlation between initial corrections, 
    %time spent on each correction, and results on error minimization. 
    %Goal: to improve using this data time of oscillation parameter to obtain better
    %tuning for controller. 
    
    time_arr(i) = (t_rev_elapsed);
    
    disp('Time elapsed:')
    disp((t_rev_elapsed));
    
    %Check for halting condition (currently at 1 pix, but expected to reach 0.5 pix)
    if abs(err(1,1)) < 1 && abs(err(2,1))  < 1 && abs(err(3,1))  < 1 && abs(err(4,1))  < 1
        disp('it aligned')
        disp(beam_vec')
        disp('it num:')
        disp(i);
        aligntime(i) = i;
        disp('Time to align (min)')
        disp(sum(time_arr(1:i)/60))
        status = 'done';
        disp(aligntime(:,i));
    end
    %convert to minutes and store timestamp
    
    curr_total_runtime = sum(time_arr(1:i)/60);
    aligntime(i) = sum(time_arr(1:i)/60);
    
    %in case of longer than 20 minutes run, stop feedback.  
    if curr_total_runtime > 20
        disp('total time run:')
        disp(curr_total_runtime(:,i));
        status = 'done';
    end
    i=i+1;
    
    
end

disp('Algo Finished. Beam Aligned to Target Position')

prompt = 'Would you like to save this experimental data?';
answer = input(prompt, 's');

if isequal(answer, 'Yes') || isequal(answer, 'yes')

    disp('Saving Data!')
    
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
end

end
