function R = qtr2rot(q)

qw = q(1); qx = q(2); qy = q(3); qz = q(4);

Nq = qw^2 + qx^2 + qy^2 + qz^2;
if Nq>0
  s = 2/Nq;
else
  s = 0;
end

X  = qx*s; Y  = qy*s; Z  = qz*s;
wX = qw*X; wY = qw*Y; wZ = qw*Z;
xX = qx*X; xY = qx*Y; xZ = qx*Z;
yY = qy*Y; yZ = qy*Z; zZ = qz*Z;

R = [1-(yY+zZ) xY-wZ xZ+wY; ...
     xY+wZ 1-(xX+zZ) yZ-wX; ...
     xZ-wY yZ+wX 1-(xX+yY)];
