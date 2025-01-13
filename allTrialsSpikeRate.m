function [spikeCounts] = allTrialsSpikeRate(trialData, spikeTimes, nNeuron)

spikeCounts = table;
cSpikeTimes = spikeTimes{nNeuron};

%% time intervals, organized by [before, after; ...]
% [sensory, motor, memory, background]
timeIntervals = [0.025, 0.325; 0.1, 0.4; -0.1, 0.2; -0.4, -0.1];
intervalDistance = [0.3, 0.3, 0.3, 0.3];

for i = 1:height(trialData)
    
    cTrial = trialData(i,:);
    
    targetOn = cTrial(1,9);
    targetOff = cTrial(1,11);
    sacTime = cTrial(1,13);
    
    timeVariables = [targetOn{1,:}, targetOff{1,:}, sacTime{1,:}, ...
        targetOn{1,:}];

    % initalize spike counts
    restingCounts = 0;

    sensoryCounts = 0;
    motorCounts = 0;
    memoryCounts = 0;
    
    countTable = [sensoryCounts, motorCounts, memoryCounts,...
        restingCounts];

    for j = 1:width(timeVariables)

        cCount = 0;
        cTimeVariable = timeVariables{1, j};

        cMin = cTimeVariable + timeIntervals(j, 1);
        cMax = cTimeVariable + timeIntervals(j, 2);

        cCount = cSpikeTimes(cSpikeTimes >= cMin & ...
            cSpikeTimes < cMax);
        cCount = cCount - cTimeVariable;

        countTable(1, j) =+ height(cCount);
        
    end

    % cTrialSpikes = cTrialSpikes - targetOn{1,:};
    % cPreTrialSpikes = targetOn{1,:} - cPreTrialSpikes;

    spikeCounts.targetX(i) = cTrial.targetX;
    spikeCounts.targetY(i) = cTrial.targetY;
 
    % calculate spike rates
    spikeCounts.background(i) = countTable(1,4);
    spikeCounts.backgroundRate(i) = countTable(1,4)/0.35;

    spikeCounts.sensory(i) = countTable(1,1);
    spikeCounts.sensoryRate(i) = countTable(1,1)/0.3;

    spikeCounts.motor(i) = countTable(1,2);
    spikeCounts.motorRate(i) = countTable(1,2)/0.3;

    spikeCounts.memory(i) = countTable(1,3);
    spikeCounts.memoryRate(i) = countTable(1,3)/0.3;

end

save(sprintf('n%dSpikeTypeCounts.mat', nNeuron), "spikeCounts");

%% should throw in a script that extracts the maximum response by probe location, 
% then all trials at "reasonably" adjacent probe locations

end