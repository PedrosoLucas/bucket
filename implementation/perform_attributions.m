function u = perform_attributions(g,n,order,mu,z,p)

%allocates each point to a cluster

u = order(g)*ones(n,1);
remainder = 0;
for k = 1:g-1
    i = order(k);
    [~,indices] = sort(p(i,:),'descend');
    total = 0;
    counter = 1;
    while (total + z(indices(counter)) <= mu(i) + remainder) && p(i,indices(counter)) > -inf
        total = total + z(indices(counter));
        u(indices(counter)) = i;
        p(:,indices(counter)) = -inf;
        counter = counter + 1;
    end
    remainder = remainder + mu(i) - total;
    p(i,:) = -inf;
end
end