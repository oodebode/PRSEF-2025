function [yLimits, uniqueProbes, RFIndicies, memoryAvgRate] = memoryRealignMat(trialMat, spikeMat, vTimes)

% determine the RF with all trial spike rate adapted, plot as following

binSize = 1;
edges = vTimes(1):binSize:vTimes(end);

% filter size?
windowSize = 500;
b = (1/windowSize) * ones(1, windowSize);
a = 1;

memoryStart = find(vTimes == 100);
memoryEnd = find(vTimes == 400);

trialLoc = trialMat(:, 7:8);


memoryEpoch = spikeMat.goAligned(:, memoryStart : memoryEnd);

% vCount = mean(sensoryEpoch, 1);

memoryAvg = mean(memoryEpoch, 2);
memoryAvgRate = memoryAvg / 0.001;

memoryAvgTable = array2table(memoryAvg);

memoryAvgTable = [trialLoc, memoryAvgTable];

uniqueProbes = unique(memoryAvgTable(:, {'targetX', 'targetY'}), 'rows');

for j = 1:height(uniqueProbes)
    cProbe = memoryAvgTable((uniqueProbes.targetX(j) == ...
        memoryAvgTable.targetX) & (uniqueProbes.targetY(j) == ...
        memoryAvgTable.targetY), :);
    
    % Find rows where the third column is not NaN
    rowsToKeep = ~isnan(cProbe.memoryAvg);
    
    cleanedData = cProbe(rowsToKeep, :);

    % Keep only those rows
    rate = mean(cleanedData(:, 3));

    avgMemory(j, 1) = rate{1,1} / 0.001;

end

uniqueProbes = [uniqueProbes, array2table(avgMemory)];

[~, maxIdx] = max(uniqueProbes(:, 3));
maxIdx = maxIdx{1,1};
rfIdx = uniqueProbes(maxIdx, 1:2);

minDistance = distanceFormula(rfIdx{1,1}, rfIdx{1,2}, uniqueProbes{:,1}, uniqueProbes{:,2});
maxSortValues = sortrows(minDistance, 'distance');

closestTrials = maxSortValues(1:3, :);
furthestTrials = maxSortValues(end-2:end, :);

RFIndicies = [];
NRFIndicies = [];

for p = 1:height(closestTrials)

    cRow = find(trialMat.targetX == closestTrials.xCords(p) & ...
        trialMat.targetY == closestTrials.yCords(p));
    
    % Append the matching rows to the result
    RFIndicies = [RFIndicies; cRow];
end

for p = 1:height(furthestTrials)

    cRow = find(trialMat.targetX == furthestTrials.xCords(p) & ...
        trialMat.targetY == furthestTrials.yCords(p));
    
    % Append the matching rows to the result
    NRFIndicies = [NRFIndicies; cRow];
end

memoryRF = [];
memoryNRF = [];

for k = 1:height(RFIndicies)

    cTrial = spikeMat.goAligned(RFIndicies(k, 1), :);

    memoryRF = [memoryRF; cTrial];

end

% Find rows where the third column is not NaN
rowsToKeepRF = ~isnan(memoryRF(:,1));

% Keep only those rows
memoryRF = memoryRF(rowsToKeepRF, :);

for k = 1:height(NRFIndicies)

    cTrial = spikeMat.goAligned(NRFIndicies(k, 1), :);

    memoryNRF = [memoryNRF; cTrial];

end

% Find rows where the third column is not NaN
rowsToKeepNRF = ~isnan(memoryNRF(:,1));

% Keep only those rows
memoryNRF = memoryNRF(rowsToKeepNRF, :);

vCountRF = mean(memoryRF, 1) / 0.001;
smoothedCountsRF = filter(b, a, vCountRF);

vCountNRF = mean(memoryNRF, 1) / 0.001;
smoothedCountsNRF = filter(b, a, vCountNRF);

plot(edges, smoothedCountsRF,'Color', 'r');
hold on
plot(edges, smoothedCountsNRF,'Color','b');
hold off

xlim([200 1400])


xline(400, 'LineStyle', '--')
xline(700, 'LineStyle', '--')

legend('Receptive Field', 'Non-Receptive Field', 'Location','bestoutside')

yLimits = ylim;

title("Memory Epoch")

end
