function [appendType] = classifyType(statsTable)

appendType = strings(height(statsTable), 1);
typeTable = ["sensory", "motor", "memory"];

for i = 1:height(statsTable)

    if(statsTable.hypothesis(i) == 1) 
        appendType(i) = typeTable(1,i);
    else
        appendType(i) = NaN; 
    end

end

end