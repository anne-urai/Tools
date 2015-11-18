echo off
%
%	The SUBPLEX method is a generalization of the Nelder-Mead Simplex (NMS)
% method.  It works by decomposing a high-dimensioned problems into
% low-dimensioned sub-spaces which are easily handled by NMS.  
% 	Because of its relationship with NMS, SUBPLEX retains the advantages
% of NMS on noisy functions.
%
%	SUBPLEX was developed by Tom Rowan for his Ph.D. Thesis: Functional
% Stability Analysis of Numerical Algorithms (University of Texas at Austin).
% Although SUBPLEX was originally developed as a routine for this analysis,
% it is a general-purpose algorithm well suited for optimization of high-
% dimensional noisy functions.
%
clc
disp ('About SUBPLEX:')
help about_subplex
