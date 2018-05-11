file = 'PnP_mex.cpp';

INCLUDE = {'/usr/local/include' , '/usr/include/glog', '/usr/include/eigen3',...
	   '/home/htaira/Desktop/zips/ceres-solver/build/config/'};

LIBFOLDER = {'/home/htaira/Desktop/zips/ceres-solver/build/lib/', '/usr/lib/x86_64-linux-gnu/'};

LIBNAME = {'ceres', 'ceres', 'glog', 'gflags', 'suitesparseconfig',...
	   'cholmod', 'lapack', 'blas', 'spqr', 'gomp', 'cxsparse'};

include = strjoin(strcat('-I', INCLUDE));
libfolder = strjoin(strcat('-L', LIBFOLDER));
libname = strjoin(strcat('-l', LIBNAME));

eval(['mex' ' ' file ' ' include ' '  libfolder ' ' libname]);

