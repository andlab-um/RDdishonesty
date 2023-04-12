#include <Rcpp.h>
#include <RcppParallel.h>
#include <math.h>
#include <iostream>
#include <vector>
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/normal_distribution.hpp>
#include <boost/random/variate_generator.hpp>
#include <ctime>

using namespace Rcpp;
using namespace RcppParallel;

typedef boost::mt19937                     ENG;    // Mersenne Twister
typedef boost::normal_distribution<double> DIST;   // Normal Distribution
typedef boost::variate_generator<ENG,DIST> GEN;    // Variate generator



// [[Rcpp::depends(RcppParallel)]]
struct ddm2w : public Worker {
  
  // input vectors/matrices to read from
  const double drate; // the drift rate for monetary reward and consistency

  const double nDT; // non-decision time

  const double moneydiff;
  const double consdiff;
  
  GEN gen;
  
  // output vector to write to
  RVector<double> vecOut;
  
  // initialize from Rcpp input and output matrixes/vectors (the RMatrix/RVector class
  // can be automatically converted to from the Rcpp matrix/vector type)
  ddm2w(const double drate, const double nDT, const double moneydiff, const double consdiff, NumericVector vecOut , GEN gen)
    : drate(drate), nDT(nDT), moneydiff(moneydiff), consdiff(consdiff), gen(gen), vecOut(vecOut) {}
  
  // function call operator that work for the specified range (begin/end)
  void operator()(std::size_t begin, std::size_t end) {
    
    double T = 4, dt , lt=1024;
    dt = (T/lt);
    
    std::vector<double> vec_t(lt,0);
    
    
    for (int t=nDT/dt; t<lt; t++) {
      vec_t[t] = 1;

    }
    
    for (std::size_t i = begin; i < end; i++) {
      vecOut[i] = T;
      double X = 0;
      int flag = 0;
      double cont = 0;
      double thres=2.5;
      while (flag==0 && cont<lt) {
        
        X = X + drate*(moneydiff + consdiff)*vec_t[cont]*dt + gen()*sqrt(dt);
        if (X > thres) {
          flag=1;
          //vecOut[i] = nDT + cont*dt;
          vecOut[i] = cont*dt;
        }
        else if (X < -thres) {
          flag=1;
          //vecOut[i] = -nDT -cont*dt;
          vecOut[i] = -cont*dt;
        }
        cont++;
      }
      
    }
  }
};


// [[Rcpp::export]]
NumericVector sddm_parallel(double drate, double nDT, double moneydiff, double consdiff, unsigned int N) {
  
  const double sd_n = 1.4;
  struct timespec time;
  clock_gettime(CLOCK_REALTIME, &time);
  ENG  eng;
  eng.seed(time.tv_nsec);
  DIST dist(0,sd_n);
  GEN  gen(eng,dist);
  
  //output vector
  NumericVector vecOut(N);
  
  // create the worker
  ddm2w ddm2w(drate, nDT, moneydiff, consdiff, vecOut, gen);
  
  // call the worker
  parallelFor(0, N, ddm2w);
  
  return vecOut;
}
