
s = sprintf('Step 6: Estimate target states');
disp(s);
X_k = [];
X_k_P = [];
X_k_w = [];

%OUTPUT_MULTIPLE_HIGH_WEIGHT_TARGETS is set in GM_PHD_Initialisation
if(OUTPUT_MULTIPLE_HIGH_WEIGHT_TARGETS == 0)
    i = find(w_bar_k > weightThresholdToBeExtracted);
    X_k = m_bar_k(:,i);
    X_k_w = w_bar_k(:,i);
    for j = 1:length(i)
        thisI = i(j);
        P_range = calculateDataRange4(thisI);

        thisP = P_bar_k(:,P_range);
        X_k_P = [X_k_P, thisP];
    end
else
    %If a target has a rounded weight greater than 1, output it multiple
    %times. VERBOSE must be set to 1 to see the effects of this.
    for i = 1:size(w_bar_k,2)
       for j = 1:round(w_bar_k(i))
            X_k = [X_k, m_bar_k(:,i)];
            X_k_w = [X_k_w, w_bar_k(i)];
            P_range = calculateDataRange4(i);
            thisP = P_bar_k(:,P_range);
            X_k_P = [X_k_P, thisP];
       end
    end
end

if(VERBOSE == 1)
    s = sprintf('\t%d targets beleived to be valid:', size(X_k, 2));
    disp(s);
    for i = 1:size(X_k, 2)
        P_range = calculateDataRange4(i);
       s = sprintf('\t\tTarget %d at %3.4f %3.4f, P %3.4f %3.4f, W %3.5f', i, X_k(1, i), X_k(2,i), X_k_P(1, P_range(1)), X_k_P(2, P_range(2)), X_k_w(i));
       disp(s);
    end
end

%Store history for plotting.
X_k_history = [X_k_history, X_k];