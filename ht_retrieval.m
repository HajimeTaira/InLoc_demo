%Note: It loads localization score and output top100 database list for each query. 

%% Load query and database list
query_dir = fullfile(params.data.dir, params.data.q.dir);
load(params.input.qlist_matname, 'query_imgnames_all');
db_dir = fullfile(params.data.dir, params.data.db.cutout.dir);
load(params.input.dblist_matname, 'cutout_imgnames_all');

%% top100 retrieval
shortlist_topN = 100;
pnp_topN = 10;
top100_matname = fullfile(params.output.dir, 'original_top100_shortlist.mat');
if exist(top100_matname, 'file') ~= 2
    ImgList = struct('queryname', {}, 'topNname', {}, 'topNscore', {});
    
    %Load score
    load(params.input.score_matname, 'score');
    
    %shortlist format
    for ii = 1:1:size(score, 1)
        ImgList(ii).queryname = query_imgnames_all{ii};
        [~, score_idx] = sort(score(ii, :), 'descend');
        ImgList(ii).topNname = cutout_imgnames_all(score_idx(1:shortlist_topN));
        ImgList(ii).topNscore = score(ii, score_idx(1:shortlist_topN));
    end
    
    if exist(params.output.dir, 'dir') ~= 7
        mkdir(params.output.dir);
    end
    save('-v6', top100_matname, 'ImgList');
else
    load(top100_matname, 'ImgList');
end
ImgList_original = ImgList;

