echo off
%
% SUBPLEX's arguments are used as follows:
%	XBEST	- the value of X returning the lowest value
%       `FUNC'	- a string of the name of the function to be
%		  optimized
%	STARTX	- the initial starting X
%	OPTIONS	- an array of values specifying different options
%		  they are:
%			(1) :if >0, print status every (1) evaluations (def =0)
%			(2) :Tolerance on X (def = 1e-4)
%			(5) :Method to use
%				0 = SUBPLEX (def.)
%				1 = Nelder-Mead Simplex
%				2 = Nelder-Mead Simplex with Restarts
%			(8) :value of FUNX(X) to stop at (def = None)
%			(14):maximum number of evaluations (def = 100*n)
%			(18):starting step size (def = 0.1)
%		  note that it is impossible to have the program stop
%		  when f(x) reaches zero, since it would confuse this with 
%		  no specification.  Rather, simply specify eps or something
%		  similar.
%		  Any array indices specified other than those listed
%		  above will be ignored.
%	FXBEST	- FUNC evaluated at XBEST
%	NUM_EVAL- number of times the function was evaluated
%	INFO	- reason for exit
%			-2: Invalid Input
%			-1: Maximum number of evaluations exceeded
%			 0: tolerance reached
%			 1: limit of machine precision
%			 2: options(8) reached
%	P*	- up to 10 additional parameters can be specified
%

clc
disp ('Options Available for SUBPLEX:')
help subplex_options




