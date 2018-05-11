function [H, inls] = at_prosac_p3p(x1, x2, udists, TN, TLmax, tol, doLO, conf)

num_points = 3;
if nargin < 7
  conf = .95;     % in case, conf is not specified.
end;
len = size(x1,2);    % the maxinum number of points, i.e. "N" in PROSAC paper.
max_i = 3; % the number of inliers.
k_star = TN;  % the maximum number for terminating iteration. "n*" in PROSAC paper.

t = 0;
n_sub = num_points; % the number of subset points corresponds to "n" in PROSAC paper.
Tn = prosac_avsamplen(num_points,len,TN); % compute the average sampling number Tn'.
n_star = len; % the number of sampling=iteration corresponds to "n*" in PROSAC paper.

if ~exist('prosac_ImnP3P.mat','file') %|| len > 20000
  Imn = zeros(1,len);
  %%%%adhoc = round(len*(1-conf));
  adhoc = 0;
  for ii = 1:num_points+adhoc
    Imn(ii) = len;
  end
  for ii = num_points+1+adhoc:len
    Imn(ii) = prosac_nonrandom(num_points,ii,conf,0.1,len);
    fprintf('%d\n',ii)
  end
else
  r = load('prosac_ImnP3P.mat');
  Imn = r.Imn; clear r;
end;

H = [];
inls = [];

[~, sindx] = sort(udists);
tmax = TLmax;

x1h = x1;
x2h = x2;

x1h(end+1,:) = 1 ;
x2h(end+1,:) = 1 ;
  





while (t < k_star && t < tmax)
  t = t+1; %msg(1,'%d\n',t);
  if (t == Tn(n_sub) && n_sub < n_star)
    n_sub = n_sub + 1;
  end
  
  p_sample = sindx(prosac_rsample(num_points,Tn,t,n_sub));
      
  x1in = x1h(:,p_sample);
  x2in = x2h(:,p_sample);
  
  y = [x1in; x2in];
  
  
  pf = P3PSolver(y);
  
  e = PerspRepErr(P,X,K)
  
%   y = xf(:,i); % get a sample
%   pf = fitF(y); % fit a model
  r  = resF(pf,xr,cnstr); % eval residuals & constraints
  il = abs(r)<=maxres; % inliers
  if size(il,1)>1 % there are more alternative models returned by fitF
    in = sum(il,2); % inlier #
    [in,ix] = max(in);
    il = il(ix,:); % select the best inliers
    r = r(ix,:); % select the residuals
    pf = pf{ix}; % select the best model
  else
    in = sum(il); % inlier #
    if ~isempty(pf)
      if iscell(pf)
        pf = pf{1};
      end
    end
  end
  
  
  S1 = centering(x1in) ;
  S2 = centering(x2in) ;
  x1c = S1 * x1in ;
  x2c = S2 * x2in ;  
  M = [x1c, zeros(size(x1c)) ;
    zeros(size(x1c)), x1c ;
    bsxfun(@times, x1c,  -x2c(1,:)), bsxfun(@times, x1c,  -x2c(2,:))] ;
  if any(isnan(M(:))), continue; end;
  if any(isinf(M(:))), continue; end;  
  [H21,D] = svd(M,'econ') ;
  H21 = reshape(H21(:,end),3,3)' ;
  H21 = S2 \ H21 * S1 ;
  H21 = H21 ./ H21(end) ;
  
%   H21 = u2H([x2h(:,p_sample); x1h(:,p_sample)]);
%   if isempty(H21), continue; end;
%   H21 = H21 ./ H21(end);
  
  x1p = H21 * x1h;
  x1p = [x1p(1,:) ./ x1p(3,:) ; x1p(2,:) ./ x1p(3,:)] ;
             
%   tol = th * sqrt(det(H21(1:2,1:2)));
  dist2 = sum((x2 - x1p).^2,1) ;
  v = dist2 < tol^2;
  no_i = sum(v);
  
  if( max_i < no_i)
    if doLO && no_i > 4
      bH = u2H([x2h(:,v); x1h(:,v)]);      
      bH = bH ./ bH(end);
      
      x1p = bH * x1h;
      x1p = [x1p(1,:) ./ x1p(3,:) ; x1p(2,:) ./ x1p(3,:)] ;
%       tol = th * sqrt(det(bH(1:2,1:2)));
      bdist2 = sum((x2 - x1p).^2,1) ;
      bv = bdist2 < tol^2;
      no_ib = sum(bv);
      if no_ib > no_i
        no_i = no_ib;
        H21 = bH;
        v = bv;
%         fprintf(1,'LO succeeded\n');
      end;
    end;
    max_i = no_i;
    H = H21;
    inls = find(v);
      
    %% STEP 6 maximality of iteration
    for cn = num_points:len
      Icn = sum(v(1:cn));
      kcn = nsamples(Icn, cn, num_points, conf);%msg(1,'kcn=%f\n',kcn);
      %                inlfrc = [inlfrc, Icn/cn];
      if cn < n_sub
        kcn = kcn - (t - Tn(cn));
      end;
      if Icn >= Imn(cn) && kcn < k_star
        n_star = cn;
        k_star = kcn;
      end;
    end;
    
%     k_star = nsamples(max_i, len, num_points, conf);
%     fprintf(1,'PROSAC(H) iter=%d, #inl=%d, k_star=%2.2f\n',t,max_i,k_star);
  end;
end;
% fprintf(1,'PROSAC(H) iter=%d, #inl=%d, k_star=%2.2f\n',t,max_i,k_star);

function urs_indx = prosac_rsample(m,Tn,t,n)
% prosac sampling
if Tn(n) > t
  tmp = randperm(n-1);
  urs_indx = [tmp(1:m-1),n];
else
  tmp = randperm(n-1);
  urs_indx = tmp(1:m);
  %msg(1,'why?\n');
end

function [SampleCnt, q] = nsamples(ni, ptNum, pf, conf)
%SampleCnt calculates number of samples needed to be done

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


function Imin = prosac_nonrandom(m,n,conf,beta,len)
% compute the Imin whch express the non-randomness.

phi = 1-conf;
ii = (m:n);
Rn(ii) = binopdf(ii-m,n-m,beta); % see Eq. (7) in PROSAC paper.
for j = m:n
  if sum(Rn(j:n)) < phi
    Imin = j; break;   % see Eq. (8) in PROSAC paper.
  else
      Imin = len;
  end
end
