function [songID,indx] = shazy(matchOptions,nSongs,test1)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%threshold for the cross-corr result
threshold = 125;

%get audio data from the recording (audio 16 bit depth)
out1 = getaudiodata(test1, 'int16');

for h = 1: nSongs
    %cross correlation between library and the recorded audio
    [xc{h}, lagc{h}] = xcorr(matchOptions{h}, out1, 'none'); 
    
    %search for the max cross correlation value
    if h == 1
        [maxC, indx] = max(xc{h});
        songNo = 1;
        
    elseif h ~= 1
        if max(xc{h}) > maxC
            [maxC, indx] = max(xc{h});
            songNo = h;
        end
    end
end

%get the index of max value
indx = lagc{songNo}(indx);

%filter with a threshold
if maxC >= threshold
  songID=songNo;
elseif maxC < threshold
  songID=0;
end


end

