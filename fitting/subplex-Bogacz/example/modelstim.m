function s = modelstim (p)

if ~exist('stimuli')
   data = getdata('eriksendata');
   stimuli = data (:,7);
end
s = model (p, stimuli);