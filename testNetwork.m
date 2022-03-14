load('gru500Net.mat')
load('GRU_inDATA_1.mat')

% CALCULATE ERROR!
L = length(X_test);
MaRE = zeros(L,6);
MeRE = zeros(L,6);
T = length(X_test{1});

for i = 1:L
    pred = predict(net,X_test{i});
    error = pred-Y_test{i};
    MeRE(i,:) = sqrt(sum(error.^2,2)/T)/25;
    MaRE(i,:) = max(abs(error),[],2)/25;
end

AvMeRE = sum(MeRE,1)/L;
AvMaRE = sum(MaRE,1)/L;