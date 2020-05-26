
if(CALCULATE_OSPA_METRIC == 1)
    X = X_k;
    Y = [simTarget1History(:,k), simTarget2History(:,k)];
    if(k >= simTarget3SpawnTime)
        Y = [Y, simTarget3History(:,k-simTarget3SpawnTime+1)];
    end

    metric = ospa_dist(X, Y, cutoff_c, order_p);
    metric_history = [metric_history, metric];
    
end