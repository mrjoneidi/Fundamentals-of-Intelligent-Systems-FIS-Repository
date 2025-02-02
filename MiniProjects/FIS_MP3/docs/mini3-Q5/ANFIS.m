close all
clear all 
clc

x = -10:0.5:10;
y = -10:0.5:10;
[X,Y] = meshgrid(x,y);
[row, col] = size(X);

% Handle division by zero
r1 = sin(X)./X;
r1(X == 0) = 1;  % Set the value at X = 0 to 1

r2 = sin(Y)./Y;
r2(Y == 0) = 1;  % Set the value at Y = 0 to 1

Z = r1 .* r2;  % Element-wise multiplication
figure(1); 
surf(Z); 
title('Actual function');

L1 = reshape(X, [row*col, 1]);
L2 = reshape(Y, [row*col, 1]);
L3 = reshape(Z, [row*col, 1]);
data = [L1, L2, L3];

Optg = genfisOptions('GridPartition');
Optg.NumMembershipFunctions = 6;
Optg.InputMembershipFunctionType = 'gaussmf';

fis1 = genfis(data(:,1:2), data(:,3), Optg);

options = anfisOptions('InitialFIS', fis1, 'EpochNumber', 100);

fis2 = anfis(data, options);
anfis_output = evalfis(fis2, data(:,1:2));

O = reshape(anfis_output, [row, col]);
figure(2); 
surf(O); 
title('Estimated function');

err = Z - O;
figure(3); 
surf(err); 
title('Error between actual and approximation');