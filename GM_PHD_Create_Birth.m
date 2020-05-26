
disp('Step 7: Creating new targets from measurements, for birthing next iteration');
w_birth = [];
m_birth = [];
P_birth = [];
w_spawn = [];
m_spawn = [];
P_spawn = [];
numBirthedTargets = 0;
numSpawnedTargets = 0;

if((addVelocityForNewTargets == true) && (k >= 2))%If we want to add targets with initial velocities.If only one iteration complete, cannot calculate velocity
    %Each measurement consists of 2 rows
    thisMeasRowRange = k;
    prevMeasRowRange = k-1;

    thisMeas = simMeasurementHistory{thisMeasRowRange};
    prevMeas = simMeasurementHistory{prevMeasRowRange};
    
    for j_this = 1:size(thisMeas,2)            
        for j_prev = 1:1:size(prevMeas,2)
            m_this = thisMeas(:,j_this);
            m_prev = prevMeas(:, j_prev);
            %计算并增加新的目标向量.
            m_i = m_this;
            thisV = (m_this(1:2) - m_prev(1:2)) / dt;
            if(abs(thisV(1)) > MAX_V) || (abs(thisV(2)) > MAX_V)
                continue;%为了减少添加的目标数量，我们通过限定监视区内产生目标的数量过滤掉了目标。
            end

            m_i = [m_i; thisV];

            %确定目标是否已新生（从新生位置开始）或从现有目标生成初始化权重
            birthWeight = birth_intensity(m_i);
            %目标也可以是从现有的目标中衍生出来，而对于这种情况设定一个较高的权重
            nTargets = size(X_k, 2);
            maxSpawnWeight = -1;
            for targetI = 1:nTargets
                thisWeight = spawn_intensity(m_i, X_k(:,targetI)) * X_k_w(targetI);%Spawn weight is a function of proximity to the existing target, and the weight of the existing target.
                if(thisWeight > maxSpawnWeight)
                    maxSpawnWeight = thisWeight;
                end
            end
            %检查新生目标强度是否大于衍生目标权重.
            if(birthWeight > maxSpawnWeight)
                %如果是就是新生的目标
                w_i = birthWeight;
                %初始化协方差
                P_i = covariance_birth;
                w_birth = [w_birth, w_i];
                m_birth = [m_birth m_i];
                P_birth = [P_birth, P_i];
                numBirthedTargets = numBirthedTargets + 1;
            else
                %检测为衍生目标
                w_i = maxSpawnWeight;
                %初始化协方差
                P_i = covariance_spawn;
                w_spawn = [w_spawn, w_i];
                m_spawn = [m_spawn, m_i];
                P_spawn = [P_spawn, P_i];
                numSpawnedTargets = numSpawnedTargets + 1;
            end                
        end
    end
end


%If we want to add targets, treating them as if they are
%static.
if (addStaticNewTargets == true) 
    thisMeasRowRange = k;
    thisMeas = simMeasurementHistory{thisMeasRowRange};
    for j_this = 1:size(thisMeas,2)    %Each measurement consists of 2 rows

        %Add a static target
        m_i = thisMeas(:,j_this);
        m_i(3:4) = [0; 0];

        %Decide if the target is birthed (from birth position)
        %or spawned (from an existing target)
        %Initialise the weight to birth
        birthWeight = birth_intensity(m_i);
        %Targets can also spawn from existing targets. We will
        %take whichever is a higher weight - birthing or
        %spawning
        nTargets = size(X_k, 2);
        maxSpawnWeight = -1;
        for targetI = 1:nTargets
            thisWeight = spawn_intensity(m_i, X_k(:,targetI)) * X_k_w(targetI);%Spawn weight is a function of proximity to the existing target, and the weight of the existing target.
            if(thisWeight > maxSpawnWeight)
                maxSpawnWeight = thisWeight;
            end
        end
        %Check if birthing had higher weight.
        if(birthWeight > maxSpawnWeight)
            %Birth the target
            w_i = birthWeight;
            %Initialise the covariance
            P_i = covariance_birth;
            w_birth = [w_birth, w_i];
            m_birth = [m_birth m_i];
            P_birth = [P_birth, P_i];
            numBirthedTargets = numBirthedTargets + 1;
        else
            %Spawn the target
            w_i = maxSpawnWeight;
            %Initialise the covariance
            P_i = covariance_spawn;
            w_spawn = [w_spawn, w_i];
            m_spawn = [m_spawn m_i];
            P_spawn= [P_spawn, P_i];
            numSpawnedTargets = numSpawnedTargets + 1;
        end                 
    end
end

if VERBOSE == 1
    for j = 1:numBirthedTargets
        thisM = m_birth(:,j);
        s = sprintf('Target to birth %d: %3.4f %3.4f %3.4f %3.4f Weight %3.9f', j, thisM(1), thisM(2), thisM(3), thisM(4), w_birth(j));
        disp(s);
    end
    for j = 1:numSpawnedTargets
        thisM = m_spawn(:,j);
        s = sprintf('Target to spawn %d: %3.4f %3.4f %3.4f %3.4f Weight %3.9f', j, thisM(1), thisM(2), thisM(3), thisM(4), w_spawn(j));
        disp(s);
    end
end
