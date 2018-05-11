function parfor_sparsePE( qname, dbname, params )

[~, dbbasename, ~] = fileparts(dbname);
this_sparsepe_matname = fullfile(params.output.pnp_sparse_inlier.dir, qname, [dbbasename, params.output.pnp_sparse_inlier.matformat]);

if exist(this_sparsepe_matname, 'file') ~= 2
    Iqsize = size(imread(fullfile(params.data.dir, params.data.q.dir, qname)));
    
    %load features
    qfmatname = fullfile(params.input.feature.dir, params.data.q.dir, [qname, params.input.feature.q_sps_matformat]);
    features_q = load(qfmatname);
    dbfmatname = fullfile(params.input.feature.dir, params.data.db.cutout.dir, [dbname, params.input.feature.db_sps_matformat]);
    features_db = load(dbfmatname);
    %load sparsegv results
    this_sparsegv_matname = fullfile(params.output.gv_sparse.dir, qname, [dbbasename, params.output.gv_sparse.matformat]);
    gv_info = load(this_sparsegv_matname);
    
    tentative_qindex = gv_info.inls_qidx; tentative_dbindex = gv_info.inls_dbidx;
    tent_xq2d = features_q.f(1:2, tentative_qindex);
    tent_xdb2d = features_db.f(1:2, tentative_dbindex);
    
    %query ray
    Kq = [params.data.q.fl, 0, Iqsize(2)/2.0; ...
        0, params.data.q.fl, Iqsize(1)/2.0; ...
        0, 0, 1];
    tent_ray2d = Kq^-1 * [tent_xq2d; ones(1, size(tent_xq2d, 2))];
    
    %load depth information
    this_db_matname = fullfile(params.data.dir, params.data.db.cutout.dir, [dbname, params.data.db.cutout.matformat]);
    load(this_db_matname, 'XYZcut');
    %load transformation matrix (local to global)
    this_floorid = strsplit(dbname, '/');this_floorid = this_floorid{1};
    info = parse_WUSTL_cutoutname( dbname );
    transformation_txtname = fullfile(params.data.dir, params.data.db.trans.dir, this_floorid, 'transformations', ...
                sprintf('%s_trans_%s.txt', info.scene_id, info.scan_id));
    [ ~, P_after ] = load_WUSTL_transformation(transformation_txtname);
    
    %DB 3d points
    tent_xdb3d = zeros(3, size(tent_xdb2d, 2));
    tent_xdb3d(1, :) = interp2(XYZcut(:, :, 1), tent_xdb2d(1, :), tent_xdb2d(2, :));
    tent_xdb3d(2, :) = interp2(XYZcut(:, :, 2), tent_xdb2d(1, :), tent_xdb2d(2, :));
    tent_xdb3d(3, :) = interp2(XYZcut(:, :, 3), tent_xdb2d(1, :), tent_xdb2d(2, :));
    tent_xdb3d = bsxfun(@plus, P_after(1:3, 1:3)*tent_xdb3d, P_after(1:3, 4));
    
    %Select keypoint correspond to 3D
    idx_3d = all(~isnan(tent_xdb3d), 1);
    tent_xq2d = tent_xq2d(:, idx_3d);
    tent_xdb2d = tent_xdb2d(:, idx_3d);
    tent_ray2d = tent_ray2d(:, idx_3d);
    tent_xdb3d = tent_xdb3d(:, idx_3d);
    
    
    tentatives_2d = [tent_xq2d; tent_xdb2d];
    tentatives_3d = [tent_ray2d; tent_xdb3d];
    
    %solver
    if size(tentatives_2d, 2) < 3
        P = nan(3, 4);
        inls = false(1, size(tentatives_2d, 2));
    else
        [ P, inls ] = ht_lo_ransac_p3p( tent_ray2d, tent_xdb3d, 1.0*pi/180);
        if isempty(P)
            P = nan(3, 4);
        end
    end
    
    if exist(fullfile(params.output.pnp_sparse_inlier.dir, qname), 'dir') ~= 7
        mkdir(fullfile(params.output.pnp_sparse_inlier.dir, qname));
    end
    save('-v6', this_sparsepe_matname, 'P', 'inls', 'tentatives_2d', 'tentatives_3d');
    
%     %debug
%     Iq = imread(fullfile(params.data.dir, params.data.q.dir, qname));
%     Idb = imread(fullfile(params.data.dir, params.data.db.cutout.dir, dbname));
%     figure();
%     ultimateSubplot ( 2, 1, 1, 1, 0.01, 0.05 );
%     imshow(rgb2gray(Iq));hold on;
%     plot(tent_xq2d(1, :), tent_xq2d(2, :),'b.');
%     plot(tent_xq2d(1, inls), tent_xq2d(2, inls),'g.');
%     ultimateSubplot ( 2, 1, 2, 1, 0.01, 0.05 );
%     imshow(rgb2gray(Idb));hold on;
%     plot(tent_xdb2d(1, :), tent_xdb2d(2, :),'b.');
%     plot(tent_xdb2d(1, inls), tent_xdb2d(2, inls),'g.');
% 
%     keyboard;
    
end

end

