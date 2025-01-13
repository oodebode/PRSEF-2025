function twoDGaussian(trialData,spikeTimes,nNeuron)
%% inputs: trial data, spike times, the number of the examined neuron

% finds the number of unique x AND y locations
uniqueProbes = unique(trialData(:, {'targetX', 'targetY'}), 'rows');
% future storage of data
uniqueProbeData = cell(height(uniqueProbes), 1);

% attempts to normalize the coordinates into a matrix
matrixSize = 801;
heatMap = zeros(matrixSize);
centerIdx = (matrixSize + 1) / 2;

uniqueProbes.plottingX = round(uniqueProbes.targetX + centerIdx); 
uniqueProbes.plottingY = round(uniqueProbes.targetY + centerIdx); 

% extracts the trials for each probe location
% one big loop
for i = 1:height(uniqueProbes)

    cTrial = uniqueProbes(i,:);
    uniqueProbeData{i} = trialData((trialData.targetX == cTrial.targetX) & (trialData.targetY == cTrial.targetY),:);

    % initalize spike counts
    counts = 0;
    
    cLocation = uniqueProbeData{i};

    targetOn = cLocation(:, 9);

    for k = 1:height(cLocation)
        cTrialStart = targetOn{k,:};
        targetRangeMax = targetOn{k,:} + 0.35;
        
        cSpikeTimes = spikeTimes{nNeuron};

        cTrialSpikes = cSpikeTimes(cSpikeTimes >= cTrialStart & cSpikeTimes < targetRangeMax);
    
        cTrialSpikes = cTrialSpikes - targetOn{k,:};
        counts = counts + height(cTrialSpikes);
    end

    spikeCounts(i,1) = counts;

    % calculate spike rates
    spikeCounts(i,2) = counts/0.3;
    
    for j = 1:height(spikeCounts)
        heatMap(uniqueProbes.plottingX,uniqueProbes.plottingY) = spikeCounts(j,2);
        % heatMap(uniqueProbes.plottingX-5:uniqueProbes.plottingX+5,
        % uniqueProbes.plottingY-5:uniqueProbes.plottingY+5) = spikeCounts(j,2);
    end

end

%% take the a spike rate of each trial from target onset to t+0.35
% only pull the data from the probe location I want to plot 

% run the filter and plot
%% does not work correctly
a = imgaussfilt(heatMap);
imagesc(a);
colormap(hot);
colorbar;
axis equal

end
