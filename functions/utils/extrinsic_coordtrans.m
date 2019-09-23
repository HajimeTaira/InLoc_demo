function [ R2, T2 ] = extrinsic_coordtrans( R1, T1, Rw, Tw, cw )
%UNTITLED Summary of this function goes here
%coordinate transform of camera extrinsic parameter [R1, T1] -> [R2, T2]
%when the world coordinate system was transformed W->W'
%Rw, Tw, cw: (cw * Rw) * X(in system W) + Tw = X(in system W')
if nargin == 4
    cw = 1;
end

R2 = R1 * transpose(Rw);
T2 = (cw * T1) - R2 * Tw;

end

