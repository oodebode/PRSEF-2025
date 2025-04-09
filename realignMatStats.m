function [h, p] = realignMatStats(backAvgRate, rfIndicies, rfRates)

rfBackRate = zeros(height(rfIndicies), 1);
importantRates = zeros(height(rfIndicies), 1);


for i = 1:height(rfIndicies)

    rfBackRate(i, 1) = backAvgRate(rfIndicies(i, 1), 1); 
    importantRates(i, 1) = rfRates(rfIndicies(i, 1), 1);
end

compareTable = [rfBackRate, importantRates];

[h, p] = ttest(compareTable(:, 1), compareTable(:, 2));



end 