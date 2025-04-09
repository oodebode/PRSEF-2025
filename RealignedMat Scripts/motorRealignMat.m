function [yLimits, uniqueProbes, RFIndicies, motorAvgRate] = motorRealignMat(trialMat, spikeMat, vTimes)

% determine the RF with all trial spike rate adapted, plot as following

binSize = 1;
edges = vTimes(1):binSize:vTimes(end);

% filter size?
windowSize = 500;
b = (1/windowSize) * ones(1, windowSize);
a = 1;

motorStart = find(vTimes == -200);
motorEnd = find(vTimes == 100);

trialLoc = trialMat(:, 7:8);


motorEpoch = spikeMat.stimAligned(:, motorStart : motorEnd);

% vCount = mean(sensoryEpoch, 1);

motorAvg = mean(motorEpoch, 2);
motorAvgRate = motorAvg / 0.001;

motorAvgTable = array2table(motorAvg);

motorAvgTable = [trialLoc, motorAvgTable];

uniqueProbes = unique(motorAvgTable(:, {'targetX', 'targetY'}), 'rows');

for j = 1:height(uniqueProbes)
    cProbe = motorAvgTable((uniqueProbes.targetX(j) == ...
        motorAvgTable.targetX) & (uniqueProbes.targetY(j) == ...
        motorAvgTable.targetY), :);
    
    % Find rows where the third column is not NaN
    rowsToKeep = ~isnan(cProbe.motorAvg);
    
    % Keep only those rows
    cleanedData = cProbe(rowsToKeep, :);

    rate = mean(cleanedData(:, 3));

    avgMotor(j, 1) = rate{1,1} / 0.001;

end

uniqueProbes = [uniqueProbes, array2table(avgMotor)];

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

motorRF = [];
motorNRF = [];

for k = 1:height(RFIndicies)

    cTrial = spikeMat.saccAligned(RFIndicies(k, 1), :);

    motorRF = [motorRF; cTrial];

end

% Find rows where the third column is not NaN
rowsToKeepRF = ~isnan(motorRF(:,1));

% Keep only those rows
motorRF = motorRF(rowsToKeepRF, :);

for k = 1:height(NRFIndicies)

    cTrial = spikeMat.saccAligned(NRFIndicies(k, 1), :);

    motorNRF = [motorNRF; cTrial];

end

% Find rows where the third column is not NaN
rowsToKeepNRF = ~isnan(motorNRF(:,1));

% Keep only those rows
motorNRF = motorNRF(rowsToKeepNRF, :);

vCountRF = mean(motorRF, 1) / 0.001;
smoothedCountsRF = filter(b, a, vCountRF);

vCountNRF = mean(motorNRF, 1) / 0.001;
smoothedCountsNRF = filter(b, a, vCountNRF);

plot(edges, smoothedCountsRF,'Color', 'r');
hold on
plot(edges, smoothedCountsNRF,'Color','b');

xlim([-600 600])

xline(-200, 'LineStyle', '--')
xline(100, 'LineStyle', '--')

legend('Receptive Field', 'Non-Receptive Field', 'Location','bestoutside')

yLimits = ylim;

title("Motor Epoch")


end
