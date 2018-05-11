%Note: It first rerank top100 original shortlist (ImgList_original) in accordance
%with the number of dense matching inliers. It then computes query
%candidate poses by using top10 database images. 

shortlist_topN = 100;
pnp_topN = 10;

%% densePE (top100 reranking -> top10 pose candidate)

densePE_matname = fullfile(params.output.dir, 'densePE_top100_shortlist.mat');
if exist(densePE_matname, 'file') ~= 2
    
    %dense feature extraction
    net = load('vd16_pitts30k_conv5_3_vlad_preL2_intra_white.mat');
    net = net.net;
    net= relja_simplenn_tidy(net);
    net= relja_cropToLayer(net, 'preL2');
    for ii = 1:1:length(ImgList_original)
        q_densefeat_matname = fullfile(params.input.feature.dir, params.data.q.dir, [ImgList_original(ii).queryname, params.input.feature.q_matformat]);
        if exist(q_densefeat_matname, 'file') ~= 2
            cnn = at_serialAllFeats_convfeat(net, query_dir, ImgList_original(ii).queryname, 'useGPU', true);
            cnn{1} = [];
            cnn{2} = [];
            cnn{4} = [];
            [feat_path, ~, ~] = fileparts(q_densefeat_matname);
            if exist(feat_path, 'dir')~=7; mkdir(feat_path); end;
            save('-v6', q_densefeat_matname, 'cnn');
            fprintf('Dense feature extraction: %s done. \n', ImgList_original(ii).queryname);
        end
        
        for jj = 1:1:shortlist_topN
            db_densefeat_matname = fullfile(params.input.feature.dir, params.data.db.cutout.dir, ...
                [ImgList_original(ii).topNname{jj}, params.input.feature.db_matformat]);
            if exist(db_densefeat_matname, 'file') ~= 2
                cnn = at_serialAllFeats_convfeat(net, db_dir, ImgList_original(ii).topNname{jj}, 'useGPU', true);
                cnn{1} = [];
                cnn{2} = [];
                cnn{4} = [];
                [feat_path, ~, ~] = fileparts(db_densefeat_matname);
                if exist(feat_path, 'dir')~=7; mkdir(feat_path); end;
                save('-v6', db_densefeat_matname, 'cnn');
                fprintf('Dense feature extraction: %s done. \n', ImgList_original(ii).topNname{jj});
            end
        end
    end
    
    %shortlist reranking
    ImgList = struct('queryname', {}, 'topNname', {}, 'topNscore', {}, 'P', {});
    for ii = 1:1:length(ImgList_original)
        ImgList(ii).queryname = ImgList_original(ii).queryname;
        ImgList(ii).topNname = ImgList_original(ii).topNname(1:shortlist_topN);
        
        %preload query feature
        qfname = fullfile(params.input.feature.dir, params.data.q.dir, [ImgList(ii).queryname, params.input.feature.q_matformat]);
        cnnq = load(qfname, 'cnn');cnnq = cnnq.cnn;
        
        parfor kk = 1:1:shortlist_topN
            parfor_denseGV( cnnq, ImgList(ii).queryname, ImgList(ii).topNname{kk}, params );
            fprintf('dense matching: %s vs %s DONE. \n', ImgList(ii).queryname, ImgList(ii).topNname{kk});
        end
        
        for jj = 1:1:shortlist_topN
            [~, dbbasename, ~] = fileparts(ImgList(ii).topNname{jj});
            this_gvresults = load(fullfile(params.output.gv_dense.dir, ImgList(ii).queryname, [dbbasename, params.output.gv_dense.matformat]));
            ImgList(ii).topNscore(jj) = ImgList_original(ii).topNscore(jj) + size(this_gvresults.inls12, 2);
        end
        
        [sorted_score, idx] = sort(ImgList(ii).topNscore, 'descend');
        ImgList(ii).topNname = ImgList(ii).topNname(idx);
        ImgList(ii).topNscore = ImgList(ii).topNscore(idx);

        fprintf('%s done. \n', ImgList(ii).queryname);
    end
    
    %pnp list
    qlist = cell(1, length(ImgList)*pnp_topN);
    dblist = cell(1, length(ImgList)*pnp_topN);
    for ii = 1:1:length(ImgList)
        for jj = 1:1:pnp_topN
            qlist{pnp_topN*(ii-1)+jj} = ImgList(ii).queryname;
            dblist{pnp_topN*(ii-1)+jj} = ImgList(ii).topNname{jj};
        end
    end
    
    %dense pnp
    parfor ii = 1:1:length(qlist)
        parfor_densePE( qlist{ii}, dblist{ii}, params );
        fprintf('densePE: %s vs %s DONE. \n', qlist{ii}, dblist{ii});
    end
    
    %load top10 pnp
    for ii = 1:1:length(ImgList)
        ImgList(ii).P = cell(1, pnp_topN);
        for jj = 1:1:pnp_topN
            [~, dbbasename, ~] = fileparts(ImgList(ii).topNname{jj});
            this_densepe_matname = fullfile(params.output.pnp_dense_inlier.dir, ImgList(ii).queryname, [dbbasename, params.output.pnp_dense.matformat]);
            load(this_densepe_matname, 'P');
            ImgList(ii).P{jj} = P;
        end
    end
    
    if exist(params.output.dir, 'dir') ~= 7
        mkdir(params.output.dir);
    end
    save('-v6', densePE_matname, 'ImgList');
else
    load(densePE_matname, 'ImgList');
end
ImgList_densePE = ImgList;
