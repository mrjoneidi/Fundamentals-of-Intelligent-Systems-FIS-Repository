data = readtable('evaporator.dat', 'Delimiter', '\t');

if any(all(ismissing(data), 1))  
    data(:, end) = [];  
end

% Nan Detector
for col = 1:width(data)
    if any(ismissing(data{:, col}))  
        colMean = mean(data{:, col}, 'omitnan');  
        data{ismissing(data{:, col}), col} = colMean;  
    end
end

% col naming
numVars = width(data); 
varNames = {'Feature_1', 'Feature_2', 'Feature_3', 'Feature_4', 'Feature_5', 'Target'};
if numVars == numel(varNames)
    data.Properties.VariableNames = varNames;
else
    error('Number of variables does not match the number of names provided.');
end

% Normalization
for col = 1:width(data)  
    colMin = min(data{:, col});  
    colMax = max(data{:, col});  
    if colMin ~= colMax  
        data{:, col} = (data{:, col} - colMin) / (colMax - colMin); 
    else
        data{:, col} = 0.5;  
    end
end

features = data{:, 1:5};  
target = data{:, end};    

% disp('Features (First 5 Columns):');
% disp(features);
% disp('Target (Last Column):');
% disp(target);



numSamples = size(features, 1);
trainSize = round(0.7 * numSamples);
randIndices = randperm(numSamples);  

% Splitting
trainIndices = randIndices(1:trainSize); % 70% for train
testIndices = randIndices(trainSize+1:end); % 30% for test

X_train = features(trainIndices, :);  % Features
y_train = target(trainIndices, :);    % Target

X_test = features(testIndices, :);   % Features
y_test = target(testIndices, :);     % Target


% disp(['Shape of X_train: ', num2str(size(X_train, 1)), ' samples, ', num2str(size(X_train, 2)), ' features']);
% disp(['Shape of y_train: ', num2str(size(y_train, 1)), ' samples']);



inputs = X_train';    
targets = y_train';   

%%%% RBF Net
%{
% RBF net Config
spread = 1.5;           
goal = 0.001;         
max_neurons = 150;    
increase_rate = 1;    


net = newrb(inputs, targets, goal, spread, max_neurons, increase_rate);

% Preficting
test_inputs = X_test';      
predicted_outputs = net(test_inputs);  

% MSE
predicted_outputs = predicted_outputs'; 
mse_test = mean((y_test - predicted_outputs).^2); 

disp(['Mean Squared Error (MSE) on Test Data: ', num2str(mse_test)]);

figure;
plot(y_test, 'o-', 'DisplayName', 'Actual Outputs');
hold on;
plot(predicted_outputs, 'x-', 'DisplayName', 'Predicted Outputs');
title('Comparison of Actual and Predicted Outputs (RBF)');
xlabel('Sample Index');
ylabel('Output Value');
legend;
grid on;
%}



% ????? ???????? ? ???????? ?? ?? ?????? ???? ????? ANFIS
trainData = [X_train y_train];  % ?????? ?????? (???????? ? ??????)
testData = [X_test y_test];    % ?????? ??? (???????? ? ??????)

% ????? ?????? ???? ????? (FIS) ?? ??????? ?? ???????? ??????
numMFs = 3;                   % ????? ????? ????? (Membership Functions)
mfType = 'gaussmf';           % ??? ???? ????? (Gaussian Membership Function)
fis = genfis1(trainData, numMFs, mfType);  % ????? FIS ?????

% ??????? ????? ANFIS
numEpochs = 150;              % ????? ???????? ???? ?????
anfisOptions = anfisOptions('InitialFIS', fis, 'EpochNumber', numEpochs);
anfisOptions.DisplayErrorValues = 1;   % ????? ???? ?????
anfisOptions.DisplayStepSize = 1;     % ????? ??????? ?? ?? ?????
anfisOptions.ValidationData = testData;  % ???????? ??????????

% ????? ANFIS
trainedFIS = anfis(trainData, anfisOptions);

% ???????? ??? ???????? ???
predicted_outputs = evalfis(X_test, trainedFIS);

% ?????? ???? ??? (Mean Squared Error)
mse_test_anfis = mean((y_test - predicted_outputs).^2);

% ????? ?????
disp(['Mean Squared Error (MSE) on Test Data (ANFIS): ', num2str(mse_test_anfis)]);

% ??? ?????? ??????
figure;
plot(y_test, 'o-', 'DisplayName', 'Actual Outputs');
hold on;
plot(predicted_outputs, 'x-', 'DisplayName', 'Predicted Outputs (ANFIS)');
title('Comparison of Actual and Predicted Outputs (ANFIS)');
xlabel('Sample Index');
ylabel('Output Value');
legend;
grid on;
