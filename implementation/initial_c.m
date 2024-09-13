function c = initial_c(x,g)

%function that computes the initial centroids

aux = prctile(x,[25 75]) + 1.5*[-1;1]*iqr(x);
minimum = max(aux(1,:),min(x,[],1));
maximum = min(aux(2,:),max(x,[],1));
c = minimum + rand(g,size(x,2)).*(maximum-minimum);