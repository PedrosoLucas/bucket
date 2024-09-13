function [u,c,f,time,accuracy] = bucket_algorithm(x,g,z,mu,y)

%This is the main file of the implementation of the algorithm proposed in 

%K.A. Benatti, J.V. Pamplona, L.G. Pedroso and A.A. Ribeiro,
%An approach to the clustering problem with capacity constraints.

%==========
%Input data
%==========

% x: a matrix where each row represents one of the n points in the dataset.
% g: the number of groups.
% z: a vector where each entry represents the weight of the corresponding
    % point. If absent, z_j will be set as 1.
% mu: Mu is a vector where each entry represents the capacity of the 
    %corresponding group. If absent, and if all z_j = 1, then mu_i will be 
    %set as n/g (rounded up or down so that sum(mu_i) = sum(z_j)).
    %Otherwise, if not all z_j = 1, mu_i will be set as sum(z_j)/g.
% y: a vector where each entry represents the label of the corresponding
    %point. It only makes sense in classification problems.
% max_time: the time budget in seconds. If absent, max_time is set to 1800.

%===========
%Output data
%===========

% u: a vector where each entry is the group of the corresponding point.
% c: a matrix where each line contains the coordinates of the corresponding
    %centroid.
% f: the objective function (SSE) at the solution found.
% time: elapsed time in seconds.
% accuracy: accuracy found. Only applies if y is provided.

%==========
%Parameters
%==========

extra_trials = true; %true if additional iterations with randomized orders are meant to be attempted when failing to decrease the objective function
display_figure = true; %true if a graphic output is required. Only applies if the data is in R^2

%==============
%Inicialization
%==============

n = size(x,1);
if extra_trials %(ntrials-1) is the number of trials with random order sets when failing in decrease the objective function
    ntrials = min([factorial(g) g^2 50]); %#ok<*UNRCH>
else
    ntrials = 1;
end
if ~exist("z","var") || isempty(z)
    z = ones(n,1);
elseif length(z) ~= n
    error("length(z) must be equal to size(x,1).")
end
if ~exist("mu","var") || isempty(mu)
    if sum(z == 1) == n
        mu = floor(n*ones(g,1)/g);
        mu = mu + ((1:g)' <= n-sum(mu));
    else
        mu = sum(z)/g*ones(g,1);
    end
else
    if sum(z) ~= sum(mu)
        error("sum(z) must be equal to sum(mu).")
    end
    if length(mu) ~= g
        error("length(mu) must be equal to g.")
    end
end

c = initial_c(x,g); %the first centroids are randomly obtained

order = randperm(g); %first order is random
tried_orders = order;
it1 = 0; %iteration counter
exit1 = false; %if true, end the algorithm
F = zeros(g,1); %a vector where each entry is the contribution of the corresponding group to the objective function
f = inf;

d = zeros(g,n); %a matrix where d_ij is the distance between centroid c_i and point x_j
for i = 1:g
    d(i,:) = sum((c(i,:)-x).^2,2)';
end
c_trial = zeros(size(c));
d_trial = zeros(size(d));

start = tic;
while ~exit1
    it1 = it1 + 1;
    it2 = 0; %inner iteration counter
    exit2 = false; %if true, end the inner iteration
    while ~exit2
        it2 = it2 + 1;
        p = priorization_matrix(d,g,order); %compute the priorization matrix
        u_trial = perform_attributions(g,n,order,mu,z,p); %distribute the points to the clusters
        for i = 1:g
            c_trial(i,:) = mean(x(u_trial == i,:)); %compute the new centroids candidates
            d_trial(i,:) = sum((c_trial(i,:)-x).^2,2)';
            F(i) = sum(d_trial(i,u_trial == i));
        end
        f_trial = sum(F);
        if f_trial < f %if the objective function reduced
            c = c_trial; %accept the new centroids
            d = d_trial;
            u = u_trial; %accept the new atributions to the clusters
            f = f_trial;
            [order,tried_orders] = compute_order(tried_orders,F,g,"F_descend"); %compute the order for the next iteration
            exit2 = true; %end the inner iteration
        elseif it2 < ntrials %if the objective function did not reduce and there are trials left
            [order,tried_orders] = compute_order(tried_orders,F,g,"random"); %compute a random order for the next inner iteration
        else %otherwise, end the algorithm (can't reduce the objective function)
            exit1 = true;
            exit2 = true;
        end
    end  
end
time = toc(start);

if exist("y","var") && ~isempty(y) %compute accuracy (for classification problems)
    accuracy = compute_accuracy(u,y,n,g);
else
    accuracy = [];
end

if display_figure %display figure
    generate_figure(g,x,c,u,z);
end
end