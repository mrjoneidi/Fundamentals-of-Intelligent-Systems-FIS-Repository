data = readtable('new_dataAirQualityUCI.xlsx');

% Data Preprocessing
data = rmmissing(data);
features = data{:, ~strcmp(data.Properties.VariableNames, 'NO2_GT_')};
target = data{:, 'NO2_GT_'};

% Normalization with proper scaling records
[features, inputPS] = mapstd(features');
[target, outputPS] = mapstd(target');
features = features';
target = target';

% Calculate data ranges for proper DataScale configuration
inputMins = min(features, [], 1);
inputMaxs = max(features, [], 1);
outputRange = [min(target) max(target)];

% Create proper DataScale matrix (2 x (numInputs+1))
dataScale = [inputMins; inputMaxs];
dataScale = [dataScale, outputRange']; % Add output range

% Improved FIS Generation
opt = genfisOptions('SubtractiveClustering',...
    'ClusterInfluenceRange', 0.35, ...
    'DataScale', dataScale, ...
    'Verbose', true);

initialFIS = genfis(features(trainInd,:), target(trainInd), opt);

% Enhanced ANFIS Configuration
options = anfisOptions;
options.InitialFIS = initialFIS;
options.EpochNumber = 500;
options.ValidationData = [features(valInd,:) target(valInd,:)];
options.OptimizationMethod = 1;
options.InitialStepSize = 0.1;
options.StepSizeDecreaseRate = 0.8;
options.StepSizeIncreaseRate = 1.1;
options.DisplayANFISInformation = true;

% Early Stopping Implementation
bestError = inf;
bestFIS = initialFIS;
patience = 15;
for epoch = 1:options.EpochNumber
    [fis, trainError, ~, chkFIS, chkError] = anfis(...
        [features(trainInd,:) target(trainInd,:)], options);
    
    if chkError(end) < bestError
        bestError = chkError(end);
        bestFIS = chkFIS;
        patienceCounter = 0;
    else
        patienceCounter = patienceCounter + 1;
        if patienceCounter >= patience
            fprintf('Early stopping at epoch %d\n', epoch);
            break;
        end
    end
end

% Post-processing and Evaluation
y_pred_norm = evalfis(features(testInd,:), bestFIS);
y_pred = mapstd('reverse', y_pred_norm', outputPS)';
y_test = mapstd('reverse', target(testInd,:)', outputPS)';

% ... rest of evaluation code remains the same ...