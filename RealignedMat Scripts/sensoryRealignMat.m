function [yLimits, uniqueProbes, RFIndicies, sensoryAvgRate] = sensoryRealignMat(trialMat, spikeMat, vTimes)

% determine the RF with all trial spike rate adapted, plot as following

binSize = 1;
edges = vTimes(1):binSize:vTimes(end);

% filter size?
windowSize = 500;
b = (1/windowSize) * ones(1, windowSize);
a = 1;

sensoryStart = find(vTimes == 25);
sensoryEnd = find(vTimes == 325);

trialLoc = trialMat(:, 7:8);


sensoryEpoch = spikeMat.stimAligned(:, sensoryStart : sensoryEnd);

% vCount = mean(sensoryEpoch, 1);

sensoryAvg = mean(sensoryEpoch, 2);
sensoryAvgRate = sensoryAvg / 0.001;

sensoryAvgTable = array2table(sensoryAvg);

sensoryAvgTable = [trialLoc, sensoryAvgTable];

uniqueProbes = unique(sensoryAvgTable(:, {'targetX', 'targetY'}), 'rows');

for j = 1:height(uniqueProbes)
    cProbe = sensoryAvgTable((uniqueProbes.targetX(j) == ...
        sensoryAvgTable.targetX) & (uniqueProbes.targetY(j) == ...
        sensoryAvgTable.targetY), :);

    % Find rows where the third column is not NaN
    rowsToKeep = ~isnan(cProbe.sensoryAvg);
    
    % Keep only those rows
    cleanedData = cProbe(rowsToKeep, :);

    rate = mean(cleanedData(:, 3));

    avgSensory(j, 1) = rate{1,1} / 0.001;

end

uniqueProbes = [uniqueProbes, array2table(avgSensory)];

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

sensoryRF = [];
sensoryNRF = [];

for k = 1:height(RFIndicies)

    cTrial = spikeMat.stimAligned(RFIndicies(k, 1), :);

    sensoryRF = [sensoryRF; cTrial];

end

% Find rows where the third column is not NaN
rowsToKeepRF = ~isnan(sensoryRF(:,1));

% Keep only those rows
sensoryRF = sensoryRF(rowsToKeepRF, :);

for k = 1:height(NRFIndicies)

    cTrial = spikeMat.stimAligned(NRFIndicies(k, 1), :);

    sensoryNRF = [sensoryNRF; cTrial];

end

% Find rows where the third column is not NaN
rowsToKeepNRF = ~isnan(sensoryNRF(:,1));

% Keep only those rows
sensoryNRF = sensoryNRF(rowsToKeepNRF, :);

% RF
vCountRF = mean(sensoryRF, 1) / 0.001;
smoothedCountsRF = filter(b, a, vCountRF);

rf_std_dev = std(vCountRF);
rf_n = length(vCountRF);

rf_SE = rf_std_dev/sqrt(rf_n);

% NRF
vCountNRF = mean(sensoryNRF, 1) / 0.001;
smoothedCountsNRF = filter(b, a, vCountNRF);

nrf_std_dev = std(vCountRF);
nrf_n = length(vCountRF);

nrf_SE = nrf_std_dev/sqrt(nrf_n);

binCenters = edges(1:end-1) + diff(edges) / 2;

plot(edges, smoothedCountsRF,'Color', 'r');
% errorbar(binCenters, smoothedCountsRF, rf_SE, 'Color', 'r');
hold on
plot(edges, smoothedCountsNRF,'Color','b');
% errorbar(binCenters, smoothedCountsNRF, nrf_SE, 'Color', 'r');
hold off

xlim([-200 1000])

xline(25, 'LineStyle', '--')
xline(325, 'LineStyle', '--')


legend('Receptive Field', 'Non-Receptive Field', 'Location','bestoutside')

yLimits = ylim;

title("Sensory Epoch")

end
