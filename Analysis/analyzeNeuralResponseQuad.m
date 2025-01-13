function [] = analyzeNeuralResponseQuad(trialData,spikeTimes,nNeuron)

% plot the saccard task
% figure;
% scatter(trialData.targetX,trialData.targetY);
% xline(0)
% yline(0)

quadrants = table;

% divide trial data into 4 quadrants
quadrants.quad{1} = trialData(trialData.targetX > 0 & trialData.targetY > 0,:);
quadrants.quad{2} = trialData(trialData.targetX < 0 & trialData.targetY > 0,:);
quadrants.quad{3} = trialData(trialData.targetX < 0 & trialData.targetY < 0,:);
quadrants.quad{4} = trialData(trialData.targetX > 0 & trialData.targetY < 0,:);

% subplotOrder = [2, 1, 3, 4];
axisMaximums = table;
subplotLoc = table;

columns = 4;
rows = 2; 
w = 1 / columns;
h = 1 / rows;

idx = 1;

for r = 1:rows
    for c = 1:columns
        % Calculate position for each subplot
        subplotLoc.left(idx) = ((c - 1) * w) + 0.035;
        subplotLoc.bottom(idx) = (1 - r * h) + 0.055; 
        subplotLoc.w(idx) = w - 0.05;
        subplotLoc.h(idx) = h - 0.1;

        idx = idx + 1;
        % Create subplot using axes
        % subplot('Position', [left, bottom, w, h]);
    end

end

locNum = 1;

figure;
for i = 1:height(quadrants)
    % subplot(2, 2, subplotOrder(i))
    
    if i == 1
        locNum = i;
    else
        locNum = locNum + 2;
    end

    [axisMax] = formatNeuralData(quadrants.quad{i}, spikeTimes, i, nNeuron, subplotLoc, locNum);
    axisMaximums.max(i) = axisMax;

end


graphicMax = max(axisMaximums.max);

%% compute locations separately 
% Left Bottom Width Height 

for i = 1:height(subplotLoc)

    subplot("Position",[subplotLoc.left(i), subplotLoc.bottom(i), ...
    subplotLoc.w(i),subplotLoc.h(i)]);
    ylim([0 graphicMax]);

end

% title(['Neuron ' num2str(nNeuron) ' Quadrant Smooth Histograms']);

savefig(sprintf('neuron#%dPSTH', nNeuron));

end
