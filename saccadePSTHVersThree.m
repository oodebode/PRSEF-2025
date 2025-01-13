function [maxRate] = saccadePSTHVersThree(trialData, spikeTimes, quadNum, nNeuron)

%% target onset data, ie. beginning of the test
sacTime = trialData(:,13);

% testing range, home far after target onset are we recording
range = 0.3;
%% increments of importance
binSize = 0.05;
%% size of histogram bars
edges = -.6:binSize:range;
numBins = length(edges) - 1;

%% simple moving average filter
windowSize = 5;
b = (1/windowSize)*ones(1, windowSize);
a = 1;

% psth = zeros(height(targetOn), floor(range / binSize));
psth = zeros(height(spikeTimes), numBins);

%% stores the number of spikes per neuron in each trial (in each quadrant)
threeNeuronSpike = cell(length(spikeTimes), 1);
trialStartColumn = 'sacTime';


cSpikeTime = spikeTimes{nNeuron};

neuronPSTH = cell(height(sacTime), 1);
%% how many times did a given neuron spike during a trial
counts = zeros(1, numBins);

% counts = zeros(1, length(0:binSize:range));

for j = 1:height(sacTime)
    cTrialStart = sacTime{j,trialStartColumn} - 0.6;
    targetRangeMax = sacTime{j,trialStartColumn} + range;

    cTrialSpike = cSpikeTime(cSpikeTime >= cTrialStart & cSpikeTime < targetRangeMax);
    
    cTrialSpike = cTrialSpike - sacTime{j,trialStartColumn};

    neuronPSTH{j} = cTrialSpike;

    % edges = 0:binSize:range;
    % numBins = length(edges) - 1;
    countsTrial = histcounts(cTrialSpike, edges);

    counts = counts + countsTrial;
end

% normalize counts because google said to?
counts = counts / height(sacTime);

smoothedCounts = filter(b, a, counts);

% number of fires per neuron normalized, stored together
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


plot(binCenters, spikeRates);
hold on
errorbar(binCenters, spikeRates, SE);

xlabel('Time (s)');
ylabel('Spike Rate (Hz)');
title(['Neuron ' num2str(nNeuron) ' Quadrant ' num2str(quadNum) ' Saccade PSTH']);

xline(0, 'Label', "Saccade Time", "LabelVerticalAlignment","top","FontSize",6,"LabelHorizontalAlignment","left")
xline(0.25, 'Label', "+250 ms", "LabelVerticalAlignment","top","FontSize",6,"LabelHorizontalAlignment","right")

xlim([-0.5 0.3])

% x_limits = xlim;
% x_position = x_limits(1) + 0.30 * (x_limits(2) - x_limits(1));

% text(x_position, max(smoothedCounts) * 0.8, ['Standard Error = ', num2str(SE)], ...
%     'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

hold off

end