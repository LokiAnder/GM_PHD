
s = sprintf('Step 1: Prediction for birthed and spawned targets.');
disp(s);

m_birth_before_prediction = [m_birth, m_spawn]; %Need to store these BEFORE prediction for use in the update step.

%Perform prediction for birthed targets using birthed velocities.
for j = 1:numBirthedTargets
    i = i + 1;
    %w_birth was already instantiated in GM_PHD_Create_Birth
    m_birth(:,j) = F * m_birth(:,j);
    P_range = calculateDataRange4(j); 
    P_birth(:,P_range) = Q + F * P_birth(:,P_range) * F';
end
%Perform prediction for spawned targets using spawned velocities.
for j = 1:numSpawnedTargets
    i = i + 1;
    %w_spawn was already instantiated in GM_PHD_Create_Birth
    m_spawn(:,j) = F * m_spawn(:,j);
    P_range = calculateDataRange4(j); 
    P_spawn(:,P_range) = Q + F * P_spawn(:,P_range) * F';
end

if(VERBOSE == 1)
  for j = 1:numBirthedTargets
        thisM = m_birth(:,j);
        s = sprintf('Birthed target %d: %3.4f %3.4f %3.4f %3.4f Weight %3.9f', j, thisM(1), thisM(2), thisM(3), thisM(4), w_birth(j));
        disp(s);      
  end
  for j = 1:numSpawnedTargets
        thisM = m_spawn(:,j);
        s = sprintf('Spawned target %d: %3.4f %3.4f %3.4f %3.4f Weight %3.9f', j, thisM(1), thisM(2), thisM(3), thisM(4), w_spawn(j));
        disp(s);      
   end
end
