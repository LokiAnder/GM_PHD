

%%控制参数
noiseScaler = 1.0;       %控制噪声的强度
nClutter = 50; %假设有多少个杂波

%I haven't included descriptions of every variable because their names are
%fairly self-explanatory
endTime = 100;%Duration of main loop
simTarget1Start = birth_mean1;
simTarget2Start = birth_mean2;
simTarget1End = [500, -900]';
simTarget2End = [900, -500]';
simTarget3End = [-200, -750]';
simTarget1Vel = (simTarget1End - simTarget1Start(1:2)) / endTime;
simTarget2Vel = (simTarget2End - simTarget2Start(1:2)) / endTime;
%目标3的速度
simTarget3Vel = [-7; -4];
simTarget1Start(3:4) = simTarget1Vel;
simTarget2Start(3:4) = simTarget2Vel;
simTarget3Start(3:4) = simTarget3Vel;

%History arrays are mostly used for plotting.
simTarget1History = simTarget1Start;
simTarget2History = simTarget2Start;
simTarget3History = [];

simMeasurementHistory = {};%We use a cell array so that we can have rows of varying length.

simTarget1State = simTarget1Start;
simTarget2State = simTarget2Start;
simTarget3State = [];
%目标3的产生时间
simTarget3SpawnTime = 20;

%Set up for plot
%Measurements and targets plot
figure(1);
clf;
hold on;
axis([-1000 1000 -1000 1000]);
xlim([-1000 1000]);
ylim([-1000 1000]);

%X and Y measurements plot
xlabel('X position');
ylabel('Y position');
title('Simulated targets and measurements');
axis square;

figure(2);
subplot(2,1,1);
hold on;
axis([0 100 -1000 1000]);
xlabel('时间');
ylabel('在X轴上的位置 (m)');
title('量测在X轴上的关系');
subplot(2,1,2);
hold on;
axis([0 100 -1000 1000]);
xlabel('时间');
ylabel('在Y轴上的位置 (m)');
title('量测在Y轴上的关系');

%Performance metric plot
if(CALCULATE_OSPA_METRIC == 1)
    figure(3);
    clf;
    xlabel('Simulation step');
    ylabel('OSPA error metric (higher is worse)');
end