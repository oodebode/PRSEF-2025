function [appendType] = doStatsSacc(spikeCountsTable, nNeuron)

%% extract trials in RF and opposing field

avgBackRate = mean(spikeCountsTable.backgroundRate);

[sensoryH, sensoryP] = ttest(spikeCountsTable.sensoryRate, spikeCountsTable.backgroundRate,"Alpha", 0.05);
[motorH, motorP] = ttest(spikeCountsTable.motorRate, spikeCountsTable.backgroundRate,"Alpha", 0.05);
[memoryH, memoryP] = ttest(spikeCountsTable.memoryRate, spikeCountsTable.backgroundRate,"Alpha", 0.05);

statsTable = [sensoryH, sensoryP; motorH, motorP; memoryH, memoryP];
save(sprintf('n%dSpikeRateStats.mat', nNeuron), "statsTable");

end