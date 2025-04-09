function realignMatWrapper(taskData, figSaveDir)

spikeMat = taskData.spkMat;
trialMat = taskData.trialMat;

%% ASK SHUSH
% appropriate filter size?
% how to stop error bars from wondering off

%% To-Do
% paired-t p-value tables (RF)

tTestValues = zeros(width(spikeMat), 3);

for i = 1:width(spikeMat)
    
    [backRateSummary, backAvgRate] = realignMatBackRate(trialMat, spikeMat{1,i}, taskData.vTimes.tStim);

    uniqueProbes = backRateSummary(:, 1:2);
    backRate = backRateSummary(:, 3);
    avgBackRate = mean(backRateSummary.avgBack, 1);

    PSTH = figure(i);
    subplot(3,1,1)

    [senYLimits, uProbeSen, senRFIdx, senAvgRate] = sensoryRealignMat(trialMat, spikeMat{1,i}, taskData.vTimes.tStim);
    [senH, senP] = realignMatStats(backAvgRate, senRFIdx, senAvgRate);

    subplot(3,1,2)

    [memYLimits, uProbeMem, memRFIdx, memAvgRate] = memoryRealignMat(trialMat, spikeMat{1,i},taskData.vTimes.tGo);
    [memH, memP] = realignMatStats(backAvgRate, memRFIdx, memAvgRate);

    subplot(3,1,3)

    [motYLimits, uProbeMot, motRFIdx, motAvgRate] = motorRealignMat(trialMat, spikeMat{1,i},taskData.vTimes.tSacc);
    [motH, motP] = realignMatStats(backAvgRate, motRFIdx, motAvgRate);

    limitTable = [senYLimits; memYLimits; motYLimits];

    tTestValues(i, 1) = senH;
    tTestValues(i, 2) = memH;
    tTestValues(i, 3) = motH;

    sgtitle(['Cluster ' num2str(taskData.clusterInfo{i, 1}) ' Receptive Field & Non-Receptive Field Peri-Stimulus Time Histograms'])
    
    maxLim = max(limitTable(:, 2));

    for j = 1:3

        subplot(3,1,j)
        ylim([0, maxLim])

    end

    filename = fullfile(figSaveDir, ['Cluster_' num2str(taskData.clusterInfo{i, 1}) '_PSTH']);
    saveas(PSTH, filename,'fig');

    sensRate = uProbeSen(:, 3);
    memRate = uProbeMem(:, 3);
    motRate = uProbeMot(:, 3);

    summaryRates = [uniqueProbes, sensRate, memRate, motRate, backRate];

    [heatMap] = realignMatHeatMap(summaryRates, avgBackRate);
    sgtitle(['Cluster ' num2str(taskData.clusterInfo{i, 1}) ' Receptive Field Heat Maps'])
    
    filenameHM = fullfile(figSaveDir, ['Cluster_' num2str(taskData.clusterInfo{i, 1}) '_Heat_Map']);
    saveas(heatMap, filenameHM,'fig');

    close all

end

[pieChart, sigPieChart] = realignMatPieChart(tTestValues);
filenamePie = fullfile(figSaveDir, 'Population Pie Chart');
filenamePieSig = fullfile(figSaveDir, 'Significant Population Pie Chart');


saveas(pieChart, filenamePie,'fig');
saveas(sigPieChart, filenamePieSig,'fig');

end
