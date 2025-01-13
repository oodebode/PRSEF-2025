function [maxYLim, SE, smoothHist] = targsOffPSTHVersFour(trialData, spikeTimes, nNeuron, label, color)

%% target onset data, ie. beginning of the test
targsOff = trialData(:,11);

% testing range, home far after target onset are we recording
range = 1;

%% increments of importance
binSize = 0.05;

%% size of histogram bars
edges = -.425:binSize:0.825;
numBins = length(edges) - 1;

%% simple moving average filter
windowSize = 5;
b = (1/windowSize)*ones(1, windowSize);
a = 1;

psth = zeros(height(spikeTimes), numBins);

%% stores the number of spikes per neuron in each trial (in each quadrant)
trialStartColumn = 'targsOff';


cSpikeTime = spikeTimes{nNeuron};

neuronPSTH = cell(height(targsOff), 1);

%% how many times did a given neuron spike during a trial
counts = zeros(1, numBins);

for j = 1:height(targsOff)
    cTrialStart = cell2mat(targsOff{j, trialStartColumn}) - 0.6;
    targetRangeMax = cell2mat(targsOff{j,trialStartColumn}) + range;

    cTrialSpike = cSpikeTime(cSpikeTime >= cTrialStart & cSpikeTime < targetRangeMax);
    
    cTrialSpike = cTrialSpike - cell2mat(targsOff{j,trialStartColumn});

    neuronPSTH{j} = cTrialSpike;

    countsTrial = histcounts(cTrialSpike, edges);

    counts = counts + countsTrial;
end

% normalize counts 
counts = counts / height(targsOff);

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

xlabel('Time (s)');
ylabel('Spike Rate (Hz)');
title('Target Offset (Memory Period)');

xline(0.1, 'Label', "+100ms", "LabelVerticalAlignment","top","FontSize",6,"LabelHorizontalAlignment","left")
xline(0.4, 'Label', "+400 ms", "LabelVerticalAlignment","top","FontSize",6,"LabelHorizontalAlignment","right")

xlim([-0.4 0.8])

% hold off

yLimits = ylim();
maxYLim = yLimits(1,2);


end
