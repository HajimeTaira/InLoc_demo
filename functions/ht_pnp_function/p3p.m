% [R,C,f,cs] = p3p(u,x[,d]) - P3P problems (regular case)
%
% u = 3 x 3 matrix of image projections
% x = 3 x 3 matrix of 3D points stored as columns
% d = {0,1} debug plot flag
% R = 3 x 3 x n matrix of n camera rotations
% C = 3 x n matrix of camera centers
% f = handles to debug plots
% cs = case used A=1,B1=2,B21=3,B22=4

% pajdla@cmp.felk.cvut.cz
% 2010-03-19
function [R,C,f,cs] = p3p(x,X,dbg)

teps = 1e-9; % equations satisfaction tollerance

if nargin>0
    if nargin<3
        dbg = 0;
    end
    % projection normalization
    x = x./([1;1;1]*sqrt(sum(x.^2)));
    % cosines of angles
    c12 = x(:,1)'*x(:,2);
    c23 = x(:,2)'*x(:,3);
    c31 = x(:,3)'*x(:,1);
    % distances between points
    d12 = sqrt(sum((X(:,2)-X(:,1)).^2));
    d23 = sqrt(sum((X(:,2)-X(:,3)).^2));
    d31 = sqrt(sum((X(:,3)-X(:,1)).^2));
    % Case A
    % remember original values of s and t, which replace x and y
    b4 = -4*d23^4*d12^2*d31^2*c23^2+d23^8-2*d23^6*d12^2-2*d23^6*d31^2+d23^4*d12^4+2*d23^4*d12^2*d31^2+d23^4*d31^4;
    b3 = 8*d23^4*d12^2*d31^2*c12*c23^2+4*d23^6*d12^2*c31*c23-4*d23^4*d12^4*c31*c23+4*d23^4*d12^2*d31^2*c31*c23-4*d23^8*c12+4*d23^6*d12^2*c12+8*d23^6*d31^2*c12-4*d23^4*d12^2*d31^2*c12-4*d23^4*d31^4*c12;
    b2 = -8*d23^6*d12^2*c31*c12*c23-8*d23^4*d12^2*d31^2*c31*c12*c23+4*d23^8*c12^2-4*d23^6*d12^2*c31^2-8*d23^6*d31^2*c12^2+4*d23^4*d12^4*c31^2+4*d23^4*d12^4*c23^2-4*d23^4*d12^2*d31^2*c23^2+4*d23^4*d31^4*c12^2+2*d23^8-4*d23^6*d31^2-2*d23^4*d12^4+2*d23^4*d31^4;
    b1 = 8*d23^6*d12^2*c31^2*c12+4*d23^6*d12^2*c31*c23-4*d23^4*d12^4*c31*c23+4*d23^4*d12^2*d31^2*c31*c23-4*d23^8*c12-4*d23^6*d12^2*c12+8*d23^6*d31^2*c12+4*d23^4*d12^2*d31^2*c12-4*d23^4*d31^4*c12;
    b0 = -4*d23^6*d12^2*c31^2+d23^8-2*d23^4*d12^2*d31^2+2*d23^6*d12^2+d23^4*d31^4+d23^4*d12^4-2*d23^6*d31^2;
    % solve the algebraic equation
    % x^4 + b3/b4*t^3 + b2/b4*t^2 + b1/b4*t + b0/b4 = 0
    % via the companion matrix
    % M = [0 0 0 -b0/b4
    %      1 0 0 -b1/b4
    %      0 1 0 -b2/b4
    %      0 0 1 -b3/b4];
    % s = eig(M);
    % small imag sols appear for roots with multiplicity > 1,     
    s = roots([b4 b3 b2 b1 b0])';
    s = real(s((imag(s)<teps)&(imag(s)>=0))); 
    if ~isempty(s)
        n = (2*d12^2*(d23^2*c31-d31^2*c23*s)+2*(d31^2-d23^2)*d12^2*c23*s);
        t = [s
            (d12^2*(d23^2-d31^2*s.^2)+(d23^2-d31^2)*(d23^2*(1+s.^2-2*s*c12)-d12^2*s.^2))./n];
        t = t(:,abs(n)>teps);
        cs = ones(1,size(t,2));
    else
        t = [];
        cs = [];
    end
    % Case B
    if abs(c23)>eps 
        % Case B1
        s = c31/c23;
        v = roots([d12^2*c23^2*s^2 -2*d12^2*c23^2*c31*s d12^2*c31^2-d23^2*c23^2-d23^2*c31^2+2*d23^2*c12*c23*c31])';
        v = real(v((imag(v)<teps)&(imag(v)>=0)));
        t = [t [repmat(s,size(v));v]];
        cs = [cs repmat(2,size(v))];
    else% Case B2 
        if abs(d31^2-d23^2)>teps  % Case B2.1
            s = roots([d12^2+d31^2-d23^2 2*c12*(d23^2-d31^2) d31^2-d23^2-d12^2])'; 
            s = real(s((imag(s)<teps)&(imag(s)>=0)));
            v = sqrt((d31^2*s.^2-d23^2)/(d23^2-d31^2));
            ix = (imag(v)<teps)&(imag(v)>=0);
            t = [t [s(ix);v(ix)]];
            cs = [cs repmat(3,size(ix))];
        else % Case B2.2
            s = 1;
            v = sqrt(2*d23^2/d12^2*(1-c12)-1);
            ix = (imag(v)<teps)&(imag(v)>=0);
            t = [t [s(ix);v(ix)]];
            cs = [cs repmat(4,size(ix))];
        end
    end
    % ratios of a's are non-negative
    ix = all(t>teps);
    t = t(:,ix);
    cs = cs(ix);    
    % get a1, a2, a3 from s, t
    a = [];
    for i=1:size(t,2)
        a1 = sqrt(d31^2/(1+t(2,i)^2-2*t(2,i)*c31));
        a2 = t(1,i)*a1;
        a3 = t(2,i)*a1;
        a = [a [a1;a2;a3]];
    end
    %% select a's satisfying 3 original equations
    if isempty(a)
        R = []; C = [];
        return;
    end
    de = [a(1,:).^2+a(2,:).^2-2*a(1,:).*a(2,:)*c12-d12^2
        a(2,:).^2+a(3,:).^2-2*a(2,:).*a(3,:)*c23-d23^2
        a(3,:).^2+a(1,:).^2-2*a(3,:).*a(1,:)*c31-d31^2];
    ix = all(abs(de)<teps);
    a  = a(:,ix);
    cs = cs(ix);
    if isempty(cs)
        R = []; C = [];
        return;
    end
    %% Compute the center and rotation
    if true % Using a change of coordinate systems
        for i=1:size(a,2) % for all etas
            XCe = x*diag(a(:,i)); % points X in system (C,epsilon)
            YCe = [XCe(:,2)-XCe(:,1) XCe(:,3)-XCe(:,1)]; % in (C,epsilon)
            YOd = [X(:,2)-X(:,1) X(:,3)-X(:,1)]; % in (O,delta)
            YCe = [cr(YCe(:,1),YCe(:,2)) YCe]; 
            YOd = [cr(YOd(:,1),YOd(:,2)) YOd];
            R(:,:,i) = YCe*inv(YOd);
            C(:,i) = mean(X-R(:,:,i)'*XCe,2);
        end
    else % Intersection of 3 spheres for all triplers of a's 
        % Choose a special coordinate system
        r1 = (X(:,2)-X(:,1));
        r1 = r1/sqrt(sum(r1.^2));
        r2 = (X(:,3)-X(:,1))-(r1'*(X(:,3)-X(:,1)))*r1;
        r2 = r2/sqrt(sum(r2.^2));
        r3 = cr(r1,r2);
        R  = [r1 r2 r3]';
        Y = R*(X-X(:,1)*[1 1 1]);
        % solve for the intersection
        p = Y(1,2);
        q = Y(1,3);
        r = Y(2,3);
        % for all a's
        C = [];
        for i=1:size(a,2)
            dx = (p^2+a(1,i)^2-a(2,i)^2)/2/p;
            dy = (r^2+q^2-p^2+a(2,i)^2-a(3,i)^2+2*(p*dx-q*dx))/2/r;
            dz = sqrt(a(1,i)^2-dx^2-dy^2);
            D = [dx dx;dy dy;dz -dz];
            % transform back
            C = [C R'*D+X(:,1)*[1 1]];
        end
        % only real solutions
        C = C(:,all(abs(imag(C)<teps)));
        % Ger R's
        for i=1:size(C,2)
            dX = X-(C(:,i)*[1 1 1]);
            dX = dX./([1;1;1]*sqrt(sum(dX.^2)));
            R(:,:,i) = x*inv(dX);
        end
    end
    if dbg % debug plots
        f(1) = subfig(2,2,1);
        plot3d(X,'.k'); hold
        axis equal, grid on
        xlabel('x');ylabel('y');zlabel('z');
        % solutions
        for i=1:size(C,2)
            plot3d([C(:,i) X(:,1) X(:,2) C(:,i) X(:,2) X(:,3) C(:,i) X(:,3) X(:,1)],':');
            plot3d(C(:,i),'ob');
        end
        for i=1:size(R,3), dR(i) = det(R(:,:,i)); end;
        plot3D(C(:,dR>0),'g.','markersize',20);
        plot3D(C(:,dR<0),'m.','markersize',20);                
        axis tight
        %
        f(2) = subfig(2,2,2); hold
        [Sx,Sy,Sz] = sphere(30);
        for i=1:3
            sx = a(i,1)*Sx+X(1,i);
            sy = a(i,1)*Sy+X(2,i);
            sz = a(i,1)*Sz+X(3,i);
            surf(sx,sy,sz,i*ones(size(Sz)),'edgecolor','none');
        end
        colormap([0 0 1;1 0 0;0 1 0]);axis equal; grid on; view(3)
        plot3D(C,'k.','markersize',20);
    end
else
   p3p([0 1 0
        0 0 1
        1 1 1],[0 1 0
                0 0 1
                0 0 0],1); 
end    
function z = cr(x,y)
  z = [x(2)*y(3)-x(3)*y(2);-x(1)*y(3)+x(3)*y(1);x(1)*y(2)-x(2)*y(1)];
return
    