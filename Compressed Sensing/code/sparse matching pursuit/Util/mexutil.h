#ifndef MEXUTIL_H
#define MEXUTIL_H

#include "mex.h"

/* Pauses for a small time allowing matlab to refresh the display */
void MatlabDrawNow()
{
    mexEvalString("drawnow;");
}

#endif  /* MEXUTIL_H */
