function cm_data = coolwarm(m)

cm = readtable('CoolWarmFloat257.csv');
cm = cm{:, 2:end};

if nargin < 1
    cm_data = cm;
else
    hsv=rgb2hsv(cm);
    cm_data=interp1(linspace(0,1,size(cm,1)),hsv,linspace(0,1,m));
    cm_data=hsv2rgb(cm_data);
  
end