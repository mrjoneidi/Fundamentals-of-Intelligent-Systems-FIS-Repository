data = readtable('new_dataAirQualityUCI.xlsx'); % Load data

% Extract features and target
targetColumn = 'NO2_GT_';
features = data{:, ~strcmp(data.Properties.VariableNames, targetColumn)};
target = data{:, targetColumn};

% Split data into training (60%), validation (20%), and testing (20%)
n = size(features, 1);
rng('default'); % For reproducibility
indices = randperm(n)';
split1 = floor(0.6 * n);
split2 = floor(0.8 * n);

trainInd = indices(1:split1);
valInd = indices(split1+1:split2);
testInd = indices(split2+1:end);

X_train = features(trainInd, :);
y_train = target(trainInd);

X_val = features(valInd, :);
y_val = target(valInd);

X_test = features(testInd, :);
y_test = target(testInd);

% Generate initial FIS using subtractive clustering
radius = 0.5; % Cluster radius (adjust as needed)
initialFIS = genfis2(X_train, y_train, radius);

% Configure ANFIS training options with 50 epochs
options = anfisOptions;
options.InitialFIS = initialFIS;
options.EpochNumber = 5000; % Changed to 50 epochs
options.ValidationData = [X_val y_val];
options.DisplayANFISInformation = false;
options.DisplayErrorValues = false;
options.DisplayStepSize = false;
options.DisplayFinalResults = false;

% Train ANFIS
[fis, trainError, ~, chkFIS, chkError] = anfis([X_train y_train], options);

% Evaluate on test data
y_pred = evalfis(X_test, chkFIS); % Use the best validation FIS

% Calculate performance metrics
testMSE = mean((y_pred - y_test).^2);
testRMSE = sqrt(testMSE);
testMAE = mean(abs(y_pred - y_test));
R = corrcoef(y_test, y_pred);
R2 = R(1,2)^2;

% Display results
fprintf('Training MSE: %.4f\n', trainError(end));
fprintf('Validation MSE: %.4f\n', chkError(end));
fprintf('Test MSE: %.4f\n', testMSE);
fprintf('Test RMSE: %.4f\n', testRMSE);
fprintf('Test MAE: %.4f\n', testMAE);
fprintf('R-squared: %.4f\n', R2);

% Plot error curves
figure;
plot(trainError, 'b');
hold on;
plot(chkError, 'r');
title('Training vs Validation Error');
xlabel('Epochs');
ylabel('Mean Squared Error');
legend('Training Error', 'Validation Error');

% Plot prediction results
figure;
subplot(2,1,1);
plot([y_test y_pred]);
legend('Actual','Predicted');
title('ANFIS Prediction Results (50 Epochs)');
xlabel('Samples');
ylabel('NO2 Levels');

subplot(2,1,2);
scatter(y_test, y_pred);
hold on;
plot([min(y_test) max(y_test)], [min(y_test) max(y_test)], 'r--');
xlabel('Actual Values');
ylabel('Predicted Values');
title('Actual vs Predicted Values');