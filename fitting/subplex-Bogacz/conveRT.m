function [ns, STEP, DELAY] = conveRT (s, g, typestat)

%Function converts statistics concerning reaction time from model units to milliseconds.

TALL = find (typestat == 2);
DALL = find (typestat == 3);
ns = s;

sumsT = sum (s (TALL));
sumsD2 = sum (s (DALL) .^ 2);
if sumsT == 0 & sumsD2 == 0
 STEP = 0;
 DELAY = 0;
else
 NT = length (TALL);
 sumgT = sum (g (TALL));
 sumsT2 = sum (s (TALL) .^ 2);
 if sumsD2 == 0
  sumsDgD = 0;
 else
  sumsDgD = sum (s (DALL) .* g (DALL));
 end
 if sumsT == 0
  STEP = sumsDgD / sumsD2;
  DELAY = 0;
 else  
  sumsTgT = sum (s (TALL) .* g (TALL));
  STEP = (sumsTgT + sumsDgD - sumgT*sumsT/NT) / (sumsT2 + sumsD2 - sumsT^2/NT);
  DELAY = (sumgT - STEP * sumsT) /NT;
  if DELAY < 0
   DELAY = 0;
   STEP = (sumsTgT + sumsDgD) / (sumsT2 + sumsD2);  
  end
 end
 if STEP < 0
  STEP = 0;
 end
 ns(TALL) = s(TALL) * STEP + DELAY;
 ns(DALL) = s(DALL) * STEP;
end
