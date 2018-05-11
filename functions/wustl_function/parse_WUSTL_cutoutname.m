function [ info ] = parse_WUSTL_cutoutname( cutout_name )

info = struct();
[~, cutout_basename, ~] = fileparts(cutout_name);
cutout_split = strsplit(cutout_basename, '_');

info.scene_id = cutout_split{1};
info.scan_id = cutout_split{3};
info.theta = str2double(cutout_split{4});
info.phi = str2double(cutout_split{5});

end

