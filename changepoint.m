function [changepointTime, changepointAmpDiff] = changepoint(signal, winSize, winGap, changeDirection)

%% Preamble

% This function finds the major change point in a signal 'signal' 
% based on the algorithm of Marple-Horvat and Gilbey (1992) 
% with an optional twist.
%
% The original algorithm uses sliding windows to find the change point 
% in a signal as the point of maximum difference between the windows. 
% My twist is the introduction of an optional gap between the windows;
% I found that this helped avoid local change points 
% (used in Olugbade et al. 2014, 2015).
%
% References
% ----------
% Marple-Horvat and Gilbey (1992) 
% A method for automatic identification of periods of muscular activity from EMG recordings. 
% Journal of Neuroscience Methods 42(3), pp. 163–167.
%
% Olugbade et al. (2014)
% Bi-Modal Detection of Painful Reaching for Chronic Pain Rehabilitation Systems. 
% Proceedings of ICMI 
% Available at: http://dl.acm.org/citation.cfm?id=2663204.2663261.
%
% Olugbade et al. (2015) 
% Pain Level Recognition using Kinematics and Muscle Activity for Physical Rehabilitation in Chronic Pain. 
% Proceedings of ACII 
% Available at: http://www.emo-pain.ac.uk/papers/ACII2015.pdf.
% 
%
% Input -- signal [class = 'double'] 
%          winSize [class = 'double'] - the size of the sliding windows
%          winGap [class = 'double'] - the size of the gap between the
%           sliding windows. Use winGap = 0 if you don't want a gap.
%          changeDirection [class = 'double'] - '-1' for low to high
%           amplitude change, '1' for high to low, and '0' if you don't care about the direction. 
%           The default is '0'.
%
% Output -- changepointTime [class = 'double'] - the frame number of the change point
%           changepointAmpDiff [class = 'double'] - the amount of signal amplitude change
%               that occurs at the change point
%
% Author -- Temitayo Olugbade
% Version -- June 2014

        %% set up
        
        counter = 1;
        changepointTime = 0;
        changepointAmpDiff = 0;
        winSizeFit = 0;
        
        %% checks

        %make sure three arguments are given
        if(~exist('signal', 'var')||~exist('winSize', 'var')||~exist('winGap', 'var')||~exist('changeDirection', 'var'))
            disp('I need three arguments, you''ve given me less.')
            return
        end

        %make sure signal is a vector
        signalSize = size(signal);
        if(min(signalSize)~=1)
            disp('Please supply the signal as a vector.')
            return            
        end
       
        %make sure winSize and winGap are just numbers
        if((sum(size(winSize))~=2)||(sum(size(winGap))~=2))
            disp('Please supply the window parameters as single numbers.')
            return            
        end
        
        %% main body

        trailingWinEnd = (2*winSize)+winGap;

        while trailingWinEnd <= max(signalSize)
            winSizeFit = 1;

            leadingWinMean = mean(signal(counter:trailingWinEnd - winSize - winGap));
            trailingWinMean = mean(signal(trailingWinEnd - winSize:trailingWinEnd));

            %on each slide, calculate the mean amplitude within each window
            winDiffStore(counter, 1:2) = ...
                [leadingWinMean - trailingWinMean, ceil(median(counter:trailingWinEnd))];

            trailingWinEnd = trailingWinEnd + 1;
            counter = counter + 1;
        end

        if(winSizeFit == 0)
            disp('Warning!!! Your window parameters are too large for the signal length.')
            return
        end

        if(changeDirection == 1)
            [changepointAmpDiff, changepointInd] = max(winDiffStore(:, 1));
        elseif(changeDirection == -1)
            [changepointAmpDiff, changepointInd] = max(-(winDiffStore(:, 1)));
        else
            [changepointAmpDiff, changepointInd] = max(abs(winDiffStore(:, 1)));
        end

       changepointTime = winDiffStore(changepointInd, 2);
