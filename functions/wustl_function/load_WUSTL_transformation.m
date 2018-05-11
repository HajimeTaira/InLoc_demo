function [ P_before, P_after ] = load_WUSTL_transformation( transformation_path )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

P_before = zeros(4, 4);
P_after = zeros(4, 4);

fid =  fopen(transformation_path, 'r');
data_all = textscan(fid, '%s', 'Delimiter', '\n');
data_all = data_all{1};
fclose(fid);

%data_all{1}: header (before)
P_before(1, :) = str2double(strsplit(data_all{2}));
P_before(2, :) = str2double(strsplit(data_all{3}));
P_before(3, :) = str2double(strsplit(data_all{4}));
P_before(4, :) = str2double(strsplit(data_all{5}));

%data_all{7}: header (before)
P_after(1, :) = str2double(strsplit(data_all{8}));
P_after(2, :) = str2double(strsplit(data_all{9}));
P_after(3, :) = str2double(strsplit(data_all{10}));
P_after(4, :) = str2double(strsplit(data_all{11}));

end

