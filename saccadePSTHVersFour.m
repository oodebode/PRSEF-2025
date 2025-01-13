function [maxYLim, SE, smoothHist] = saccadePSTHVersFour(trialData, spikeTimes, nNeuron, label, color)

%% target onset data, ie. beginning of the test
sacTime = trialData(:,13);

% testing range, home far after target onset are we recording
range = 0.8;

%% increments of importance
binSize = 0.05;

%% size of histogram bars
edges = -.625:binSize:0.625;
numBins = length(edges) - 1;

%% simple moving average filter
windowSize = 5;
b = (1/windowSize)*ones(1, windowSize);
a = 1;

psth = zeros(height(spikeTimes), numBins);

%% stores the number of spikes per neuron in each trial (in each quadrant)
trialStartColumn = 'sacTime';


cSpikeTime = spikeTimes{nNeuron};

neuronPSTH = cell(height(sacTime), 1);

%% how many times did a given neuron spike during a trial
counts = zeros(1, numBins);

for j = 1:height(sacTime)
    cTrialStart = sacTime{j,trialStartColumn} - 0.8;
    targetRangeMax = sacTime{j,trialStartColumn} + range;

    cTrialSpike = cSpikeTime(cSpikeTime >= cTrialStart & cSpikeTime < targetRangeMax);
    
    cTrialSpike = cTrialSpike - sacTime{j,trialStartColumn};

    neuronPSTH{j} = cTrialSpike;

    countsTrial = histcounts(cTrialSpike, edges);

    counts = counts + countsTrial;
end

% normalize counts 
counts = counts / height(sacTime);

smoothedCounts = filter(b, a, counts);

% number of fires per neuron normalized, stored together
psth(nNeuron, :) = smoothedCounts;

% this is really the RASTER vertially averaged
meanPSTH = mean(psth, 1);

% from counts to rates
spikeRates = meanPSTH / binSize;
% maxRate = ceil(max(spikeRates) / 10) * 10;

% plotting
binCenters = edges(1:end-1) + diff(edges)/2;

% stats
std_dev = std(spikeRates);
n = length(spikeRates);

SE = std_dev/sqrt(n);


smoothHist = plot(binCenters, spikeRates, 'Color', color);
hold on
errorbar(binCenters, spikeRates, SE, 'Color', color);
xlim([-0.2 1])

xlabel('Time (s)');
ylabel('Spike Rate (Hz)');
title('Saccade (Motor Period)');

xline(-0.2, 'Label', "-200ms", "LabelVerticalAlignment","top","FontSize",6,"LabelHorizontalAlignment","left")
xline(0.1, 'Label', "+100ms", "LabelVerticalAlignment","top","FontSize",6,"LabelHorizontalAlignment","right")

xlim([-0.6 0.6])

% hold off

yLimits = ylim();
maxYLim = yLimits(1,2);

end