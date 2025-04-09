function [uniqueProbes, backAvgRate] = realignMatBackRate(trialMat, spikeMat, vTimes) 

backStart = find(vTimes == -400);
backEnd = find(vTimes == -100);

trialLoc = trialMat(:, 7:8);

backEpoch = spikeMat.stimAligned(:, backStart : backEnd);

backAvg = mean(backEpoch, 2);
backAvgRate = backAvg / 0.001;
backAvgTable = array2table(backAvg);

backAvgTable = [trialLoc, backAvgTable];

uniqueProbes = unique(backAvgTable(:, {'targetX', 'targetY'}), 'rows');

for j = 1:height(uniqueProbes)
    cProbe = backAvgTable((uniqueProbes.targetX(j) == ...
        backAvgTable.targetX) & (uniqueProbes.targetY(j) == ...
        backAvgTable.targetY), :);

    % Find rows where the third column is not NaN
    rowsToKeep = ~isnan(cProbe.backAvg);
    
    % Keep only those rows
    cleanedData = cProbe(rowsToKeep, :);

    rate = mean(cleanedData(:, 3));

    avgBack(j, 1) = rate{1,1} / 0.001;

end

uniqueProbes = [uniqueProbes, array2table(avgBack)];


end
