# InLoc demo

This toolkit provides scalable indoor visual localization (InLoc) demo on InLoc dataset. 
Please send bug reports and suggestions to <htaira@ok.ctrl.titech.ac.jp>, <torii@sc.e.titech.ac.jp> . 

2019.5.1 Update. 
We open an online evaluation tool for visual localization on the InLoc dataset (<https://www.visuallocalization.net/>). The tool accepts the localization results in text format. Please use `` functions/utils/ImgList2text.m `` in this repository to convert .mat result file to the proper text format. 


## Installation

* Install dependencies

    * Netvlad (<https://www.di.ens.fr/willow/research/netvlad/>)
    * relja_matlab (<https://github.com/Relja/relja_matlab>)
    * vlfeat (<http://www.vlfeat.org/>)
    * matconvnet (<http://www.vlfeat.org/matconvnet/>)
    * Inpaint nans (<https://jp.mathworks.com/matlabcentral/fileexchange/4551-inpaint-nans?requestedDomain=www.mathworks.com>)
    * yael (<http://yael.gforge.inria.fr/#>)

    Netvlad, relja_matlab, vlfeat, matconvnet, Inpaint nans are the submodules of this repository and automatically downloaded by `` git clone --recurse-submodules ``. 
    For yael, please follow installation procedure described in its page.
    Then modify `` startup.m `` to add path to all dependencies. 

* Compile mex function in functions/ht_pnp_function
    
    First, install ceres solver: 

    If you are on macOS, then just do `` brew install ceres-solver ``. Otherwise:

    ```
    git clone https://ceres-solver.googlesource.com/ceres-solver
    cd ceres-solver
    mkdir build
    cd build
    cmake .. 
    make
    sudo make install
    ```

    Then modify paths in `` functions/ht_pnp_function/make_PnP_mex.m `` and execute it in Matlab. 

## Quick Start

* Download InLoc dataset (<https://github.com/HajimeTaira/InLoc_dataset>)

* Download pre-trained CNN model from <http://www.di.ens.fr/willow/research/netvlad/>

* Modify `` setup_project_ht_WUSTL.m ``
    * line 8: `` params.data.dir = '/path/to/dataset'; ``

* Execute `` startup `` and `` inloc_demo `` in Matlab

* Optional: `` sparse_demo `` executes the baseline indoor visual localization using spase features. 

## Outputs

`` InLoc_demo `` generates the matfile `` outputs/densePV_top10_shortlist.mat `` that contains localization results. 
It includes a struct array named `` ImgList `` that consists of fields named 
`` queryname `` (query image name), `` topNname `` (N retrieved database images), `` topNscore `` (retrieval scores), and `` P `` (estimated 6 DoF query poses [R t]). 
We are planning to build a evaluation server that computes the quantitative localization errors for the result files following this format. 
Until then, we can evaluate your own localization results if you send it to <htaira@ok.ctrl.titech.ac.jp>. 

## Details: Run InLoc with your own features and image retrieval

* Prepare your own features, image lists, and retrieval scores

    The toolkit requires multiple .mat files 
    containing list of database / query images, initial image retireval scores, and dense features for each image  as input. 
    All of them should be in one directory such as `` inputs ``. 

    * Image list

        `` query_imgnames_all.mat `` contains string cell array named `` query_imgnames_all `` that consists of image names of queries. 

        ```
        query imgnames_all = 
        {'IMG_0731.JPG', 
        'IMG_0732.JPG', 
        ...
        'IMG_1113.JPG', 
        'IMG_1114.JPG'};
        ```

        Similary, `` cutout_imgnames_all.mat `` contains string cell array named `` cutout_imgnames_all ``. 
        It consists of paths of cutout images from `` database/cutouts/ `` directory in WUSTL dataset. 

        ```
        cutout_imgnames_all = 
        {'CSE3/000/cse_cutout_000_0_0.jpg',
        'CSE3/000/cse_cutout_000_0_30.jpg', 
        ...
        };
        ```

    * Image retireval scores

        `` scores.mat `` contains single numeric array named `` score ``. 
        It contains the similarity score between query in each row and database in each column. 
        Indices of queries and database should follow indices defined by image lists. 

    * Features

        Dense features for queries and databases are in ``inputs/features/query/iphone7/XXX.features.dense.mat `` and `` inputs/features/database/cutouts/XXX.features.dense.mat ``.  
        "XXX" is the image name or path in image list. 
        Each file contains 1x5 cell array named `` cnn `` that consists of multiple-level CNN intermediate feature map for each cell. 
        We use 3rd and 5th layers for our coarse-to-fine matching, so we recommend to keep the other cells empty to eliminate loading time. 
        If there are no pre-computed features, our tool computes dense features by using model pre-trained as the part of NetVLAD. 

* Modify `` setup_project_ht_WUSTL.m ``

    In our demo, `` setup_project_ht_WUSTL.m `` is firstly called and defines all paths and file name formats. 
    If you want to change input/output directories or file names format, modify description in the function. 

    setup_project_ht_WUSTL.m line 32-49: 

    ```
    %input
    params.input.dir = 'inputs';
    params.input.dblist_matname = fullfile(params.input.dir, 'cutout_imgnames_all.mat');%string cell containing cutout image names
    params.input.qlist_matname = fullfile(params.input.dir, 'query_imgnames_all.mat');%string cell containing query image names
    params.input.score_matname = fullfile(params.input.dir, 'scores.mat');%retrieval score matrix
    params.input.feature.dir = fullfile(params.input.dir, 'features');
    params.input.feature.db_matformat = '.features.dense.mat';
    params.input.feature.q_matformat = '.features.dense.mat';


    %output
    params.output.dir = 'outputs';
    params.output.gv_dense.dir = fullfile(params.output.dir, 'gv_dense');%dense matching results (directory)
    params.output.gv_dense.matformat = '.gv_dense.mat';%dense matching results (file extention)
    params.output.pnp_dense_inlier.dir = fullfile(params.output.dir, 'PnP_dense_inlier');%PnP results (directory)
    params.output.pnp_dense.matformat = '.pnp_dense_inlier.mat';%PnP results (file extention)
    params.output.synth.dir = fullfile(params.output.dir, 'synthesized');%View synthesis results (directory)
    params.output.synth.matformat = '.synth.mat';%View synthesis results (file extention)

    ```

### LICENSE


```
Copyright (c) 2017 Hajime Taira

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

If you use our data and Software, please cite our paper: 

@inproceedings{taira2018inloc, 
  title={{InLoc}: Indoor Visual Localization with Dense Matching and View Synthesis}, 
  author={Taira, Hajime and Okutomi, Masatoshi and Sattler, Torsten and Cimpoi, Mircea and Pollefeys, Marc and Sivic, Josef and Pajdla, Tomas and Torii, Akihiko}, 
  booktitle={{CVPR}}, 
  year={2018} 
}

and the paper presenting original Wustl Indoor RGBD dataset: 

@inproceedings{wijmans17rgbd,
  author = {Erik Wijmans and
            Yasutaka Furukawa},
  title = {Exploiting 2D Floorplan for Building-scale Panorama RGBD Alignment},
  booktitle = {Computer Vision and Pattern Recognition, {CVPR}},
  year = {2017},
  url = {http://cvpr17.wijmans.xyz/CVPR2017-0111.pdf}
}
```
