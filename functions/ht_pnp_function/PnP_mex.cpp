#include <cmath>
#include <cstdio>
#include <iostream>

#include <glog/logging.h>
#include <gflags/gflags.h>

#include "ceres/ceres.h"
#include "ceres/rotation.h"

#include "mex.h"

struct SnavelyReprojectionErrorWithQuaternions {
  // (u, v): the position of the observation with respect to the image
  // center point.
  SnavelyReprojectionErrorWithQuaternions(double observed_x, double observed_y, double observed_z, 
                                                                            double observed3d_x, double observed3d_y, double observed3d_z)
      : observed_x(observed_x), observed_y(observed_y), observed_z(observed_z), observed3d_x(observed3d_x), observed3d_y(observed3d_y), observed3d_z(observed3d_z){}

  template <typename T>
  bool operator()(const T* const camera, T* residuals) const {
    // camera[0,1,2,3] is are the rotation of the camera as a quaternion.
    //
    // We use QuaternionRotatePoint as it does not assume that the
    // quaternion is normalized, since one of the ways to run the
    // bundle adjuster is to let Ceres optimize all 4 quaternion
    // parameters without a local parameterization.
    T p[3];
    T p3d[3];
    p3d[0] = T(observed3d_x);
    p3d[1] = T(observed3d_y);
    p3d[2] = T(observed3d_z);
    ceres::QuaternionRotatePoint(camera, p3d, p);

    // camera[4,5,6] is translation vector. 
    p[0] += camera[4];
    p[1] += camera[5];
    p[2] += camera[6];

    // normalization
    T p_norm = sqrt(p[0]*p[0] + p[1]*p[1] + p[2]*p[2]);
    p[0] = p[0] / p_norm;
    p[1] = p[1] / p_norm;
    p[2] = p[2] / p_norm;


    // angular error between observed and reprojected
    residuals[0] = 1.0 - p[0] * T(observed_x) - p[1] * T(observed_y) - p[2] * T(observed_z);

    return true;
  }

  // Factory to hide the construction of the CostFunction object from
  // the client code.
  static ceres::CostFunction* Create(const double observed_x, const double observed_y, const double observed_z, 
                                                            const double observed3d_x, const double observed3d_y, const double observed3d_z) {
    return (new ceres::AutoDiffCostFunction<
            SnavelyReprojectionErrorWithQuaternions, 1, 7>(
                new SnavelyReprojectionErrorWithQuaternions(observed_x, observed_y, observed_z, observed3d_x, observed3d_y, observed3d_z)));
  }

  double observed_x;
  double observed_y;
  double observed_z;
  double observed3d_x;
  double observed3d_y;
  double observed3d_z;
};

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
    if(nrhs != 3){
        mexErrMsgIdAndTxt("PnP_mex.cpp", "input arg must be (observed_2d, obserbed_3d, camera). ");
    }
    if(!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) || 
        !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) || 
        !mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]))
    {
        mexErrMsgIdAndTxt("PnP_mex.cpp", "Input matrix must be type double. ");
    }

    //入力読み取り
    double *observe;//corresponding keypoints on the image coordinate
    observe = mxGetPr(prhs[0]);
    int observe_dim = mxGetDimensions(prhs[0])[0];
    int observe_num = mxGetDimensions(prhs[0])[1];
    if(observe_dim != 3){
        mexErrMsgIdAndTxt("PnP_mex.cpp", "1st input arg must be 3xN double matrix. ");
    }

    double *Points3D;//corresponding 3D points
    Points3D = mxGetPr(prhs[1]);
    int Points3D_dim = mxGetDimensions(prhs[1])[0];
    int Points3D_num = mxGetDimensions(prhs[1])[1];
    if(Points3D_dim != 3){
        mexErrMsgIdAndTxt("PnP_mex.cpp", "2nd input arg must be 3xN double matrix. ");
    }
    if(observe_num != Points3D_num){
        mexErrMsgIdAndTxt("PnP_mex.cpp", "You must input corresponding 2D keypoints and 3D points to 1st and 2nd arg. ");
    }

    double *camera;
    camera = mxGetPr(prhs[2]);
    int camera_row = mxGetDimensions(prhs[2])[0];
    int camera_col = mxGetDimensions(prhs[2])[1];
    if( (camera_row != 1) || (camera_col != 7) ){
        mexErrMsgIdAndTxt("PnP_mex.cpp", "3rd input arg must be 1x7 camera matrix. ");
    }


    //TODO: Reprojection error を最小にする camera を求める
    double *camera_optim = camera;

    ceres::Problem problem;
    for(int i=0;i<observe_num;i++)
    {

        ceres::CostFunction* cost_function =
        SnavelyReprojectionErrorWithQuaternions::Create(observe[3*i], observe[3*i+1], observe[3*i+2], 
                                                                                            Points3D[3*i], Points3D[3*i+1], Points3D[3*i+2]);
        problem.AddResidualBlock(cost_function,
                            NULL /* squared loss */,
                            camera_optim);
    }



    ceres::Solver::Options options;
    options.linear_solver_type = ceres::DENSE_SCHUR;
    options.minimizer_progress_to_stdout = false;

    ceres::Solver::Summary summary;
    ceres::Solve(options, &problem, &summary);
    // std::cout << summary.FullReport() << "\n";



    // double p[3];
    // double observed3d_p[3];
    // observed3d_p[0] = Points3D[0];
    // observed3d_p[1] = Points3D[0+1];
    // observed3d_p[2] = Points3D[0+2];
    // ceres::QuaternionRotatePoint(camera, observed3d_p, p);

    // std::cout << p[0] << "," << p[1] << "," << p[2] << "\n";
    // // 1.46913,0.222557,0.660212
    // p[0] += camera[4];
    // p[1] += camera[5];
    // p[2] += camera[6];
    // std::cout << p[0] << "," << p[1] << "," << p[2] << "\n";






    //出力インターフェース
    plhs[0] = mxCreateDoubleMatrix(1, 10, mxREAL);//output_x
    double *camera_ptr = mxGetPr(plhs[0]);
    for(int kk=0;kk<10;kk++){
        camera_ptr[kk] = camera_optim[kk];
    }






}

