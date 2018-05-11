function parfor_densePE( qname, dbname, params )

[~, dbbasename, ~] = fileparts(dbname);
this_densepe_matname = fullfile(params.output.pnp_dense_inlier.dir, qname, [dbbasename, params.output.pnp_dense.matformat]);

if exist(this_densepe_matname, 'file') ~= 2
    %geometric verification results
    this_densegv_matname = fullfile(params.output.gv_dense.dir, qname, [dbbasename, params.output.gv_dense.matformat]);
    if exist(this_densegv_matname, 'file') ~= 2
        qfname = fullfile(params.input.feature.dir, params.data.q.dir, [qname, params.input.feature.q_matformat]);
        cnnq = load(qfname, 'cnn');cnnq = cnnq.cnn;
        parfor_denseGV( cnnq, qname, dbname, params );
    end
    this_gvresults = load(this_densegv_matname);
    tent_xq2d = this_gvresults.f1(:, this_gvresults.inls12(1, :));
    tent_xdb2d = this_gvresults.f2(:, this_gvresults.inls12(2, :));
    
    
    %depth information
    this_db_matname = fullfile(params.data.dir, params.data.db.cutout.dir, [dbname, params.data.db.cutout.matformat]);
    load(this_db_matname, 'XYZcut');
    %load transformation matrix (local to global)
    this_floorid = strsplit(dbname, '/');this_floorid = this_floorid{1};
    info = parse_WUSTL_cutoutname( dbname );
    transformation_txtname = fullfile(params.data.dir, params.data.db.trans.dir, this_floorid, 'transformations', ...
                sprintf('%s_trans_%s.txt', info.scene_id, info.scan_id));
    [ ~, P_after ] = load_WUSTL_transformation(transformation_txtname);
    %Feature upsampling
    Iqsize = size(imread(fullfile(params.data.dir, params.data.q.dir, qname)));
    Idbsize = size(XYZcut);
    tent_xq2d = at_featureupsample(tent_xq2d,this_gvresults.cnnfeat1size,Iqsize);
    tent_xdb2d = at_featureupsample(tent_xdb2d,this_gvresults.cnnfeat2size,Idbsize);
    %query ray
    Kq = [params.data.q.fl, 0, Iqsize(2)/2.0; ...
        0, params.data.q.fl, Iqsize(1)/2.0; ...
        0, 0, 1];
    tent_ray2d = Kq^-1 * [tent_xq2d; ones(1, size(tent_xq2d, 2))];
    %DB 3d points
    indx = sub2ind(size(XYZcut(:,:,1)),tent_xdb2d(2,:),tent_xdb2d(1,:));
    X = XYZcut(:,:,1);Y = XYZcut(:,:,2);Z = XYZcut(:,:,3);
    tent_xdb3d = [X(indx); Y(indx); Z(indx)];
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
    
    
    
    if exist(fullfile(params.output.pnp_dense_inlier.dir, qname), 'dir') ~= 7
        mkdir(fullfile(params.output.pnp_dense_inlier.dir, qname));
    end
    save('-v6', this_densepe_matname, 'P', 'inls', 'tentatives_2d', 'tentatives_3d');
    
%     %debug
%     Iq = imread(fullfile(params.data.dir, params.data.q.dir, qname));
%     Idb = imread(fullfile(params.data.dir, params.data.db.cutout.dir, dbname));
%     points.x2 = tentatives_2d(3, inls);
%     points.y2 = tentatives_2d(4, inls);
%     points.x1 = tentatives_2d(1, inls);
%     points.y1 = tentatives_2d(2, inls);
%     points.color = 'g';
%     points.facecolor = 'g';
%     points.markersize = 60;
%     points.linestyle = '-';
%     points.linewidth = 1.0;
%     show_matches2_vertical( Iq, Idb, points );
%     
%     points.x2 = tentatives_2d(3, :);
%     points.y2 = tentatives_2d(4, :);
%     points.x1 = tentatives_2d(1, :);
%     points.y1 = tentatives_2d(2, :);
%     points.color = 'r';
%     points.facecolor = 'r';
%     points.markersize = 60;
%     points.linestyle = '-';
%     points.linewidth = 1.0;
%     show_matches2_vertical( Iq, Idb, points );
%     
%     keyboard;    
end


end

