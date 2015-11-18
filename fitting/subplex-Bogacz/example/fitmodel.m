data = getdata ('eriksendata');
goal = mystat (data);
typestat = [1 1 2 2 3 3 3];
stimuli = data (:,7);

%Running a single optimization session (takes about 3min on Pentium 4)
fitparam ('modelstim', [0.4 0.4 0.4 0.4 0.4], goal, typestat, 50, 150, 100, 1);

%Running full 200 sessions takes (about 10 hours on Pentium 4)
%fitparam ('modelstim', [0.4 0.4 0.4 0.4 0.4], goal, typestat, 50, 150, 100, 200);
