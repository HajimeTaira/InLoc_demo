function [ R ] = R_rpy( roll, pitch, yaw )
%R_RPY この関数の概要をここに記述
%   Camera rotates (1) yaw (y-axis) (2)pitch (x'-axis) (3)roll (z''-axis)

rrad = -roll * pi / 180.0;
prad = -pitch * pi / 180.0;
yrad = -yaw * pi / 180.0;

Rr = [cos(rrad), -sin(rrad), 0;...
      sin(rrad), cos(rrad), 0;...
      0, 0, 1];

Rp = [1, 0, 0;...
      0, cos(prad), -sin(prad);...
      0, sin(prad), cos(prad)];
  
Ry = [cos(yrad), 0, sin(yrad);...
      0, 1, 0;...
      -sin(yrad), 0, cos(yrad)];
  
R = Rr * Rp * Ry;


end

