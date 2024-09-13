function p = priorization_matrix(d,g,order)

%computes the priorization matrix

p = zeros(size(d));
for k = 1:g-1
    i = order(k);
    groups = order(k+1:end);
    p(i,:) = min(d(groups,:),[],1)-d(i,:);
end
end