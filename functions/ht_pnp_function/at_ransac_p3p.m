% [p,inl,res,L] = ransacfit(x,model,maxres,smpls,smpln[,doLO,cnstr]) - Ransac fitting
%
% x         ... data - structure depends on the model, see the function
%                      implementation
% model     ... {'line','line-cnstr-seg','plane','conic','3Dpts','E5ptNister','P3PSolver','uX2PSolver'}
% maxres    ... maximal residual to vote
% smpls     ... sample size 0    = minimal sample
%                          (0,1) = percentile from the size of data
%                           >=1  = number of point in the samples
% smpln     ... number of samples
% doLO      ... {0,1} do local optimization (0 implicit)
% cnstr     ... constraint parameters
%               'line-cnstr-seg' ... cnstr = [x1 x2], such that x1 resp. x2
%                                                     is on the left resp. right
%                                                     from the line
% p         ... model parameters
% inl       ... inliers
% res       ... residuals for the model p
% L         ... fitting structure L{i} = output at the i-th improvement
%
% Example: >>ransacfit;

% T.Pajdla, pajdla@cmp.felk.cvut.cz
% 2015-07-11
function [p,inl,r,L] = at_ransac_p3p(x,maxres,smpls,smpln,doLO,bop)
if nargin>0 %% Fit
  if nargin<6, cnstr = []; end
  if nargin<5, doLO = false; end % implicitly do not use the local optimization
  %% model independent sample size
  % percentile from the data lengths
  if smpls >0 && smpls <1, smpl = max(2,ceil(length(x)*smpls)); end
  %         case 'P3PSolver'
  % x is struct containing
  % x.K = camera calibration matrix
  % x.iK = inversion of the camera calibration matris
  % x.x = [u;X] ... stacked hom coordis of image points & coords of 3D points
  if smpls == 0, smpl = 3; end % the minimal case
  if smpls>=3, smpl = smpls; end  % enforce the number of samples
  fitF = @P3PSolver; % 4pt absolute pose
  resF = @PerspRepErr; % residual function
  fitDataF = @P3PSolverFitImPoints; % original data
  resDataF = @E5ptResImPoints; % original data
  cnstr = x.K;
  
  % check if the sample size has been assigned
  if ~exist('smpl','var'), error('ransacfit: invalid sample size for smpls = %s',smpls); end
  %% RANSAC
  % prepare method depndent data from fitting and evaluation
  xf = fitDataF(x);
  xr = resDataF(x);
  % do ransac
  si = round((size(xf,2)-1)*rand(smpl,smpln)+1); % samples in the columns
  iN = 0;
  p = [];
  inl = [];
  r = [];
  k = 1;
  for i = si
    y = xf(:,i); % get a sample
    pf = fitF(y); % fit a model
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
    if in>iN % larger support
      if doLO % local optimization
        y = xf(:,il); % get all inliers
        
%         po = fitF(y); % fit a model
        
        bop.constant_points = ones(1,sum(il));
        [uout,Kout,Rout,Cout,Xout,eout] = uPXBA_({y(1:2,:)},{pf},y(4:6,:),bop);
        po{1} = [Rout{1} -Rout{1}*Cout{1}];
        
        ro = resF(po,xr,cnstr); % eval residuals & constraints
        ilo = abs(ro)<=maxres; % inliers
        if size(ilo,1)>1 % there are more alternative models returned by fitF
          ino = sum(ilo,2); % inlier #
          [ino,ix] = max(ino);
          ilo = ilo(ix,:); % select the best inliers
          ro = ro(ix,:); % select the residuals
          po = po{ix}; % select the best model
        else
          ino = sum(ilo); % inlier #
        end
        if ino>in % an improvement
          p = po; r = ro; il = ilo; in = ino;
          fprintf('LO succeeded!\n');
        end
      end
      iN  = in;
      inl = il;
      p = pf;
      if nargout>3 % store the history
        L{k}.iN = iN; L{k}.p = p; L{k}.res = r; L{k}.inl = inl;
        k = k + 1;
      end
    end
  end
  % refit to all inliers (must return only one model!)
  if sum(inl)>0
    y   = xf(:,inl); % inliers
    p = fitF(y,p); % fit
    r = resF(p,xr,cnstr); % residuals
    inl = abs(r)<=maxres; % inliers
  else
    
  end
  if nargout>3 % store the history
    L{k}.iN = iN; L{k}.p = p; L{k}.res = r; L{k}.inl = inl;
  end
  
end


