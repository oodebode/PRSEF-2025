function [smoothHist] = trialPSTHVersTwo(trialData, spikeTimes, quadNum)

%% target onset data, ie. beginning of the test
targetOn = trialData(:,9);

% testing range, home far after target onset are we recording
range = 1;
%% increments of importance
binSize = 0.05;
%% size of histogram bars
edges = -.25:binSize:range;
numBins = length(edges) - 1;

%% simple moving average filter
windowSize = 5;
b = (1/windowSize)*ones(1, windowSize);
a = 1;

% psth = zeros(height(targetOn), floor(range / binSize));
psth = zeros(height(spikeTimes), numBins);

%% stores the number of spikes per neuron in each trial (in each quadrant)
threeNeuronSpike = cell(length(spikeTimes), 1);
trialStartColumn = 'targ1_On';


for i = 1:length(spikeTimes)
    cSpikeTime = spikeTimes{i};

    neuronPSTH = cell(height(targetOn), 1);
    %% how many times did a given neuron spike during a trial
    counts = zeros(1, numBins);

    % counts = zeros(1, length(0:binSize:range));

    for j = 1:height(targetOn)
        cTrialStart = targetOn{j,trialStartColumn} - 0.25;
        targetRangeMax = targetOn{j,trialStartColumn} + range;

        cTrialSpike = cSpikeTime(cSpikeTime >= cTrialStart & cSpikeTime < targetRangeMax);
        
        cTrialSpike = cTrialSpike - targetOn{j,trialStartColumn};

        neuronPSTH{j} = cTrialSpike;

        % edges = 0:binSize:range;
        % numBins = length(edges) - 1;
        countsTrial = histcounts(cTrialSpike, edges);

        counts = counts + countsTrial;
    end
    
    % normalize counts because google said to?
    counts = counts / height(targetOn);
    
    smoothedCounts = filter(b, a, counts);
    % number of fires per neuron normalized, stored together
    psth(i, :) = smoothedCounts;
    threeNeuronSpike{i} = neuronPSTH;

    % this is really the RASTER vertially averaged
    meanPSTH = mean(psth, 1);
    
    % from counts to rates
    spikeRates = meanPSTH / binSize;

    % fancy plotting nonsense to cover my confusion..?
    smoothHist = figure;
    
    binCenters = edges(1:end-1) + diff(edges)/2;

    % bar(edges(1:end-1) + binSize/2, spikeRates, 'histc');
    plot(binCenters, spikeRates);

    xlabel('Time (s)');
    ylabel('Spike Rate (Hz)');
    title(['Neuron ' num2str(i) ' Quadrant ' num2str(quadNum) ' PSTH']);

    xline(0, 'Label', "Target Onset", "LabelVerticalAlignment","top","FontSize",6,"LabelHorizontalAlignment","left")
    xline(0.25, 'Label', "250 ms After Target Onset", "LabelVerticalAlignment","top","FontSize",6,"LabelHorizontalAlignment","right")

    xlim([-0.25 1.05])
    ylim([0 50])
end

% sgtitle(['PSTHs for the ' num2str(quadNum) 'th Quadrant'])

end
