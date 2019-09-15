// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// hashstr2i
NumericVector hashstr2i(std::vector< std::string > x, int ngrps);
RcppExport SEXP _disk_frame_hashstr2i(SEXP xSEXP, SEXP ngrpsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::vector< std::string > >::type x(xSEXP);
    Rcpp::traits::input_parameter< int >::type ngrps(ngrpsSEXP);
    rcpp_result_gen = Rcpp::wrap(hashstr2i(x, ngrps));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_disk_frame_hashstr2i", (DL_FUNC) &_disk_frame_hashstr2i, 2},
    {NULL, NULL, 0}
};

RcppExport void R_init_disk_frame(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}