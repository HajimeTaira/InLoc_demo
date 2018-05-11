[ params ] = setup_project_ht_WUSTL;

%1. retrieval
ht_retrieval;

%2. geometric verification (sparse feature)
ht_top100_sparsePE_localization;

%3. evaluation
method = struct();
method(1).ImgList = ImgList_originalPE;
method(1).description = 'originalPE';
method(1).marker = '-m';
method(2).ImgList = ImgList_sparsePE;
method(2).description = 'sparsePE';
method(2).marker = '-g';

ht_plotcurve_WUSTL;
