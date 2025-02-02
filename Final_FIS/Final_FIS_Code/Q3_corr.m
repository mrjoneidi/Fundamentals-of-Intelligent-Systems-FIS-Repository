data = readtable('evaporator.dat', 'Delimiter', '\t');

% Verify and remove any empty columns at the end if they exist
if any(all(ismissing(data),1))  % Check if any column is completely empty
    data(:,end) = [];  % Remove the last column if it's empty
end

% Ensure the number of variable names matches the number of columns in the table
% Adjust the names according to the actual number of columns
numVars = width(data);
varNames = {'Feature_1', 'Feature_2', 'Feature_3', 'Feature_4', 'Feature_5', 'Target'};
if numVars == numel(varNames)
    data.Properties.VariableNames = varNames;
else
    error('Number of variables does not match the number of names provided.');
end

% Extract each feature column for autocorrelation
features = data{:, 1:end-1}; % Excluding the 'Target' column

% Number of lags
numLags = 100;

% Plot autocorrelation results for each feature in separate figures
for i = 1:size(features, 2)
    figure; % Create a new figure for each feature
    [acf, lags] = autocorr(features(:, i), 'NumLags', numLags, 'NumSTD', 0); % Capture autocorrelation values

    % Ensure lags and acf are row vectors for correct concatenation
    lags = lags(:)'; % Convert to row vector if not already
    acf = acf(:)'; % Convert to row vector if not already

    % Prepare mirrored data for visual representation from -lag to +lag
    extendedLags = [-fliplr(lags(2:end)) lags];  % Create symmetric lags around zero
    extendedACF = [fliplr(acf(2:end)) acf];  % Mirror the autocorrelation values

    % Plot the extended autocorrelation
    stem(extendedLags, extendedACF, 'filled');
    title(['Autocorrelation of ', varNames{i}]);
    xlabel('Lags');
    ylabel('Autocorrelation');
end