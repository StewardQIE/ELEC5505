clc
clear all
iter=100;
scale_P=18;
scale_V=0.002;
eff13_P=zeros(iter,1);
mpopt = mpoption('PF_ALG',1,'PF_MAX_IT_GS',20000); % '1' for 'NR','4' for 'GS'
baseMVA = 100;

for i=1:iter
    mpc=case69_16m;
    mpc.gen(13,2)=mpc.gen(13,2)+i*scale_P;
    [RESULTS1, ~] =runpf(mpc,mpopt);
    bus1=RESULTS1.bus;
    branch1=RESULTS1.branch;
    gen1=RESULTS1.gen;
    Ybus1 = makeYbus(baseMVA, bus1, branch1);
    Ybus1=full(Ybus1);
    [Ploss,~,~]= get_losses(baseMVA, bus1, branch1);
    genP=sum(gen1(:,2),'all');
    eff13_P(i,1)=(genP-real(sum(Ploss)))*100/genP;
end

eff13_voltage=zeros(iter,1);
for i=1:iter
    mpc=case69_16m;
    mpc.gen(13,6)=mpc.gen(13,6)+i*scale_V;
    [RESULTS1, ~] =runpf(mpc,mpopt);
    bus1=RESULTS1.bus;
    branch1=RESULTS1.branch;
    gen1=RESULTS1.gen;
    Ybus1 = makeYbus(baseMVA, bus1, branch1);
    Ybus1=full(Ybus1);
    [Ploss,~,~]= get_losses(baseMVA, bus1, branch1);
    genP=sum(gen1(:,2),'all');
    eff13_voltage(i,1)=(genP-real(sum(Ploss)))*100/genP;
end

eff12_P=zeros(iter,1);
for i=1:iter
    mpc=case69_16m;
    mpc.gen(12,2)=mpc.gen(12,2)+i*scale_P;
    [RESULTS1, ~] =runpf(mpc,mpopt);
    bus1=RESULTS1.bus;
    branch1=RESULTS1.branch;
    gen1=RESULTS1.gen;
    Ybus1 = makeYbus(baseMVA, bus1, branch1);
    Ybus1=full(Ybus1);
    [Ploss,~,~]= get_losses(baseMVA, bus1, branch1);
    genP=sum(gen1(:,2),'all');
    eff12_P(i,1)=(genP-real(sum(Ploss)))*100/genP;
end

eff12_voltage=zeros(iter,1);
for i=1:iter
    mpc=case69_16m;
    mpc.gen(12,6)=mpc.gen(12,6)+i*scale_V;
    [RESULTS1, ~] =runpf(mpc,mpopt);
    bus1=RESULTS1.bus;
    branch1=RESULTS1.branch;
    gen1=RESULTS1.gen;
    Ybus1 = makeYbus(baseMVA, bus1, branch1);
    Ybus1=full(Ybus1);
    [Ploss,~,~]= get_losses(baseMVA, bus1, branch1);
    genP=sum(gen1(:,2),'all');
    eff12_voltage(i,1)=(genP-real(sum(Ploss)))*100/genP;
end


fig=figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf, 'PaperPositionMode', 'auto');
yyaxis left
plot(1:iter,eff13_P,'--r','linewidth',3);
hold on 
plot(1:iter,eff12_P,'*-r','linewidth',3)
ylabel('recursive of active power');
[max_P, max_P_Idx] = findpeaks(eff13_P);
text(max_P_Idx,max_P,sprintf('Peak = %5.3f', max_P),'FontSize',20);
[max_P, max_P_Idx] = findpeaks(eff12_P);
text(max_P_Idx,max_P,sprintf('Peak = %5.3f', max_P),'FontSize',20);
yyaxis right
plot(1:iter,eff13_voltage,'--g','linewidth',3);
hold on
plot(1:iter,eff12_voltage,'*-g','linewidth',3);
ylabel('recursive of voltage magnitude');
[max_V, max_V_Idx] = findpeaks(eff13_voltage);
text(max_V_Idx,max_V,sprintf('Peak = %5.3f', max_V),'FontSize',20);
[max_V, max_V_Idx] = findpeaks(eff12_voltage);
text(max_V_Idx,max_V,sprintf('Peak = %5.3f', max_V),'FontSize',20);
grid minor
legend('P-eff of machine 13','P-eff of machine 12','V-eff of mahcine 13','V-eff of mahcine 12','location','northwest');
xlabel('iteration');
ax = gca;
ax.YAxis(1).Color = 'r';
ax.YAxis(2).Color = 'g';
ax.GridColor='k';
set(ax,'fontsize',25,'linewidth',2);
print('report\Fig\comp','-dpng');