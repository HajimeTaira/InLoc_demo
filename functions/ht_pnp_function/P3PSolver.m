% P = P3PSolver(X[,P]) - Absolute Camera Pose Solver
%
% P        = Calibrated camera P =[R -R*C] matrix celarray
% X(1:3,:) = 3 x 3 points in image 1
% X(4:6,:) = 3 x 3 3D points

% T. Pajdla, pajdla@cmp.felk.cvut.cz, 2015-09-09
function P = P3PSolver(X,P)
if nargin>0
    if nargin<2 % slove for P3P
        try
            [R,C] = p3p(X(1:3,:),X(4:6,:));
            P = cell(size(C,2),1);
            for i=1:size(C,2)
                P{i} = [R(:,:,1) -R(:,:,1)*C(:,i)];
            end
        catch
            P = [];
        end
    end
else % unit tests
    P = true;
end
