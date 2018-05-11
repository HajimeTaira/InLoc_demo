function parfor_denseGV( cnnq, qname, dbname, params )
coarselayerlevel = 5;
finelayerlevel = 3;

[~, dbbasename, ~] = fileparts(dbname);
this_densegv_matname = fullfile(params.output.gv_dense.dir, qname, [dbbasename, params.output.gv_dense.matformat]);

if exist(this_densegv_matname, 'file') ~= 2
    
    %load input feature
    dbfname = fullfile(params.input.feature.dir, params.data.db.cutout.dir, [dbname, params.input.feature.db_matformat]);
    cnndb = load(dbfname, 'cnn');cnndb = cnndb.cnn;
    
    
    
    %coarse-to-fine matching
    cnnfeat1size = size(cnnq{finelayerlevel}.x);
    cnnfeat2size = size(cnndb{finelayerlevel}.x);
    [match12,f1,f2,cnnfeat1,cnnfeat2] = at_coarse2fine_matching(cnnq,cnndb,coarselayerlevel,finelayerlevel);
    [inls12] = at_denseransac(f1,f2,match12,2);
    
    
    if exist(fullfile(params.output.gv_dense.dir, qname), 'dir') ~= 7
        mkdir(fullfile(params.output.gv_dense.dir, qname));
    end
    save('-v6', this_densegv_matname, 'cnnfeat1size', 'cnnfeat2size', 'f1', 'f2', 'inls12', 'match12');
    
    
%     %debug
%     im1 = imresize(imread(fullfile(params.data.dir, params.data.q.dir, qname)), cnnfeat1size(1:2));
%     im2 = imresize(imread(fullfile(params.data.dir, params.data.db.cutout.dir, dbname)), cnnfeat2size(1:2));
%     figure();
%     ultimateSubplot ( 2, 1, 1, 1, 0.01, 0.05 );
%     imshow(rgb2gray(im1));hold on;
%     plot(f1(1,match12(1,:)),f1(2,match12(1,:)),'b.');
%     plot(f1(1,inls12(1,:)),f1(2,inls12(1,:)),'g.');
%     ultimateSubplot ( 2, 1, 2, 1, 0.01, 0.05 );
%     imshow(rgb2gray(im2));hold on;
%     plot(f2(1,match12(2,:)),f2(2,match12(2,:)),'b.');
%     plot(f2(1,inls12(2,:)),f2(2,inls12(2,:)),'g.');
%     keyboard;
end

end

