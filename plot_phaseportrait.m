function plot_phaseportrait(angProfile)

%% Preamble

% This function plots the phase portrait of the joint with angle profile
% 'angProfile'.
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
% Output -- a plot
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
        else
            angProfileVelocity = [0; diff(angProfile)];
        end

        len = max(angProfileSize);

        beginning = floor(0.1*len);
        final = ceil(0.9*len);
        mainFrames = beginning+1:final-1;


        plot(angProfile(1:beginning+1), angProfileVelocity(1:beginning+1), ...
            'Color', 'g', 'LineWidth', 2);
        hold on;
        plot(angProfile(mainFrames), angProfileVelocity(mainFrames), ...
            'Color', 'k', 'LineWidth', 2);
        hold on;
        plot(angProfile(final-1:len), angProfileVelocity(final-1:len), ...
            'Color', 'r', 'LineWidth', 2);
        hold on;

        xlabel('Angle (deg)')
        ylabel('Angular Velocity (deg/sec)')

        title({'Phase Portrait'; ...
            'movement start (first 10%) in {\color{green}green} and movement end (last 10%) in {\color{red}red}'})

