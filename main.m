clear all; clc;

%% ==========Creating Ybus and solving load flow using MATPOWER==========
baseMVA = 100;
mpopt = mpoption('PF_ALG',1,'PF_MAX_IT_GS',20000); % '1' for 'NR','4' for 'GS'
[RESULTS1, SUCCESS] =runpf('case69_16m',mpopt);
bus1=RESULTS1.bus;
branch1=RESULTS1.branch;
gen1=RESULTS1.gen;
Ybus1_sp = makeYbus(baseMVA, bus1, branch1);
Ybus1=full(Ybus1_sp);
[Ploss,~,~]= get_losses(baseMVA, bus1, branch1);
genP=sum(gen1(:,2),'all');

%% =======================Verfiy the Ymatrix=============================
fb=branch1(:,1);
tb=branch1(:,2);
r=branch1(:,3);
x=branch1(:,4);
b=1i*branch1(:,5)/2;
tap=branch1(:,9);
z=r+1i*x;
y=1./z;
Y=zeros(69,69);
tap(tap==0)=1;

for k=1:88
    Y(fb(k),tb(k))=(Y(fb(k),tb(k))-y(k))/tap(k);
    Y(tb(k),fb(k))=Y(fb(k),tb(k));
end

for m=1:69
    for n=1:88
        if fb(n)==m 
            Y(m,m)=Y(m,m)+y(n)+b(n);
        elseif tb(n)==m          
            Y(m,m)=Y(m,m)+y(n)+b(n);
        end
    end
end
Y_sp=sparse(Y);

%%  =====Outputing the results to .xls and print in command window========
xlswrite('YMat.xlsx',num2str(Ybus1));
fprintf('The effiency is : %4.2f%% \n',(genP-real(sum(Ploss)))*100/genP);


input('Press enter to continue do the recursive about the active power');
%% ========Changing the generator data to reduce the loss========
iter=100;
scale_P=18;
scale_V=0.002;
eff_P=zeros(iter,1);

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
    eff_P(i,1)=(genP-real(sum(Ploss)))*100/genP;
end

input('Press enter to continue do the recursive about voltage magnitude');
eff_voltage=zeros(iter,1);
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
    eff_voltage(i,1)=(genP-real(sum(Ploss)))*100/genP;
end

fig=figure('units','normalized','outerposition',[0 0 1 1]);
set(gcf, 'PaperPositionMode', 'auto');
yyaxis left
plot(1:iter,eff_P,'--r','linewidth',3);
ylabel('recursive of active power');
[max_P, max_P_Idx] = findpeaks(eff_P);
text(max_P_Idx,max_P,sprintf('Peak = %5.3f', max_P)'FontSize',16);
yyaxis right
plot(1:iter,eff_voltage,'--g','linewidth',3);
ylabel('recursive of voltage magnitude');
[max_V, max_V_Idx] = findpeaks(eff_voltage);
text(max_V_Idx,max_V,sprintf('Peak = %5.3f', max_V),'FontSize',16);
grid minor
legend('P-eff','V-eff','location','northwest');
ax = gca;
ax.YAxis(1).Color = 'r';
ax.YAxis(2).Color = 'g';
ax.GridColor='k';
set(ax,'fontsize',20,'linewidth',2);
print('report\Fig\comp','-dpng');

clc
mpc=case69_16m;
max_P_13=mpc.gen(13,2)+max_P_Idx*scale_P;
max_V_13=mpc.gen(13,6)+max_V_Idx*scale_V;
PV_12=mpc.gen(12,[2 6]);
