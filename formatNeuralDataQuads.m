function [axisMax] = formatNeuralDataQuads(trialData, spikeTimes, quadNum, nNeuron, subplotLoc, locNum)

subplot("Position",[subplotLoc.left(locNum), subplotLoc.bottom(locNum), ...
    subplotLoc.w(locNum),subplotLoc.h(locNum)])
[maxRatePSTH] = trialPSTHVersThree(trialData, spikeTimes, quadNum, nNeuron);

subplot("Position",[subplotLoc.left(locNum + 1), subplotLoc.bottom(locNum + 1), ...
    subplotLoc.w(locNum + 1),subplotLoc.h(locNum + 1)])
[maxRateSaccade] = saccadePSTHVersThree(trialData, spikeTimes, quadNum, nNeuron);

% subplot(1,2,1)
if maxRatePSTH > maxRateSaccade
    axisMax = maxRatePSTH;
    ylim([0 maxRatePSTH])
else
    axisMax = maxRateSaccade;
    ylim([0 maxRateSaccade])
end

% subplot(1,2,2)
if maxRatePSTH > maxRateSaccade
    ylim([0 maxRatePSTH])
else
    ylim([0 maxRateSaccade])
end

end