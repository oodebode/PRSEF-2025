function formatSubplots(plotMaxResponse, plotMinResponse, spikeTimes, nNeuron, label)
    
    %% rewrite to focus on target offset
    % really should be one PSTH program

    figure()
    subplot(1,3,1)
    [yLim1, SE1, SH1] = trialPSTHVersFour(plotMaxResponse, spikeTimes, nNeuron, label, 'r');
    hold on
 
    [yLim2, SE2, SH2] = trialPSTHVersFour(plotMinResponse, spikeTimes, nNeuron, label, 'b');
    legend([SH1 SH2], {'Receptive Field', 'Non-Receptive Field'}, 'Location','southeast')

    hold off

    subplot(1,3,2)
    [yLim5, SE5, SH5] = targsOffPSTHVersFour(plotMaxResponse, spikeTimes, nNeuron, label, 'r');
    hold on

    [yLim6, SE6, SH6] = targsOffPSTHVersFour(plotMinResponse, spikeTimes, nNeuron, label, 'b');
    legend([SH5 SH6], {'Receptive Field', 'Non-Receptive Field'}, 'Location','southeast')

    hold off

    subplot(1,3,3)
    [yLim3, SE3, SH3] = saccadePSTHVersFour(plotMaxResponse, spikeTimes, nNeuron, label, 'r');
    hold on

    [yLim4, SE4, SH4] = saccadePSTHVersFour(plotMinResponse, spikeTimes, nNeuron, label, 'b');
    legend([SH3 SH4], {'Receptive Field', 'Non-Receptive Field'}, 'Location','southeast')

    hold off

axisLimits = [yLim1, yLim2, yLim3, yLim4, yLim5, yLim6];
yScalar = max(axisLimits);

errorList = [SE1, SE2, SE3, SE4, SE5, SE6];
maxError = max(errorList);

yScalar = yScalar + maxError;

for i = 1:3
    
    subplot(1,3,i)
    ylim([0 yScalar])

end

sgtitle(['Neuron ' num2str(nNeuron) ' ' label ' Receptive & Non-Receptive Field Peri-Stimulus Time Histogram']);
savefig(sprintf(['neuron#%d' label 'RF'], nNeuron));

end