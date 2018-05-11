function [ Poptim ] = PnP_mex_wrapper( u, X, P )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%parse P to input args
q = rot2qtr(P(1:3, 1:3));
camera = [q, P(1:3, 4)'];

camera_optim = PnP_mex(u, X, camera);

%parse output args to P
R = qtr2rot(camera_optim(1:4));
Poptim = [R, camera_optim(5:7)'];


end

