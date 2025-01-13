function createManyPlots()
figure;

% Parameters for the subplots
cols = 4; % Number of columns
rows = 2; % Number of rows
w = 1 / cols; % Width of each subplot
h = 1 / rows; % Height of each subplot

for r = 1:rows
    for c = 1:cols
        % Calculate position for each subplot
        left = (c - 1) * w;     % Left position
        bottom = 1 - r * h;     % Bottom position (from top to bottom)
        
        % Create subplot using axes
        subplot('Position', [left, bottom, w, h]);
        
        % Optionally, plot something in each subplot
        plot(rand(10, 1)); % Random plot example
    end
end

end
