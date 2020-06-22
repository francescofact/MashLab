function [choice,indx, maxValues] = shazy(matchOptions,nSongs,audio)
%shazy exec cross correlation and get the index of the matched song
%   Detailed explanation goes here
maxValues=[];

%threshold for the cross-corr result
threshold = 125;

%get audio data from the recording (audio 16 bit depth)
out1 = getaudiodata(audio, 'int16');

for k = 1: nSongs
    %cross correlation between library and the recorded audio
    [xc{k}, lagc{k}] = xcorr(matchOptions{k}, out1, 'none'); 
    
    [maxValue, maxValueIndex] = max(xc{k});
    maxValues(k) = maxValue;
    
    if k == 1
        topValue=maxValue;
        choice = k;
        indx = maxValueIndex;
    else
        if maxValue > topValue
            topValue = maxValue;
            choice = k;
            indx = maxValueIndex;
        end
    end
    
end

%search for the max cross correlation value

%idx refers to the index of the xc array..
%but i need the index in lagc for time estimation
%get the index of max value 
indx = lagc{choice}(indx);

%filter with a threshold
if maxValue < threshold
  choice=0;
end


end

