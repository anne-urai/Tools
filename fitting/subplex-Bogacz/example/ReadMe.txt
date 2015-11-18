This is an example of a parameterization code for the Eriksen model.
The directory includes following files:

model.c - mex file implementing Eriksen model
modelstim.m - function calling the model with appropriate stimuli sequence
eriksendata - file with behavioral results of Eriksen experiment
getdata.m - a file reading the experimnetal data
mystat.m - function calculating descriptive statistics for the experimental data
fitmodel.m - function calling fitparam with the model
best10.mat - ten top parameterization found (parameterization 9 was reported in the paper)

To run the parameterization:
1. compile the mex-file, i.e. type in Matlab: "mex model.c"
2. add path to fitparam (e.g. using command addpath)
3. type in Matlab: fitmodel

Currently fitmodel.m runs just a single optimization session and writes the results to file model.c
To run more optimization sessions, modify file: fitmodel.m (see inside the file for details)
