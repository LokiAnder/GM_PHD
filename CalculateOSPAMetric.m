
function ospa = CalculateOSPAMetric(X, Y, cutoff_c, order_p)

    m = size(X, 2);%Length of vector X
    n = size(Y, 2);%Length of vector Y

    alphas = cutoff_c * ones(1, n);%Initialise to cutoff, overwrite if there is a shorter value
    bestOMATCost = -1;
    bestOMATDataAssoc_i = [];
    
    
    if(m > n)
        tmpX = X;
        tmpm = m;
        X = Y;
        m = n;
        Y = tmpX;
        n = tmpm;
    end
    if(m > 0)
        comboSize = m;
        valuesSampled = 1:n;
        allCombos = combnk(valuesSampled, comboSize);
        nCombos = size(allCombos, 1);
        
        
        for i = 1:nCombos
            thisCombo = allCombos(i,:);
            allDataAssocs = perms(thisCombo);
            nDataAssocs = size(allDataAssocs, 1);
            
            for j = 1:nDataAssocs
                thisDataAssoc = allDataAssocs(j,:);
                thisY = Y(:,thisDataAssoc);
                thisOMATCost = CalculateOMATMetric(X, thisY, order_p);

                if(bestOMATCost < 0) || (thisOMATCost < bestOMATCost) 
                    bestOMATCost = thisOMATCost;
                    bestOMATDataAssoc_i = thisDataAssoc;
                end
            end
        end
        
       
        for i = 1:m
           thisX = X(:,i);
           thisY = Y(:,bestOMATDataAssoc_i(i));
           alphas(i) = min(cutoff_c, norm(thisX - thisY) ^ order_p);
        end
      
        for i = 1:(n - m)
            alphas(m+i) = cutoff_c;
        end
        
    end
    alphasSum = sum(alphas) / n;
    ospa = alphasSum ^ (1/order_p);
end


function omat = CalculateOMATMetric(X, Y, order_p)
    m = size(X, 2);
    omat = 0;
    for i = 1:m
        thisX = X(:,i);
        thisY = Y(:,i);
        dx = thisX(1) - thisY(1);
        dy = thisX(2) - thisY(2);
        omat = omat + hypot(dx, dy) ^ order_p;
    end
    omat = omat / m;
    omat = omat ^ (1/order_p);
end