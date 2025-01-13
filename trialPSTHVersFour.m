function [maxYLim, SE, smoothHist] = trialPSTHVersFour(trialData, spikeTimes, nNeuron, label, color)

% target onset data, ie. beginning of the test
targetOn = trialData(:,9);

% testing range, home far after target onset are we recording
range = 1.25;

% increments of importance
binSize = 0.05;

% size of histogram bars
edges = -.225:binSize:1.025;
numBins = length(edges) - 1;

% simple moving average filter
windowSize = 5;
b = (1/windowSize) * ones(1, windowSize);
a = 1;

psth = zeros(height(spikeTimes), numBins);

% stores the number of spikes per neuron in each trial
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
% region for each trial rather than average spikes for entire 
counts = counts / height(targetOn);

smoothedCounts = filter(b, a, counts);

% number of fires per neuron stored together
psth(nNeuron, :) = smoothedCounts;

% this is really the RASTER vertially averaged
meanPSTH = mean(psth, 1);

% from counts to rates
spikeRates = meanPSTH / binSize;
% maxRate = ceil(max(spikeRates) / 10) * 10;

% fancy plotting nonsense to cover my confusion..?
binCenters = edges(1:end-1) + diff(edges)/2;

% stats
std_dev = std(spikeRates);
n = length(spikeRates);

SE = std_dev/sqrt(n);

smoothHist = plot(binCenters, spikeRates,'Color', color);
hold on

errorbar(binCenters, spikeRates, SE, 'Color', color);
xlim([-0.2 1])

% formatting
xlabel('Time (s)');
ylabel('Spike Rate (Hz)');
title('Target Onset (Sensory Period)');

xline(0.025, 'Label', "+25ms", "LabelVerticalAlignment", "top","FontSize",6,"LabelHorizontalAlignment","left")
xline(0.325, 'Label', "+325ms", "LabelVerticalAlignment", "top","FontSize",6,"LabelHorizontalAlignment","right")

xlim([-0.2 1])

% hold off

yLimits = ylim();
maxYLim = yLimits(1,2);

end