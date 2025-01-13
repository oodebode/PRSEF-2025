function determineRF(trialData, spikeTimes, nNeuron)

% something weird here: each sCounts should spit out a different max, but
% they are all 35...
[sCounts] = allTrialsSpikeRate(trialData, spikeTimes, nNeuron);

avgBackRate = mean(sCounts.backgroundRate);

uniqueProbes = unique(trialData(:, {'targetX', 'targetY'}), 'rows');

for i = 4:2:10
    
    figIdx = (i / 2) - 1;

    for j = 1:height(uniqueProbes)

    uniqueProbeData{j,1} = sCounts((uniqueProbes.targetX(j) == ...
        sCounts.targetX) & (uniqueProbes.targetY(j) == ...
        sCounts.targetY), :);
    
    dataTable = uniqueProbeData{j};

    averageSpikeRate = mean(dataTable(:, i));

    uniqueProbeData{j,(figIdx + 1)} = averageSpikeRate;
    
    
    end

end

newTable = [];

for k = 2:5

    for m = 1:height(uniqueProbeData)

        newTable(m,k-1) = uniqueProbeData{m,k}{1,1};

    end

end

newTable = array2table(newTable, 'VariableNames', {'backgroundRate', 'sensoryRate', 'motorRate', 'memoryRate'}); 

probeCompare = cat(2, uniqueProbes, newTable);

numericData = table2array(probeCompare);
maxRate = ceil(max(max(numericData(:,3:6))) / 10) * 10 + 5;


%% determine probe location where maximum response is observed
% select two closest probe locations (min possible num trials is 4)
% run paired t test on these trials against their baseline in every
% category

pairedT = table();

%% geometrically determine NRF 
% repeat

neuronLabels = ["Sensory", "Motor", "Memory"];

for n = 4:6
    
    storageIdx = n - 3;
    
    % this should be a function and you know it
    cMaxRate = max(probeCompare{:,n});
    maxProbeLoc = probeCompare(probeCompare{:,n} == cMaxRate, 1:2);

    theoreticalMinProbeLoc = table2array(maxProbeLoc) * -1;

    dOfMax = distanceFormula(maxProbeLoc{1,1}, maxProbeLoc{1,2}, probeCompare{:,1}, probeCompare{:,2});
    dOfMin = distanceFormula(theoreticalMinProbeLoc(1,1), theoreticalMinProbeLoc(1,2), probeCompare{:,1}, probeCompare{:,2});

    maxSortValues = sortrows(dOfMax, 'distance');
    minSortValues = sortrows(dOfMin, 'distance');

    closestTrials = maxSortValues(1:3, :);
    theoClosestTrials = minSortValues(1:3,:);
    
    testedTrials = table();
    inverseTrials = table();
    
    plotMaxResponse = table();
    plotMinResponse = table();

    
    for p = 1:height(closestTrials)
        currentTrial = sCounts((sCounts.targetX == closestTrials.xCords(p)) & ...
                                (sCounts.targetY == closestTrials.yCords(p)), :);

        cInverse = sCounts((sCounts.targetX == theoClosestTrials.xCords(p)) & ...
                                (sCounts.targetY == theoClosestTrials.yCords(p)), :);
        
        cMax = trialData((trialData.targetX == closestTrials.xCords(p)) & ...
                                (trialData.targetY == closestTrials.yCords(p)), :);
        cMin = trialData((trialData.targetX == theoClosestTrials.xCords(p)) & ...
                                (trialData.targetY == theoClosestTrials.yCords(p)), :);
        
        testedTrials = [testedTrials; currentTrial]; 
        inverseTrials = [inverseTrials; cInverse];

        plotMaxResponse = [plotMaxResponse; cMax];
        plotMinResponse = [plotMinResponse; cMin];


    end
    
    % call plotting here
    %% plot ylim as a function of period max response or data max response?
    
    % something is very wrong with the sensory and motor plots
    % currently sets the xlim to be a function of the maximum average rate
    % testRate = max(inverseTrials{:,n});
    % maxRate = ceil(cMaxRate/10)*10;

    label = neuronLabels{storageIdx};
    formatSubplots(plotMaxResponse, plotMinResponse, spikeTimes, nNeuron, label);

    % stats
    % Bonferroni correction?
    periodRate = testedTrials{:, ((n-1)*2)};
    [h,p] = ttest(periodRate, testedTrials.backgroundRate, "Alpha", 0.1/height(periodRate));

    pairedT.hypothesis(storageIdx) = h;
    pairedT.probability(storageIdx) = p;

    inverseRate = inverseTrials{:,((n-1)*2)};
    [null, prob] = ttest(inverseTrials.backgroundRate,inverseRate,"Alpha",0.05/3);

    pairedT.null(storageIdx) = null;
    pairedT.prob(storageIdx) = prob;


end

%% results in some very strange classifications, get checked out
neuronType = classifyType(pairedT);

end
