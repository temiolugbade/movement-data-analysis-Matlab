function [numZerocrossings, zerocrossingsInd] = zerocrossings_phaseportrait(angProfile)

%% Preamble

% This function find the zero crossings in the phase portrait of the joint 
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
%
%
% Output -- numZerocrossings [class = 'double'] - the number of
%                zero crossings in 'angProfile', a scalar
%           zerocrossingsInd [class = 'double'] - the indices of the
%                zero crossings in 'angProfile', a vector
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
       
     
        
        %% main body
        
        if(angProfileSize(1)==1)
            angProfileVelocity = [0 diff(angProfile)];
            zerocrossingsInd = ([0 angProfileVelocity].*[angProfileVelocity 0]) < 0;
        else
            angProfileVelocity = [0; diff(angProfile)];
            zerocrossingsInd = ([0; angProfileVelocity].*[angProfileVelocity; 0]) < 0;
        end

        zerocrossingsInd = zerocrossingsInd(2:end);
        numZerocrossings = sum(zerocrossingsInd);

       
end%end of function