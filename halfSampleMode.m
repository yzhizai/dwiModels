function hsm = halfSampleMode(X)
% calculates the half sample mode for each row in X

if ~ismatrix(X)
    error('X must be a matrix or vector');
end

X = sort(X,2);
n = size(X,2);

hsm = HSM_rec(n,X);

function hsm = HSM_rec(n,X)

% special cases
if size(X,2) == 1
    hsm = X;
    return;
elseif size(X,2) == 2
    hsm = sum(X,2)/2;
    return;
elseif size(X,2) == 3   
    hsm = zeros(size(X,1),1);
    low = (X(:,2) - X(:,1)) < (X(:,3) - X(:,2)); % use lower pair
    eq = (X(:,2) - X(:,1)) == (X(:,3) - X(:,2)); % use mid value
    
    if any(low)
        hsm(low) = sum(X(low,1:2),2)/2;
    end
    if any(eq)
        hsm(eq) = X(eq,2);
    end
    if any(~(low|eq))
        hsm(~(low|eq)) = sum(X(~(low|eq),2:3),2)/2; % otherwise
    end
    return
end

% general case (n > 3)
wmin = X(:,end) - X(:,1);
N = ceil(n/2);
j = ones(size(X,1),1);
for i = 1:(n-N+1)
   w = X(:,i+N-1) - X(:,i);
   m = w < wmin;
   wmin(m) = w(m);
   j(m) = i;
end
rowsub = repmat((1:size(X,1))',1,N);
colsub = repmat(j,1,N) + repmat(0:N-1,size(X,1),1);

Xsub = reshape(X(sub2ind(size(X),rowsub,colsub)),size(X,1),N);
hsm = HSM_rec(N,Xsub);
