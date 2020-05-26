
s = sprintf('Step 3: Constructing update components for all targets, new and existing.');
disp(s);


eta = [];
S = [];
K = [];
P_k_k = [];

for j = 1:numTargets_Jk_k_minus_1
    m_j = mk_k_minus_1(:,j);
    eta_j = H2 * m_j;

    P_range = calculateDataRange4(j); 

    PHt = Pk_k_minus_1(:,P_range) * H2'; 

    
    S_j = R2 + H2 * PHt;
    
    SChol= chol(S_j);

    SCholInv= SChol \ eye(size(SChol)); 
    W1 = PHt * SCholInv;

    K_j = W1 * SCholInv';

    P_j = Pk_k_minus_1(:,P_range) - W1*W1';
    
    
    eta = [eta, eta_j];
    S = [S, S_j];
    K = [K, K_j];
    P_k_k = [P_k_k, P_j]; 
end