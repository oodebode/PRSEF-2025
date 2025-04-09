function [pieChart, signPieChart] = realignMatPieChart(tTest)

% tTest is a table that contains the hypothesis values for each neuron in
% each epoc (sensory, memory, motor) as either rejecting (1) and failing to
% reject (0) at alpha = 0.05

rowsNaN = any(isnan(tTest), 2);
typeData = tTest(~rowsNaN, :);

sensory = 0; % just sensory
memory = 0; % just memory
motor = 0; % just motor
sensMot = 0; % sensory-motor
sensMem = 0; % sensory-memory
memMot = 0; % memory-motor
none = 0; % none 
all = 0; % sensory-memory-motor

for i = 1:height(typeData)

    if typeData(i, 1) == 1
        if typeData(i, 2) == 1 && typeData(i, 3) == 1
            all = all + 1;
        elseif typeData(i, 2) == 1
            sensMem = sensMem + 1;
        elseif typeData(1, 3) == 1
            sensMot = sensMot + 1;
        else
            sensory = sensory + 1;
        end
    end

    if typeData(i, 1) == 0
        if typeData(i, 2) == 1 && typeData(i, 3) == 1
            memMot = memMot + 1;
        elseif typeData(i, 2) == 1
            memory = memory + 1;
        elseif typeData(1, 3) == 1
            motor = motor + 1;
        else
            none = none + 1;
        end
    end

end

functionalDistribution = [sensory, memory, motor, sensMot, sensMem, memMot, none, all];
labels = {'Sensory','Memory','Motor','Sensory-Motor', 'Sensory-Memory', 'Memory-Motor', 'None', 'All'};

explode = [0 0 0 0 0 0 1 0];

figure()
pieChart = pie(functionalDistribution, explode);

legend(labels,"Location","bestoutside","Orientation","horizontal")
title("Regional Function Distribution")

figure()
significantDistribution = [sensory, memory, motor, sensMot, sensMem, memMot, all];
signLabels = {'Sensory','Memory','Motor','Sensory-Motor', 'Sensory-Memory', 'Memory-Motor', 'All'};
signPieChart = pie(significantDistribution);

legend(signLabels,"Location","bestoutside","Orientation","horizontal")

title("Significant Regional Function Distribution")

end
