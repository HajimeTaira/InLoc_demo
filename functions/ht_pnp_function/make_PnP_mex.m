file = 'PnP_mex.cpp';

INCLUDE = {'/usr/local/include' , '/usr/local/include/glog', '/usr/local/include/eigen3',...
	   '/Users/lucivpav/repos/ceres-solver/bld/config/'};

LIBFOLDER = {'/usr/local/lib/'};

LIBNAME = {'ceres', 'ceres', 'glog', 'gflags', 'suitesparseconfig',...
	   'cholmod', 'lapack', 'blas', 'spqr', 'omp', 'cxsparse'};

include = strjoin(strcat('-I', INCLUDE));
libfolder = strjoin(strcat('-L', LIBFOLDER));
libname = strjoin(strcat('-l', LIBNAME));

eval(['mex' ' ' file ' ' include ' '  libfolder ' ' libname]);

