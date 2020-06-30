function [choice,indx, maxValues] = shazy(matchOptions,nSongs,audio,useGPU)
%shazy esegue la cross correlazione e ottiene l'indice della canzone
%corrispondente

maxValues=[];

%threshold per rilevare musica
threshold = 300;

%ottengo audio dalla registrazione (a 16 bit di profondità)
out1 = getaudiodata(audio, 'int16');

if (mean(abs(out1))< threshold)
    choice = 0;
    indx = 1;
    return
end

for k = 1: nSongs
    %cross correlazione tra libreria e audio registrato
    if (useGPU == 1 && gpuDeviceCount>0)
        try
            [xc{k}, lagc{k}] = xcorr(gpuArray(matchOptions{k}), gpuArray(out1) , 'none'); 
            xc{k} = gather(xc{k}); %da gpuArray a double array
        catch
            [xc{k}, lagc{k}] = xcorr(matchOptions{k}, out1); 
        end
    else
        [xc{k}, lagc{k}] = xcorr(matchOptions{k}, out1); 
    end
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

%cerco il valore massimo di cross correlazione
%idx è l'indice dell'array xc
%ma ho bisogno dell'indice in lagc per stimare il tempo del match
indx = lagc{choice}(indx);

end

