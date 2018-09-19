

function [rev_arr] = rev_move(target_vec)

%measured by callibration matrix
%check folder for latest callibration matrix.
cammat = [        


  322.1066    3.1398  544.0888   14.9011
    7.3212 -235.9904   16.1838 -414.1739
  155.3355   -1.3564  424.4813    3.5086
   -7.8248 -121.5604   -0.7654 -320.4423

];

%Callibration matrix was measured in 10 revolutions. 


cammat = cammat / 10;
cammat = cammat';


rev_arr = cammat \ target_vec;

%Extract inverse from target_vec
%target_vec is the err calculated in Fmethod algorithm.
rev_arr = cammat\target_vec;
%This result are the raw corrections which will be adjusted
%by tuning parameters and integration/derivative corrections.
end
