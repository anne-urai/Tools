%# blank image
figure
zeroimage = zeros(799,799);
pal = [1 1 1; 0 0 0];
imshow(zeroimage);
colormap(pal);
set(gca, 'nextplot','replacechildren', 'Visible','off');

%# create AVI object
nFrames = 380;
vidObj = VideoWriter('GridIllusion.avi');
vidObj.Quality = 100;
vidObj.FrameRate = 2;
open(vidObj);

%# preallocate
writeVideo(vidObj, getframe(gca));


% make frames, customscript
middlepointX = [80 240 400 560 720];
middlepointY = [80 240 400 560 720];
zeroimage = zeros(799,799);
size = 4;

for b = 1:38
    for c = 1:length(middlepointX);
        x = middlepointX(c);
        for d = 1:length(middlepointY);
            y = middlepointY(d);
            zeroimage(x-size/2:x+size/2, y-size/2:y+size/2) = 1;
        end;
    end;
    size = size + 4;
   
    imshow(zeroimage); %this is essential
    colormap(pal);     %this is essential
    
    for g = 1:1
        writeVideo(vidObj, getframe(gca)); %this is essential
    end;
    
end;
close(gcf)      %this is essential
close(vidObj);  %this is essential
