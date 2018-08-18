function plot_signals_and_errorSignal(Time1,Y1, Time2,Y2, y1label, y2label, title_, lineWidth)

fontsize = 14;

if (nargin < 5), y1label='$y$'; end
if (nargin < 6), y2label='$y2$'; end
if (nargin < 7), lineWidth=1.1; end

D = size(Y1,1);

y1_data_align = cell(D,1);
y2_data_align = cell(D,1);

if (Time1(end)>Time2(end))
    Time = Time1;
else
    Time = Time2;
end
    
for i=1:D
   [y1_data_align{i}, y2_data_align{i}] = makeSignalsEqualLength(Time1, Y1(i,:), Time2, Y2(i,:), Time); 
end

figure;
for i=1:D
    subplot(D,2,1+(i-1)*2);
    plot(Time,y1_data_align{i}, Time,y2_data_align{i}, 'LineWidth',lineWidth);
    legend({y1label,y2label},'Interpreter','latex','fontsize',fontsize);
    if (i==1), title(title_,'Interpreter','latex','fontsize',fontsize); end
    axis tight;
    subplot(D,2,2+(i-1)*2);
    plot(Time, y1_data_align{i}-y2_data_align{i},'r','LineWidth',lineWidth);
    legend({'error=DMP-demo'},'Interpreter','latex','fontsize',fontsize);
    axis tight;
end

end


function [inArgs, usingDefaults, unmatchedNames] = parseInputArguments(varargin)

    % initialize parser with the names and default values of the input arguments
    inPars = inputParser;
    
    inPars.KeepUnmatched = true;
    inPars.PartialMatching = false;
    inPars.CaseSensitive = false;
    
    inPars.addParameter('title', '', @(x)assert_string(x));
    inPars.addParameter('xlabel', '', @(x)assert_string(x));
    inPars.addParameter('ylabel', '', @(x)assert_string(x));
    
    inPars.addParameter('legend', '', @(x)assert_string(x));
    
    inPars.addParameter('LineWidth', 1.0, @(x)assert_numeric_scalar_positive(x));
    inPars.addParameter('LineColor', [0.45 0.26 0.26], @(x)assert_rgbColor(x));
    inPars.addParameter('LineStyle', '-', @(x)assert_string(x));
    
    inPars.addParameter('Interpreter', 'latex', @(x)assert_string(x));
    inPars.addParameter('fontSize', 12, @(x)assert_numeric_scalar_positive(x));
    
    inPars.addParameter('animated', false, @(x)assert_boolean(x));
    inPars.addParameter('Time', 0.01, @(x)assert_numeric_nonnegative_increasing(x));
    
    % Parse input arguments
    inPars.parse(varargin{:});
    
    unmatchedNames = fieldnames(inPars.Unmatched);
    usingDefaults = inPars.UsingDefaults;
    
    inArgs = inPars.Results;

end
