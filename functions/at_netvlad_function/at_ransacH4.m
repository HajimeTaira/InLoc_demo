function [H, inls] = at_ransacH4(x1, x2, tmax, tol, doLO, conf)

rng(43);

num_points = 4;
if nargin < 6
  conf = .95;     % in case, conf is not specified.
end;
len = size(x1,2);    % the maxinum number of points, i.e. "N" in PROSAC paper.
max_i = 4; % the number of inliers.

k_star = tmax;

t = 0;
H = [];
inls = [];

if len < 10, return; end;

x1h = x1;
x2h = x2;

x1h(end+1,:) = 1 ;
x2h(end+1,:) = 1 ;
  
S1 = centering(x1h) ;
S2 = centering(x2h) ;
x1call = S1 * x1h ;
x2call = S2 * x2h ;

while (t < k_star && t < tmax)
  t = t+1; 
    
  p_sample = randperm(len,num_points);
        
%   x1in = x1h(:,p_sample);
%   x2in = x2h(:,p_sample);
%   S1 = centering(x1in) ;
%   S2 = centering(x2in) ;
%   x1c = S1 * x1in ;
%   x2c = S2 * x2in ;  
  
  x1c = x1call(:,p_sample);
  x2c = x2call(:,p_sample);  
  
  M = [x1c, zeros(size(x1c)) ;
    zeros(size(x1c)), x1c ;
    bsxfun(@times, x1c,  -x2c(1,:)), bsxfun(@times, x1c,  -x2c(2,:))] ;
  if any(isnan(M(:))), continue; end;
  if any(isinf(M(:))), continue; end;  
  [H21,D] = svd(M,'econ') ;
  H21 = reshape(H21(:,end),3,3)' ;
  H21 = S2 \ H21 * S1 ;
  H21 = H21 ./ H21(end) ;
  
  x1p = H21 * x1h;
  x1p = [x1p(1,:) ./ x1p(3,:) ; x1p(2,:) ./ x1p(3,:)] ;
             
  dist2 = sum((x2 - x1p).^2,1) ;
  v = dist2 < tol^2;
  no_i = sum(v);
  
  if( max_i < no_i)
    if doLO && no_i > num_points
      bH = u2H([x2h(:,v); x1h(:,v)]);      
      bH = bH ./ bH(end);
      
      x1p = bH * x1h;
      x1p = [x1p(1,:) ./ x1p(3,:) ; x1p(2,:) ./ x1p(3,:)] ;
      bdist2 = sum((x2 - x1p).^2,1) ;
      bv = bdist2 < tol^2;
      no_ib = sum(bv);
      if no_ib > no_i
        no_i = no_ib;
        H21 = bH;
        v = bv;
      end;
    end;
    max_i = no_i;
    H = H21;
    inls = find(v);      
    k_star = min(k_star,nsamples(max_i, len, num_points, conf));    
  end;
end;

%SampleCnt calculates number of samples needed to be done
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
  end;
end;

% --------------------------------------------------------------------
function C = centering(x)
% --------------------------------------------------------------------d
T = [eye(2), - mean(x(1:2,:),2) ; 0 0 1] ;
x = T * x ;
S = [1 ./ std(x(1,:)) 0 0 ;
  0 1 ./ std(x(2,:)) 0 ;
  0 0 1] ;
C = S * T ;
