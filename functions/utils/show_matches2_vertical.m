function [ h ] = show_matches2_vertical( I1, I2, showkeys )
%SHOW_MATCHES この関数の概要をここに記述
%   詳細説明をここに記述


if size(I1, 3) == 3
    I1 = rgb2gray(I1);
end
if size(I2, 3) == 3
    I2 = rgb2gray(I2);
end

[I1ylen, I1xlen] = size(I1);
[I2ylen, I2xlen] = size(I2);

blackxlen = I2xlen - I1xlen;
%cat image
if I1xlen <= I2xlen
    black = uint8(zeros(I1ylen, blackxlen));
    I1 = cat(2, I1, black);
    horiblack = zeros(10, size(I1, 2));
else
    black = uint8(zeros(I2ylen, -blackxlen));
    I2 = cat(2, I2, black);
    horiblack = zeros(10, size(I2, 2));
end
catI = cat(1, I1, horiblack, I2);
hori_vert = size(catI, 1) / size(catI, 2);

h = figure();
imagesc(catI);
colormap(gray);
set(gca, 'Position', [0 0 1 1]);
set(gcf, 'Position', [0 0 800/hori_vert 800]);
grid off;
axis equal tight;
axis off;
hold on;

%plot matches
style = length(showkeys);
for s = 1:1:style
    x1 = showkeys(s).x1;
    y1 = showkeys(s).y1;
    x2 = showkeys(s).x2;
    y2 = showkeys(s).y2 + I1ylen + 10;
    
    mh = scatter([x1'; x2'], [y1'; y2']);
    set(mh, 'MarkerEdgeColor', showkeys(s).color, 'MarkerFaceColor', showkeys(s).facecolor, 'SizeData', showkeys(s).markersize);
    
    lh = line([x1; x2], [y1; y2]);
    set(lh, 'Color', showkeys(s).color, 'LineStyle', showkeys(s).linestyle, 'LineWidth', showkeys(s).linewidth);
    
end


end

