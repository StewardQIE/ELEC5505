clear all; clc;

%% ==========Creating Ybus and solving load flow using MATPOWER==========
baseMVA = 100;
mpopt = mpoption('PF_ALG',1); % '1' for 'NR','4' for 'GS'
mpopt1 = mpoption('PF_ALG',4,'PF_MAX_IT_GS',20000); % '1' for 'NR','4' for 'GS
tic
[RESULTS, SUCCESS] =runpf('case69_16m',mpopt);
toc

tic
[RESULTS1, SUCCESS1] =runpf('case69_16m',mpopt1);
toc