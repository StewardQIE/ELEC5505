clc;clear all

mpc=case69_16m;
scale_P=18;
mpopt = mpoption('PF_ALG',1); % '1' for 'NR','4' for 'GS'
baseMVA = 100;
mpc.gen(13,2)=mpc.gen(13,2)+82*scale_P;
[RESULTS1, ~] =runpf(mpc,mpopt);