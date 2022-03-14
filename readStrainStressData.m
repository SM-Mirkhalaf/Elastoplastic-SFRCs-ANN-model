% INPUT
% n_files  = Number of files.
% n_train  = Number of files used for training.
% n_valid  = Number of files used for validation.
% loadPath = Path where data is read from.
% savePath = Path where the file is saved. 
% N        = Use every Nth number from sample sequences. [OPTIONAL]

% OUTPUT
% Saves the loaded data in a .mat file.

function readStrainStressData(n_files,n_train,n_valid,loadPath,savePath,N)
    if nargin == 4
        N = 1;
    end
    
    % Number of files used for testing.
    n_test = n_files - n_train - n_valid;

    %READ DATA AND PUT INTO APPROPRIATE CELL ARRAYS

    % Initialize cell arrays.
    X_all = cell(n_files,1);
    Y_all = cell(n_files,1);

    X_train = cell(n_train,1);
    Y_train = cell(n_train,1);
    X_valid = cell(n_valid,1);
    Y_valid = cell(n_valid,1);
    X_test = cell(n_test,1);
    Y_test = cell(n_test,1);

    % Read data.
    for i = 1:n_files
        X = readmatrix(strcat(...
           loadPath,...
           '\strainData_',num2str(i),'.txt'));
        A = readmatrix(strcat(...
           loadPath,...
           '\orientationData_',num2str(i),'.txt'));
        A = repmat(A,length(1:N:length(X)),1);
        X = cat(1,A',X(1:N:end,2:end)');
        Y = readmatrix(strcat(...
           loadPath,...
           '\stressData_',num2str(i),'.txt'));
        Y = Y(1:N:end,2:end)'/10^6; % Normalize data to MPa.
        X_all{i} = X;
        Y_all{i} = Y;
        if mod(i,100) == 0
            disp(strcat('Currently reading file number: ',num2str(i)))
        end
    end

    % Shuffle data.
    permutation = randperm(n_files);
    X_all = X_all(permutation);
    Y_all = Y_all(permutation);

    % Put in correct arrays.
    X_train(:) = X_all(1:n_train);
    Y_train(:) = Y_all(1:n_train);
    X_valid(:) = X_all((n_train+1):(n_train+n_valid));
    Y_valid(:) = Y_all((n_train+1):(n_train+n_valid));
    X_test(:) = X_all((n_train+n_valid+1):(n_train+n_valid+n_test));
    Y_test(:) = Y_all((n_train+n_valid+1):(n_train+n_valid+n_test));
    
    save(savePath,'X_train','Y_train','X_valid', ...
        'Y_valid','X_test','Y_test', '-v7.3');
end