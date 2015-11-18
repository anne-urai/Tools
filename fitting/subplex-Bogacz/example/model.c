/*Fast implementation of Eriksen model as a mex file*/

#include <math.h>
#include "mex.h"

/*number of iterations after which simulations are stoped even if no threshold is reached*/
#define TIMEOUT 50  

/*noise used*/
#define NOISE c*(0.001*(rand()%1000)-0.5)

/*statistics*/
#define ERC 0
#define ERI 1
#define RTC 2
#define RTI 3
#define RTD 4	/*difference between the reaction time for correct and error trials*/
#define SDC 5	/*standard deviation of reaction time for compatible*/
#define SDI 6

/*truncated hyperbolic tangent - nonlinearity of units*/
double trf (double x)
{
 return (x<0 ? 0 : tanh(x));
}

/*main function*/
void finderror (double *param, int numstim, double *stimuli, double *s)
{
 /*input parameters*/
 double a = param[0];
 double b = param[1];
 double c = param[2];
 double d = param[3];
 double z = param[4];

 /*activation levels of connectionist units*/
 double xc1, xc2, xf1, xf2, y1, y2, xl1, xl2;

 /*activations of flanker input units*/
 int inf1, inf2;

 /*index of stimulus in the run*/
 int stim;

 /*level of inhibition*/
 double inh;

 /*time*/
 int t;
 
 /*variables required to calulate statistics*/
 int nocom = 0;		/*number of compatibile stimuli*/
 double rtcor = 0;	/*mean reaction time of correct trials*/
 double rtincor = 0;    /*mean reaction time on incorrect trials*/
 for (t=0; t<7; t++)
  s[t] = 0;
  
 mexPrintf ("a=%f b=%f c=%f d=%f z=%f\n", a, b, c, d, z);

 /*main simulation loop*/
 for (stim=0; stim<numstim; stim++)
 {
  xc1 = xc2 = xf1 = xf2 = y1 = y2 = xl1 = xl2 = 0;
  inf1 = 1 - stimuli[stim];
  inf2 = stimuli[stim];
  t = 0;
  while ((y1<z) && (y2<z) && (t<TIMEOUT))
  {
   t++;
   inh = (y1 + y2) * d;
   y1 = trf (y1 + a*(xc1+xf1+xl1) + NOISE - inh);
   y2 = trf (y2 + a*(xc2+xf2+xl2) + NOISE - inh);
   inh = (xc1 + xc2 + xf1 + xf2 + xl1 + xl2) * d;
   xc1 = trf (xc1 + a + b + NOISE - inh);
   xc2 = trf (xc2 + b + NOISE - inh);
   xf1 = trf (xf1 + a*inf1 + NOISE - inh);
   xf2 = trf (xf2 + a*inf2 + NOISE - inh);
   xl1 = trf (xl1 + a*inf1 + NOISE - inh);
   xl2 = trf (xl2 + a*inf2 + NOISE - inh);
  }
  if (stimuli[stim])
  {
   s[ERI] += (y2>y1);
   s[RTI] += t;
   s[SDI] += t*t;
  }
  else
  {
   s[ERC] += (y2>y1);
   s[RTC] += t;
   s[SDC] += t*t;
   nocom++;
  }
  if (y2>y1)
   rtincor += t;
  else
   rtcor += t;
 }
 
 rtcor /= numstim - s[ERC] - s[ERI];
 rtincor /= s[ERC] + s[ERI];
 s[RTD] = rtcor - rtincor;
 s[ERC] /= nocom;
 s[ERI] /= numstim - nocom;
 s[RTC] /= nocom;
 s[RTI] /= numstim - nocom;
 s[SDC] /= nocom;
 s[SDI] /= numstim - nocom;
 s[SDC] = sqrt(s[SDC] - s[RTC]*s[RTC]);
 s[SDI] = sqrt(s[SDI] - s[RTI]*s[RTI]);

 mexPrintf ("ErCom=%f ErIncom=%f RTCom=%f RTIncom=%f RT(cor-incor)=%f RTDvCom=%f RTDvIncom=%f\n",
 	    s[ERC], s[ERI], s[RTC], s[RTI], s[RTD], s[SDC], s[SDI]); 
}

void mexFunction (int nlhs, mxArray *plhs[],
		  int nrhs, const mxArray *prhs[])
{
 double *param;		/*model parameters*/
 int numstim;		/*number of presented stimuli*/
 double *stimuli;	/*series of stimuli: 0-compatibile, 1-incompatibile*/
 double *stat;		/*error statistics*/
 
 plhs[0] = mxCreateDoubleMatrix (1, 7, mxREAL);
 
 param = mxGetPr (prhs[0]);
 numstim = mxGetM (prhs[1]);
 stimuli = mxGetPr (prhs[1]);
 stat = mxGetPr (plhs[0]);

 finderror (param, numstim, stimuli, stat);
}
