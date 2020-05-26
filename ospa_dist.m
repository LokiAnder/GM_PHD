
function [dist varargout]= ospa_dist(X,Y,c,p)


if nargout ~=1 & nargout ~=3
   error('Incorrect number of outputs'); 
end

if isempty(X) & isempty(Y)
    dist = 0;

    if nargout == 3
        varargout(1)= {0};
        varargout(2)= {0};
    end
    
    return;
end

if isempty(X) | isempty(Y)
    dist = c;

    if nargout == 3
        varargout(1)= {0};
        varargout(2)= {c};
    end
    
    return;
end


%Calculate sizes of the input point patterns
n = size(X,2);
m = size(Y,2);

%Calculate cost/weight matrix for pairings - fast method with vectorization
XX= repmat(X,[1 m]);
YY= reshape(repmat(Y,[n 1]),[size(Y,1) n*m]);
D = reshape(sqrt(sum((XX-YY).^2)),[n m]);
D = min(c,D).^p;

% %Calculate cost/weight matrix for pairings - slow method with for loop
% D= zeros(n,m);
% for j=1:m
%     D(:,j)= sqrt(sum( ( repmat(Y(:,j),[1 n])- X ).^2 )');
% end
% D= min(c,D).^p;

%Compute optimal assignment and cost using the Hungarian algorithm
[assignment,cost]= Hungarian(D);

%Calculate final distance
dist= ( 1/max(m,n)*( c^p*abs(m-n)+ cost ) ) ^(1/p);

%Output components if called for in varargout
if nargout == 3
    varargout(1)= {(1/max(m,n)*cost)^(1/p)};
    varargout(2)= {(1/max(m,n)*c^p*abs(m-n))^(1/p)};
end
    