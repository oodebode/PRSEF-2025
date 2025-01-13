function [] = trialPSTHVersOne(trialData, spikeTimes, quadNum, fourFigure)

%% target onset data, ie. beginning of the test
targetOn = trialData(:,9);

% testing range, home far after target onset are we recording
range = 1;
%% increments of importance
binSize = 0.05;
%% size of histogram bars
edges = -.25:binSize:range;
numBins = length(edges) - 1;

% psth = zeros(height(targetOn), floor(range / binSize));
psth = zeros(height(spikeTimes), numBins);

%% stores the number of spikes per neuron in each trial (in each quadrant)
threeNeuronSpike = cell(length(spikeTimes), 1);
trialStartColumn = 'targ1_On';

figure;

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

    % number of fires per neuron normalized, stored together
    psth(i, :) = counts;
    threeNeuronSpike{i} = neuronPSTH;

    % this is really the RASTER vertially averaged
    meanPSTH = mean(psth, 1);
    
    % from counts to rates
    spikeRates = meanPSTH / binSize;

    % fancy plotting nonsense to cover my confusion..?
    subplot(2,2,1);
    originalAxes = get(fourFigure, 'CurrentAxes');
    copyobj(allchild(originalAxes), gca);

    subplot(2,2,i+1);
    bar(edges(1:end-1) + binSize/2, spikeRates, 'histc');
    xlabel('Time (s)');
    ylabel('Spike Rate (Hz)');
    title(['Neuron ' num2str(i) ' PSTH']);

    xline(0, 'Label', "Target Onset", "LabelVerticalAlignment","top","FontSize",6,"LabelHorizontalAlignment","left")
    xline(0.25, 'Label', "250 ms After Target Onset", "LabelVerticalAlignment","top","FontSize",6,"LabelHorizontalAlignment","left")

    xlim([-0.25 1.05])
    ylim([0 40])
    
    %% this does not work at all which is why i think im wrong
    %hold on
    % 
    % histfit(meanPSTH)
    %[f, xi] = ksdensity(meanPSTH);
    %plot(xi, f, 'r-', 'LineWidth', 1);
    % 
    %hold off

   
    % subplotPSTH = subplot(3, 1, i); 
    % bar(edges(1:end-1) + binSize/2, meanPSTH, 'histc');
    % xlabel('Time (s)');
    % ylabel('Spike Count');
    % title(['Neuron ' num2str(i) ' PSTH']);

    % figure;
    % bar(edges(1:end-1) + binSize/2, meanPSTH, 'histc');
    % xlabel('Time (s)');
    % ylabel('Spikes');
    % title('Peri-Stimulus Time Histogram (PSTH)');
end

sgtitle(['PSTHs for the ' num2str(quadNum) 'th Quadrant'])

end