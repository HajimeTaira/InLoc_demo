function [ RGBpersp, XYZpersp ] = ht_Points2Persp( RGB, XYZ, P, H, W )
%RGB, XYZ: 3*(#Number of Points)
%P = K * [R, t]
%H, W: size of output perspective

%outputs
RGBpersp = nan(H, W, 3);
XYZpersp = nan(H, W, 3);

%XYZ->image coordinate
UV = P * [XYZ; ones(1, size(XYZ, 2))];
UV_norm = UV(3, :);
UV = bsxfun(@rdivide, UV(1:2, :), UV_norm);

% keyboard;

front_idx = UV_norm > 0;
UV = UV(:, front_idx);
RGB = RGB(:, front_idx);
XYZ = XYZ(:, front_idx);
UV_norm = UV_norm(front_idx);

visible_idx = UV(1, :) >= 0 & UV(2, :) >= 0 & UV(1, :) < W & UV(2, :) < H;
UV = UV(:, visible_idx);
RGB = RGB(:, visible_idx);
XYZ = XYZ(:, visible_idx);
UV_norm = UV_norm(visible_idx);

% UV= 1 + uint16(UV);
% UV = UV(:, UV_norm>0);
% UV_norm = UV_norm(UV_norm>0);
% RGB = RGB(:, UV_norm>0);
% XYZ = XYZ(:, UV_norm>0);
% 
% UV = UV(:, UV(1, :) <=W & UV(2, :) <= H);
% UV_norm = UV_norm(UV(1, :) <=W & UV(2, :) <= H);
% RGB = RGB(:, UV(1, :) <=W & UV(2, :) <= H);
% XYZ = XYZ(:, UV(1, :) <=W & UV(2, :) <= H);

% keyboard;

%rendering
UV = 1 + uint16(floor(UV));
check_norm = ones(H, W) * max(UV_norm);
for pp = 1:1:size(UV, 2)
    if UV_norm(pp) <= check_norm(UV(2, pp), UV(1, pp))
        RGBpersp(UV(2, pp), UV(1, pp), 1) = RGB(1, pp);
        RGBpersp(UV(2, pp), UV(1, pp), 2) = RGB(2, pp);
        RGBpersp(UV(2, pp), UV(1, pp), 3) = RGB(3, pp);
        XYZpersp(UV(2, pp), UV(1, pp), 1) = XYZ(1, pp);
        XYZpersp(UV(2, pp), UV(1, pp), 2) = XYZ(2, pp);
        XYZpersp(UV(2, pp), UV(1, pp), 3) = XYZ(3, pp);
        check_norm(UV(2, pp), UV(1, pp)) = UV_norm(pp);
    end
end

RGBpersp = uint8(RGBpersp);



end

