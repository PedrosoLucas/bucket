function accuracy = compute_accuracy(u,y,n,g,A,total,accuracy,aux)

%recursive function that computes the accuracy (for classification problems). To call it, use accuracy = compute_accuracy(u,y,n,g), as the other input values are only used within the recursive loop

if nargin == 4
    labels = unique(y);
    g = length(labels);
    y_original = y;
    for i = 1:length(labels)
        y(y_original == labels(i)) = i;
    end
    y = double(y);
    accuracy = 0;
    total = 0;
    aux = 0;
    U = sparse(n,g);
    Y = sparse(n,g);
    for i = 1:g
        U(:,i) = u == i; %#ok<*SPRIX>
        Y(:,i) = y == i;
    end
    A = full(U'*Y);
end
total = total + aux;
if isempty(A)
    accuracy = max(total/n,accuracy);
else
    for k = 1:length(A)
        B = A;
        aux = B(1,k);
        B(:,k) = [];
        B(1,:) = [];
        if total + aux + sum(B,"all") > n*accuracy
            accuracy = compute_accuracy(u,y,n,g,B,total,accuracy,aux);
        end
    end
end
end