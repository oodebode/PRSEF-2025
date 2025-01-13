function saccardPSTHVersOne(trialData, spikeTimes, quadNum, fourFigure)

%% target onset data, ie. beginning of the test
sacTime = trialData(:,13);

% testing range, home far after target onset are we recording
range = 0.3;
%% increments of importance
binSize = 0.05;
%% size of histogram bars
edges = -.5:binSize:range;
numBins = length(edges) - 1;

% psth = zeros(height(targetOn), floor(range / binSize));
psth = zeros(height(spikeTimes), numBins);

%% stores the number of spikes per neuron in each trial (in each quadrant)
threeNeuronSpike = cell(length(spikeTimes), 1);
trialStartColumn = 'sacTime';

figure;

for i = 1:length(spikeTimes)
    cSpikeTime = spikeTimes{i};

    neuronPSTH = cell(height(sacTime), 1);
    %% how many times did a given neuron spike during a trial
    counts = zeros(1, numBins);

    % counts = zeros(1, length(0:binSize:range));

    for j = 1:height(sacTime)
        cTrialStart = sacTime{j,trialStartColumn} - 0.5;
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

    % number of fires per neuron normalized, stored together
    psth(i, :) = counts;
    threeNeuronSpike{i} = neuronPSTH;

    % this is really the RASTER vertially averaged
    meanPSTH = mean(psth, 1);
    
    % from counts to rates
    spikeRates = meanPSTH / binSize;

    % fancy plotting nonsense to cover my confusion..?
    %for m = 2:4
    subplot(2,2,1);
    originalAxes = get(fourFigure, 'CurrentAxes');
    copyobj(allchild(originalAxes), gca);

    subplot(2,2,i+1);
    bar(edges(1:end-1) + binSize/2, spikeRates, 'histc');
    xlabel('Time (s)');
    ylabel('Spike Rate (Hz)');
    title(['Neuron ' num2str(i) ' PSTH']);

    xline(0, 'Label', "Saccard Time", "LabelVerticalAlignment","top","FontSize",6,"LabelHorizontalAlignment","left")
    xline(0.25, 'Label', "250 ms After Target Onset", "LabelVerticalAlignment","top","FontSize",6,"LabelHorizontalAlignment","left")

    xlim([-0.55 0.35])
    ylim([0 40])
    
end

sgtitle(['PSTHs for the ' num2str(quadNum) 'th Quadrant'])

end
