function [maxRate] = trialPSTHVersThree(trialData, spikeTimes, quadNum, nNeuron)

% target onset data, ie. beginning of the test
targetOn = trialData(:,9);

% testing range, home far after target onset are we recording
range = 1;

% increments of importance
binSize = 0.05;

% size of histogram bars
edges = -.4:binSize:range;
numBins = length(edges) - 1;

% simple moving average filter
windowSize = 5;
b = (1/windowSize) * ones(1, windowSize);
a = 1;

psth = zeros(height(spikeTimes), numBins);

% stores the number of spikes per neuron in each trial (in each quadrant)
threeNeuronSpike = cell(length(spikeTimes), 1);
trialStartColumn = 'targ1_On';

cSpikeTime = spikeTimes{nNeuron};
neuronPSTH = cell(height(targetOn), 1);

% how many times did a given neuron spike during a trial
counts = zeros(1, numBins);

for j = 1:height(targetOn)

    % counts = 0;
    cTrialStart = targetOn{j,trialStartColumn} - 0.4;
    targetRangeMax = targetOn{j,trialStartColumn} + range;

    cTrialSpike = cSpikeTime(cSpikeTime >= cTrialStart & cSpikeTime < targetRangeMax);
    
    % delta from target onset (0)
    cTrialSpike = cTrialSpike - targetOn{j,trialStartColumn};

    neuronPSTH{j} = cTrialSpike;

    countsTrial = histcounts(cTrialSpike, edges);

    counts = counts + countsTrial;
end

% MUST NORMALIZE COUNTS --> average spike rate accross all trials within
% region for each trial rather than average spikes for entire quadrant
counts = counts / height(targetOn);

smoothedCounts = filter(b, a, counts);

% number of fires per neuron stored together
psth(nNeuron, :) = smoothedCounts;
threeNeuronSpike{nNeuron} = neuronPSTH;

% this is really the RASTER vertially averaged
meanPSTH = mean(psth, 1);

% from counts to rates
spikeRates = meanPSTH / binSize;
maxRate = ceil(max(spikeRates) / 10) * 10;

% fancy plotting nonsense to cover my confusion..?
binCenters = edges(1:end-1) + diff(edges)/2;

% stats
std_dev = std(spikeRates);
n = length(spikeRates);

SE = std_dev/sqrt(n);

upperBound = smoothedCounts + SE;
lowerBound = smoothedCounts - SE;

% plot(binCenters, upper_bound, 'r', 'LineWidth', 1);
% plot(binCenters, lower_bound, 'r', 'LineWidth', 1);

xLimits = xlim; 

lowerMin = spikeRates - SE;
upperMax = spikeRates + SE;

lowerMin(lowerMin < xLimits(1)) = xLimits(1); 
upperMax(upperMax > xLimits(2)) = xLimits(2); 


smoothHist = plot(binCenters, spikeRates);
hold on

errorbar(binCenters, spikeRates, SE);

% formatting
xlabel('Time (s)');
ylabel('Spike Rate (Hz)');
title(['Neuron ' num2str(nNeuron) ' Quadrant ' num2str(quadNum) ' PSTH']);

xline(0, 'Label', "Target Onset", "LabelVerticalAlignment","top","FontSize",6,"LabelHorizontalAlignment","left")
xline(0.25, 'Label', "+250 ms", "LabelVerticalAlignment","top","FontSize",6,"LabelHorizontalAlignment","right")

xlim([-0.25 1])

% text(mean(binCenters), max(smoothedCounts) * 0.8, ['Standard Error = ', num2str(SE)], ...
%     'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

hold off

end