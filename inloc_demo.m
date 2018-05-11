startup;
[ params ] = setup_project_ht_WUSTL;


%1. retrieval
ht_retrieval;

%2. geometric verification
ht_top100_densePE_localization;

%3. pose verification
ht_top10_densePV_localization;

%4. evaluationmethod = struct();
method = struct();
method(1).ImgList = ImgList_densePE;
method(1).description = 'densePE';
method(1).marker = '-b';
method(2).ImgList = ImgList_densePV;
method(2).description = 'InLoc (densePE+densePV)';
method(2).marker = '-bo';

ht_plotcurve_WUSTL;



