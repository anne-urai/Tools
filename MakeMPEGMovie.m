%% make a movie out of frames taken from the Psychtoolbox

%# create AVI object
vidObj = VideoWriter('Radial_Linear_Gratings_2spatialfreq.avi');
vidObj.Quality = 100;
vidObj.FrameRate = round(window.frameRate);
open(vidObj);

for t = 1:length(imageArray),
    
writeVideo(vidObj, imageArray{t});
end

close(vidObj);  %this is essential