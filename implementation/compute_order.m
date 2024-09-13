function [order,tried_orders] = compute_order(tried_orders,F,g,type)

%computes the order in which the clusters will be filled

switch type
    case "F_descend"
        [~,order] = sort(F,"descend");
        order = order';
        tried_orders = order;
    case "random"
        order = randperm(g);
        while ismember(order,tried_orders,'rows')
            order = randperm(g);
        end
        tried_orders = [tried_orders;order];      
end
end