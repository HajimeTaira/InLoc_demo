%[ P, inls ] = ht_simple_ransac_p3p( u, X, rthr, maxiter )
%u: 3 x n image points
%X: 3 x n 3D points
%rthr: inlier threshold
%maxiter: default=1000

function [ P, inls ] = ht_simple_ransac_p3p( u, X, rthr, max_iter )
if nargin < 4
    max_iter = 1000;
end

%initialization
u = bsxfun(@rdivide, u, sqrt(sum(u.^2, 1)));
Npts = size(u, 2);
rthr = cos(rthr);
max_inlsnum = 3;
no_iter = 0;
P = [];
inls = false(1, Npts);
%ransac
while no_iter < max_iter
    no_iter = no_iter + 1;
    
    idx = randperm(Npts, 3);
    P_cand = P3PSolver([u(:, idx); X(:, idx)]);
    [inls_cand, inls_cand_num] = calculate_inls_angular(P_cand, u, X, rthr);
    if length(P_cand) > 1
        [inls_cand_num, inls_cand_idx] = max(inls_cand_num);
        inls_cand = inls_cand{inls_cand_idx};
        P_cand = P_cand{inls_cand_idx};
    else
        inls_cand_num = inls_cand_num(1);
        inls_cand = inls_cand{1};
        P_cand = P_cand{1};
    end
    
    
    if inls_cand_num >= max_inlsnum
        max_inlsnum = inls_cand_num;
        P = P_cand;
        inls = inls_cand;
        max_iter = min([max_iter, nsamples(max_inlsnum, Npts, 3, 0.95)]);
    end
    
end


end


function [SampleCnt, q] = nsamples(ni, ptNum, pf, conf)
    q  = prod (((ni-pf+1) : ni) ./ ((ptNum-pf+1) : ptNum));
    if q < eps
      SampleCnt = Inf;
    else
      %   SampleCnt  = log(1 - conf) / log(1 - q);
      if q > conf
        SampleCnt = 1;
      else
        SampleCnt  = log(1 - conf) / log(1 - q);
      end
    end
end

function [inls, inls_num] = calculate_inls_angular(Pcand, u, X, rthr)
    inls = cell(1, length(Pcand));
    inls_num = zeros(1, length(Pcand));
    for ii = 1:1:length(Pcand)
        X_reproj = Pcand{ii} * [X; ones(1, size(X, 2))];
        X_reproj = bsxfun(@rdivide, X_reproj, sqrt(sum(X_reproj.^2, 1)));

        res = sum(u .* X_reproj, 1);
        inls{ii} = res > rthr;
        inls_num(ii) = sum(inls{ii});
    end
    
end
