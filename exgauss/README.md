# Exgauss


## Overview

Exgauss is a MATLAB toolbox for fitting the ex-Gaussian distribution to data (e.g. response times) using maximum likelihood estimation.

## Getting started


### Requirements

* [MATLAB](http://www.mathworks.com)
* [MATLAB Statistics Toolbox](http://www.mathworks.com/products/statistics/)
* [MATLAB Optimization Toolbox](http://www.mathworks.com/products/optimization/)
* [fminsearchbnd.m](http://www.mathworks.com/matlabcentral/fileexchange/8277-fminsearchbnd-fminsearchcon)


### Intstallation

Get the code as follows:

```
git clone https://github.com/bramzandbelt/exgauss.git
```

You can also download the code as a ZIP file on the right.

### Usage

Obtain best-fitting ex-Gaussian parameters (X) by fitting the ex-Gaussian model to the observed data (y) using a bounded Simplex algorithm and maximum likelihood estimation:

```
[X,fVal,exitFlag,solverOutput] = exgauss_fit(y);
```

Compute Pearson's &chi;<sup>2</sup> goodness-of-fit statistic:

```
chiSquare = exgauss_chi_square(y,X);
```

Plot a histogram of the observed data (y) and and a line plot of the ex-Gaussian probability density function (PDF), using the best-fitting parameters:

```
figure;hold on
exgauss_plot('pdf',y,X);
```

Plot quantiles (.1, .3, .5, .7, .9, hard-coded in `exgauss_plot`) of the observed data (y) and and a line plot of the ex-Gaussian cumulative distribution function (CDF), using the best-fitting parameters:

```
figure;hold on
exgauss_plot('cdf',y,X);
```

Plot both the histogram/PDF and quantiles/CDF in one figure:

```
figure;hold on
exgauss_plot('both',y,X);
```

Print the figure as 'fileName.png' in the present working directory:

```
figure;hold on
exgauss_plot('both',y,X,'fileName');
```

### Citation
If you intend to publish results obtained with this code, you can cite it as follows:
Zandbelt, Bram (2014): exgauss. figshare.
http://dx.doi.org/10.6084/m9.figshare.971318

## Colophon


### Version

Version 1.3 - June 2014

Changes in version 1.3 - Added computation of Pearson's &chi;<sup>2</sup> goodness-of-fit statistic.  
Changes in version 1.2 - Corrected a bug in code for computing the normalized ex-Gaussian probability density function.  
Changes in version 1.1 - Corrected a bug in plotting the PDF,  added functionality for plotting CDFs, and added exporting figure as *.png file.

### Contact

E-mail: bramzandbelt@gmail.com  
Web: www.bramzandbelt.com  

### License

&copy; 2014  Bram B. Zandbelt

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>

### References

Lacouture, Y., & Cousineau, D. (2008). How to use MATLAB to fit the ex-Gaussian and other probability functions to a distribution of response times. Tutorials in Quantitative Methods for Psychology, 4(1), 35-45.  

Lewandowsky, S., & Farrell, S. (2010). Computational modeling in cognition: Principles and practice. Sage.
