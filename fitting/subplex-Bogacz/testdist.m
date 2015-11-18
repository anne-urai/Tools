function testdist (numstat)

NUMSIM = 10000;

for i = 1:NUMSIM
    cost(i) = 0;
    for s = 1:numstat
        sim = randn(1,10);
        x = randn(1);
        cost(i) = cost(i) + ((x-mean(sim))/std(sim,1)) ^ 2 * 9/11;
    end
end

figure(2);
plot (histc (cost, 0:30));
hold on
mydist  = costdist ([0.5:29.5], numstat);
plot (mydist * NUMSIM, 'r');
td =  sum ((tinv (rand(numstat,NUMSIM), 9)).^2);
plot (histc (td, 0:30), 'g');
    