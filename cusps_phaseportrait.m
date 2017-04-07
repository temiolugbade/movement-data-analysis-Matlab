function [numCusps, cuspsInd] = cusps_phaseportrait(angProfile, winSize, angDiffThreshold)

%% Preamble

% This function find the cusps in the phase portrait of the joint 
% with angle profile 'angProfile'.
%
% Winstein and Garfinkel (1989) provide useful interpretations of phase portraits.
%
%
% References
% ----------
% Winstein and Garfinkel (1989)
% Qualitative dynamics of disordered human locomotion: a preliminary investigation. 
% Journal of motor behavior 21(4), pp.373–91. 
% Available at: http://www.ncbi.nlm.nih.gov/pubmed/15136252.
%
% Input -- angProfile [class = 'double'] - a vector
%          winSize [class = 'double'] - the size of window to consider for
%           each cusp test, a scalar
%          angDiffThreshold [class = 'double'] - 
%
%
% Output -- numCusps [class = 'double'] - the number of cusps
%                in 'angProfile', a scalar
%           cuspsInd [class = 'double'] - the indices of the cusps
%                in 'angProfile', a vector
%
% Author -- Temitayo Olugbade
% Version -- March 2017

        %% checks

        %make sure three arguments are given
        if(~exist('angProfile', 'var'))
            disp('I need an argument, you''ve given me none.')
            return
        end

        %make sure angProfile is a vector
        angProfileSize = size(angProfile);
        if(min(angProfileSize)~=1)
            disp('Please supply the angle profile as a vector.')
            return            
        end
       
        if(mod(winSize, 2)==0)
            disp('Warning!!! Your window size should be an odd number.');
            winSize = winSize + 1;
        elseif(winSize>21 || winSize>max(angProfileSize))
            disp('Too large window size.');
            return
        end
        
        %% set up

        winRadius = floor(winSize/2);

        if(angProfileSize(1)==1)
            angProfileVelocity = [0 diff(angProfile)];
        else
            angProfileVelocity = [0; diff(angProfile)];
        end
        
       %% main body
        
       for window = winRadius+1:max(angProfileSize)-winRadius
    
        cuspsInd(window) = isCusp(angProfileVelocity(window-winRadius:window+winRadius), ...
            angProfile(window-winRadius:window+winRadius), angDiffThreshold);
       end
 
cuspsInd = cuspsInd>0;
numCusps = sum(cuspsInd);

       
end%end of function

%% helper functions

function cuspDirection = iscusp_basic(query)

    %An helper function that checks if the given signal 'query' is a cusp or not.
   
    %% set up
    
    cuspDirection = 0;

    %% checks
    querySize = size(query);

    if(min(querySize)~=1)
        disp('Error thrown by ''iscusp_basic'': ')
        disp('I need a vector to work with.');
        return
    elseif(max(querySize)~=3)
        disp('Error thrown by ''iscusp_basic'': ')
        disp('I only work in threes.');
        return
    end

    %% main body

    cuspUp = (query(2)>query(1))&&(query(2)>query(3));

    cuspDown = (query(2)<query(1))&&(query(2)<query(3));

    cuspDirection = cuspUp - cuspDown;
 
 
end%end of function

function cuspOrNot = iscusp(signalWinAngVelAxis, signalWinAngleAxis, angDiffThreshold)

    %An helper function that checks if the given signal window
    %with 'signalWinAngVelAxis' values in the anuglar velocity axis
    %and 'signalWinAngleAxis' values in the angle axis is a cusp or not.
    %
    %'angDiffThreshold' is used to threshold the width of the cusp,
    %i.e. a cusp of angle width greater than or equal to 'angDiffThreshold'
    %is not a cusp after all.
    %

    %% checks

    angularVelSize = size(signalWinAngVelAxis);
    angleSize = size(signalWinAngleAxis);

    if((min(angularVelSize)~=1) || (min(angleSize)~=1))
        disp('Error thrown by ''iscusp'': ')
        disp('I need vectors to work with.');
        cuspOrNot = -1;
        return

    end

    if(max(angularVelSize) ~= min(angleSize))
        disp('Error thrown by ''iscusp'': ')
        disp('All angular velocities must have corresponding angles.');
        cuspOrNot = -1;
        return

    end

    %% set up

    %reduce decimal place by 1 to reduce sensitivity to noise
    signalWinAngVelAxis = round(signalWinAngVelAxis*10)/10;

    %find the tip of the potential cusp
    winMidPoint = floor(max(angularVelSize)/2)+1;

 
    %default return value
    cuspOrNot = 0;

    %check if potential cusp should be up-pointing or down-pointing
    if(signalWinAngVelAxis(winMidPoint) < 0)
        expectedCuspDirection = -1;
    elseif(signalWinAngVelAxis(winMidPoint) < 0)
        expectedCuspDirection = 1;
    else
        
        return
    end


    %% main body
    
    %check that middle portion of signal window is linear in time along the angle
    %axis

    if(islinear(signalWinAngleAxis(winMidPoint-1:winMidPoint+1)))
        
        %test if there's a cusp based on immediate neighbours alone
        %the narrower the cusp-ier (although that should depend 
        %on the angular velocity amplitude, but that check is not done
        %in this version)
        %also check if the width of the cusp is narrow or wide
        %wideness is defined by 'angDiffThreshold'

        cuspOrNot = iscusp_basic(signalWinAngVelAxis(winMidPoint-1:winMidPoint+1))==expectedCuspDirection;
        cuspOrNot = cuspOrNot && (range(signalWinAngleAxis(winMidPoint-1:winMidPoint+1))<=angDiffThreshold);

        %test if there's a cusp based on whole window if previous fails 
        %but both sides of the midpoint must linear in time along the
        %angular velocity axis, and whole signal window must also be linear 
        %in time along the angle axis
        %and
        %check if the width of the cusp is narrow or wide
        %the narrower the cusp-ier (although that should depend 
        %on the angular velocity amplitude, but that check is not done
        %in this version)
        %wideness is defined by angDiffThreshold
        
        if(cuspOrNot==0 &&...
            (islinear(signalWinAngVelAxis(1:winMidPoint)) && islinear(signalWinAngVelAxis(winMidPoint:end)))&&...
            islinear(signalWinAngleAxis))

            cuspOrNot = iscusp_basic(signalWinAngVelAxis([1, winMidPoint, end]))==expectedCuspDirection;
            cuspOrNot = cuspOrNot && (range(signalWinAngleAxis)<=angDiffThreshold);
        end
    end

end%end of function


function linearOrNot = islinear(signal)

    %An helper function that checks if the given signal is linear
    %
    %returns 1 if linear, 0 otherwise
    

    diffSignal = diff(signal);

    len = length(diffSignal);

    linearOrNot = max([sum(diffSignal<0), sum(diffSignal==0), sum(diffSignal>0)])==len;

end%end of function
