function [uniqueProbeData] = createHeatMaps(trialData, spikeTimes, nNeuron)

[sCounts] = allTrialsSpikeRate(trialData, spikeTimes, nNeuron);

avgBackRate = mean(sCounts.backgroundRate);

%% plotting crap
% finds the number of unique x AND y locations
uniqueProbes = unique(trialData(:, {'targetX', 'targetY'}), 'rows');

% attempts to normalize the coordinates into a matrix
matrixSize = 801;
% heatMap = zeros(matrixSize);
centerIdx = (matrixSize + 1) / 2;

uniqueProbes.plottingX = round(uniqueProbes.targetX + centerIdx); 
uniqueProbes.plottingY = round(uniqueProbes.targetY + centerIdx); 

% heatMap(:,:) = avgBackRate;
heatMapLabels = ["Sensory", "Motor", "Memory"];
figureOrder = [1,3,2];

colorLimits = [];

for i = 6:2:10
    
    cHeatMap = zeros(matrixSize);
    cHeatMap(:,:) = avgBackRate;
    figIdx = (i / 2) - 2;

    for j = 1:height(uniqueProbes)

    uniqueProbeData{j,1} = sCounts((uniqueProbes.targetX(j) == ...
        sCounts.targetX) & (uniqueProbes.targetY(j) == ...
        sCounts.targetY),:);
    
    %% should specify which rate
    dataTable = uniqueProbeData{j};
    % tester = dataTable(:,i);

    averageSpikeRate = mean(dataTable(:, i));
    % avgSpike = averageSpikeRate{1,1};
    % 
    % if (avgSpike > cMax)
    %     cMax = avgSpike;
    % end
    % 
    % if (avgSpike < cMin)
    %     cMin = avgSpike;
    % end

    uniqueProbeData{j,(figIdx + 1)} = averageSpikeRate;
    
    
    end


    for k = 1:height(uniqueProbes)
        % heatMap(uniqueProbes.plottingX(k),uniqueProbes.plottingY(k)) = spikeCounts{k,2};

        helperTable = uniqueProbeData{k, (figIdx + 1)};
        cHeatMap(uniqueProbes.plottingX(k)-10:uniqueProbes.plottingX(k)+10, ...
            uniqueProbes.plottingY(k)-10:uniqueProbes.plottingY(k)+10) = helperTable{1,1};
    end

    
    % figure(figureIdx);
    
    figLoc = figureOrder(figIdx);
    subplot(3,1,figLoc)

    a = imgaussfilt(cHeatMap, 50);
    imagesc(a);
    % colormap(hot);
    colorbar;

    ax1 = gca;
    cLim = ax1.CLim;

    colorLimits(figIdx, 1:2) = cLim;

    axis off equal
    
    label = heatMapLabels{figIdx};
    title(['Neuron ' num2str(nNeuron) ' ' label ' Receptive Field Map']);
    % savefig(sprintf('neuron#%d_%s_heatmap', nNeuron, heatMapLabels{figureIdx}));


end

cMin = min(cLim);
cMax = max(cLim);

for m = 1:3
    subplot(3, 1, m)
    clim([cMin cMax])
end

sgtitle(['Two Dimensional Gaussian Neuron ' num2str(nNeuron) ' Neural Data']);
savefig(sprintf('neuron#%dheatmap', nNeuron));


end
