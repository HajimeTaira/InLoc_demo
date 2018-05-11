%Note: It first rerank top100 original shortlist (ImgList_original) in accordance
%with the number of sparse matching inliers. It then computes query
%candidate poses by using top10 database images. It also computes top10
%pose candidates with the shortlists before reranking (without geometric verification)

shortlist_topN = 100;
pnp_topN = 10;

%% sparsePE (top100 reranking -> top10 pose candidate)

sparsePE_matname = fullfile(params.output.dir, 'sparsePE_top100_shortlist.mat');
if exist(sparsePE_matname, 'file') ~= 2
    
    %sparse matching
    qlist = cell(1, length(ImgList_original)*shortlist_topN);
    dblist = cell(1, length(ImgList_original)*shortlist_topN);
    for ii = 1:1:length(ImgList_original)
        for jj = 1:1:shortlist_topN
            qlist{shortlist_topN*(ii-1)+jj} = ImgList_original(ii).queryname;
            dblist{shortlist_topN*(ii-1)+jj} = ImgList_original(ii).topNname{jj};
        end
    end
    
    parfor ii = 1:1:length(qlist)
        parfor_sparseGV(qlist{ii}, dblist{ii}, params);
        fprintf('Sparse matching: %s vs %s DONE. \n. \n', qlist{ii}, dblist{ii});
    end
    
    %reranking
    ImgList = struct('queryname', {}, 'topNname', {}, 'topNscore', {}, 'P', {});
    for ii = 1:1:length(ImgList_original)
        ImgList(ii).queryname = ImgList_original(ii).queryname;
        ImgList(ii).topNname = ImgList_original(ii).topNname(1:shortlist_topN);
        ImgList(ii).topNscore = zeros(1, shortlist_topN);
        ImgList(ii).P = cell(1, pnp_topN);
        
        for jj = 1:1:shortlist_topN
            [~, dbbasename, ~] = fileparts(ImgList(ii).topNname{jj});
            this_gvresults = load(fullfile(params.output.gv_sparse.dir, ImgList(ii).queryname, [dbbasename, params.output.gv_sparse.matformat]));
            ImgList(ii).topNscore(jj) = ImgList_original(ii).topNscore(jj) + this_gvresults.inliernum;
        end
        
        [sorted_score, idx] = sort(ImgList(ii).topNscore, 'descend');
        ImgList(ii).topNname = ImgList(ii).topNname(idx);
        ImgList(ii).topNscore = ImgList(ii).topNscore(idx);
    end
    
    %pose candidates
    qlist = cell(1, length(ImgList_original)*pnp_topN);
    dblist = cell(1, length(ImgList_original)*pnp_topN);
    for ii = 1:1:length(ImgList)
        for jj = 1:1:pnp_topN
            qlist{pnp_topN*(ii-1)+jj} = ImgList(ii).queryname;
            dblist{pnp_topN*(ii-1)+jj} = ImgList(ii).topNname{jj};
        end
    end
    
    parfor ii = 1:1:length(qlist)
        parfor_sparsePE(qlist{ii}, dblist{ii}, params);
        fprintf('sparsePE: %s vs %s DONE. \n', qlist{ii}, dblist{ii});
    end
    
    %load pose candidates
    for ii = 1:1:length(ImgList)
        for jj = 1:1:pnp_topN
            [~, dbbasename, ~] = fileparts(ImgList(ii).topNname{jj});
            pnpresults_matname = fullfile(params.output.pnp_sparse_inlier.dir, ImgList(ii).queryname, [dbbasename, params.output.pnp_sparse_inlier.matformat]);
            pnpresults = load(pnpresults_matname);
            ImgList(ii).P{jj} = pnpresults.P;
        end
    end
    
    %save results
    if exist(params.output.dir, 'dir') ~= 7
        mkdir(params.output.dir);
    end
    save('-v6', sparsePE_matname, 'ImgList');
    
else
    load(sparsePE_matname, 'ImgList');
end
ImgList_sparsePE = ImgList;

%% pnp with original top10

originalPE_matname = fullfile(params.output.dir, 'originalPE_top100_shortlist.mat');
if exist(originalPE_matname, 'file') ~= 2
    ImgList = ImgList_original;
    
    %original top10
    qlist = cell(1, length(ImgList)*pnp_topN);
    dblist = cell(1, length(ImgList)*pnp_topN);
    for ii = 1:1:length(ImgList)
        for jj = 1:1:pnp_topN
            qlist{pnp_topN*(ii-1)+jj} = ImgList(ii).queryname;
            dblist{pnp_topN*(ii-1)+jj} = ImgList(ii).topNname{jj};
        end
    end
    
    %originalPE
    parfor ii = 1:1:length(qlist)
        parfor_originalPE(qlist{ii}, dblist{ii}, params);
        fprintf('originalPE: %s vs %s DONE. \n', qlist{ii}, dblist{ii});
    end
    
    %load pose candidates
    for ii = 1:1:length(ImgList)
        ImgList(ii).P = cell(1, pnp_topN);
        for jj = 1:1:pnp_topN
            [~, dbbasename, ~] = fileparts(ImgList(ii).topNname{jj});
            pnpresults_matname = fullfile(params.output.pnp_sparse_origin.dir, ImgList(ii).queryname, [dbbasename, params.output.pnp_sparse_origin.matformat]);
            pnpresults = load(pnpresults_matname);
            ImgList(ii).P{jj} = pnpresults.P;
        end
    end
    
    %save results
    if exist(params.output.dir, 'dir') ~= 7
        mkdir(params.output.dir);
    end
    save('-v6', originalPE_matname, 'ImgList');
    
else
    load(originalPE_matname, 'ImgList');
end
ImgList_originalPE = ImgList;

