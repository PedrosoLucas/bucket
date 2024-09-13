function generate_figure(g,x,c,u,z)

%generates a figure for the final clustering found by bucket_algorithm.
%If m > 2, only the first two features are depicted.

figure

palette = [0 0 255 %blue
    255 0 0 %red
    0 192 0 %green
    128 0 255 %violet
    255 192 0 %orange
    0 255 255 %cyan
    255 0 255 %pink
    255 255 0 %yellow
    192 192 192 %gray
    0 255 0]; %light green
if g > 10 %if there are more than 10 groups, get a random pallete
    all_colors = unique(nchoosek(repelem(0:64:256,3),3),"rows");
    all_colors(all_colors == 256) = 255;
    all_colors = setdiff(all_colors,[0 0 0;255 255 255;palette],"rows");
    try
        palette(11:g,:) = all_colors(randperm(g,g-10),:);
    catch
        return
    end
else
    palette = palette(1:g,:);
end
palette = palette/255;

if isempty(find(z ~= 1,1))
    point_sizes = 40;
else
    point_sizes = 10+60*(z-min(z))/(max(z)-min(z));
end

scatter(x(:,1),x(:,2),point_sizes,palette(u,:),"filled");
hold on
scatter(c(:,1),c(:,2),300,palette,"filled","p","markeredgecolor","k");
axis equal
window = [max(x(:,1))-min(x(:,1)) max(x(:,2))-min(x(:,2))];
window = max(window,1e-1);
window = [min(x(:,1))-0.05*window(1) max(x(:,1))+0.05*window(1) min(x(:,2))-0.05*window(2) max(x(:,2))+0.05*window(2)];
axis(window)
end