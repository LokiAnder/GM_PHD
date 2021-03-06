
s = sprintf('Step Sim: Simulating measurements.');
disp(s);

%仿真实际目标的移动
%每一次迭代运行时计算当前的状态
simTarget1State = F * simTarget1State;
simTarget2State = F * simTarget2State;
%第三个目标如果存在时计算当前的状态
if(~isempty(simTarget3State))
    simTarget3State = F * simTarget3State;
end
%新生目标3当k为simTarget3spawnTime时产生
if(k == simTarget3SpawnTime)
    %simTarget3State = simTarget1State;%当进行衍生目标的实验时使用该段代码
    simTarget3State = [240;364;-7;-4]
    simTarget3State(3:4) = simTarget3Vel;
end

%保存目标的行径历史用于plot
simTarget1History = [simTarget1History, simTarget1State];
simTarget2History = [simTarget2History, simTarget2State];
simTarget3History = [simTarget3History, simTarget3State];

%生成噪声
clutter = zeros(2,nClutter);%所有的量测都被限制在[x,y]这个范围内
for i = 1:nClutter
    clutterX = rand * (xrange(2) - xrange(1)) + xrange(1); %Random number between xrange(1) and xrange(2), uniformly distributed.
    clutterY = rand * (yrange(2) - yrange(1)) + yrange(1); %Random number between yrange(1) and yrange(2), uniformly distributed.
    
    clutter(1,i) = clutterX;
    clutter(2,i) = clutterY;
end

%因为实际情况下无法保证一定能够探测到目标，所以将量测值转换为概率密度

detect1 = rand;
detect2 = rand;
detect3 = rand;

if(detect1 > prob_detection)
    measX1 = [];
    measY1 = [];
else
    measX1 = simTarget1State(1) + sigma_r * randn * noiseScaler;
    measY1 = simTarget1State(2) + sigma_r * randn * noiseScaler;
end
if(detect2 > prob_detection)
    measX2 = [];
    measY2 = [];
else
    measX2 = simTarget2State(1) + sigma_r * randn * noiseScaler;
    measY2 = simTarget2State(2) + sigma_r * randn * noiseScaler;
end

if(k >= simTarget3SpawnTime) && (detect3 <= prob_detection)
    measX3 = simTarget3State(1) + sigma_r * randn * noiseScaler;
    measY3 = simTarget3State(2) + sigma_r * randn * noiseScaler;
else
    measX3 = [];
    measY3 = [];
end

%产生实际的量测数据集
Z = [ [measX1 measX2 measX3]; [measY1 measY2 measY3] ];
zTrue = Z;%Store for plotting

%添加噪声
Z = [Z, clutter];
if(~isempty(simTarget3State))
    fake_x=[fake_x,measX3]
    fake_y=[fake_y,measY3]
end
%存储量测历史
simMeasurementHistory{k} =  Z;