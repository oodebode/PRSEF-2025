function [vSpikeRates] = realignMat(trialData, spikeTimes, nNeuron)

[RF, NRF] = extractRF(trialData, spikeTimes, nNeuron);

% sensory, memory, motor, background (targOn: -0.4, -0.1)
timePeriods = [0.025, 0.325; 0.1, 0.4; -0.1, 0.2];
epochDefinitions = ["targ1_On", "targsOff", "sacTime"];
plottingRange = [-0.2, 1; -0.4, 0.8; -0.6, 0.4];
epochNames = ["Sensory", "Memory", "Motor"];
labels = ["Target Onset (Sensory Period)", "Target Offset (Memory Period)", ...
        "Saccade Time (Motor Period)"];

for j = 1:length(RF) 
    
    plotMaxResponse = RF{j};
    plotMinResponse = NRF{j};

    for n = 1 : height(timePeriods)
    
        [vSpikes, edges] = getSpikeRates(plotMaxResponse, spikeTimes, nNeuron, epochDefinitions(n), timePeriods(n, :), plottingRange(n, :));
        receptiveData{n, 1} = vSpikes;
        receptiveData{n, 2} = edges;
    
        [vSpikeRates, edge] = getSpikeRates(plotMinResponse, spikeTimes, nNeuron, epochDefinitions(n), timePeriods(n, :), plottingRange(n, :));
        nonReceptiveData{n, 1} = vSpikeRates;
        nonReceptiveData{n, 2} = edge;
    
    end
    
    axisLimits = [];
    errorList = [];
    
    figure(j)
    for m = 1 : length(receptiveData)
        
        subplot(1,3,m)
        [plotMax, maxYLimRF, SE_RF] = plotRealignMat(receptiveData{m, 1}, 'r', labels(m), timePeriods(m, :), ...
            plottingRange(m, :), receptiveData{m, 2});
    
        hold on 
        [plotMin, maxYLimNRF, SE_NRF] = plotRealignMat(nonReceptiveData{m, 1}, 'b', labels(m), timePeriods(m, :), ...
            plottingRange(m, :), nonReceptiveData{m, 2});
        
        hold off

        axisLimits = [axisLimits, maxYLimRF, maxYLimNRF];
        errorList = [errorList, SE_RF, SE_NRF];

        legend([plotMax plotMin], {'Receptive Field', 'Non-Receptive Field'}, 'Location','southeast')

    end

    yScalar = max(axisLimits);
    maxError = max(errorList);
    
    yScalar = yScalar + maxError;
    
    for i = 1:3
        
        subplot(1,3,i)
        ylim([0 yScalar])
    
    end
    
    % decide how to save figures
    epochNameStr = char(epochNames(j));
    sgtitle(['Neuron ' num2str(nNeuron) ' ' epochNameStr ' Receptive & Non-Receptive Field Peri-Stimulus Time Histogram']);


end

% run statistics
end