function plotPosVelAccel(Time, Pos, Vel, Accel, varargin)

D = size(Pos,1);

[inArgs, usingDefaults, unmatchedNames] = parseInputArguments(varargin{:});

if (isempty(inArgs.dimTitle))
    inArgs.dimTitle = cell(D);
    for i=1:D
        inArgs.dimTitle{i} = '';
    end
end

figure;
for i=1:D
    subplot(3,D,1+(i-1));
    plot(Time,Pos(i,:), 'Color',inArgs.PosColor, 'LineWidth',inArgs.LineWidth);
    title(inArgs.dimTitle{i}, 'Interpreter',inArgs.Interpreter, 'fontsize',inArgs.FontSize);
    if (i==1), ylabel(inArgs.PosYlabel, 'Interpreter',inArgs.Interpreter, 'fontsize',inArgs.FontSize); end
    axis tight;
    
    subplot(3,D,1+(i-1)+D);
    plot(Time,Vel(i,:), 'Color',inArgs.VelColor, 'LineWidth',inArgs.LineWidth);
    if (i==1), ylabel(inArgs.VelYlabel, 'Interpreter',inArgs.Interpreter, 'fontsize',inArgs.FontSize); end
    axis tight;
    
    subplot(3,D,1+(i-1)+2*D);
    plot(Time,Accel(i,:), 'Color',inArgs.AccelColor, 'LineWidth',inArgs.LineWidth);
    if (i==1), ylabel(inArgs.AccelYlabel, 'Interpreter',inArgs.Interpreter, 'fontsize',inArgs.FontSize); end
    xlabel(inArgs.xlabel, 'Interpreter',inArgs.Interpreter, 'fontsize',inArgs.FontSize);
    axis tight;
end


end


function [inArgs, usingDefaults, unmatchedNames] = parseInputArguments(varargin)
        
    % initialize parser with the names and default values of the input arguments
    inPars = inputParser;
    
    inPars.KeepUnmatched = true;
    inPars.PartialMatching = false;
    inPars.CaseSensitive = false;

    inPars.addParameter('LineWidth', 1.0, @(x)assert_numeric_scalar_positive(x));
    inPars.addParameter('FontSize', 12, @(x)assert_numeric_scalar_positive(x));
    inPars.addParameter('Interpreter', 'latex', @(x)assert_string(x));
    
    inPars.addParameter('xlabel', 'time [$s$]', @(x)assert_string(x));
    
    inPars.addParameter('PosColor', [0.0 0.0 1.0], @(x)assert_color(x));
    inPars.addParameter('PosYlabel', '[$m$]', @(x)assert_string(x));
    
    inPars.addParameter('VelColor', [0.0 1.0 0.0], @(x)assert_color(x));
    inPars.addParameter('VelYlabel', '[$m/s$]', @(x)assert_string(x));
    
    inPars.addParameter('AccelColor', [1.0 0.0 0.0], @(x)assert_color(x));
    inPars.addParameter('AccelYlabel', '[$m/s^2$]', @(x)assert_string(x));
    
    inPars.addParameter('dimTitle', {}, @(x)assert_cell_with_strings(x));
    
    % Parse input arguments
    inPars.parse(varargin{:});
    
    unmatchedNames = fieldnames(inPars.Unmatched);
    usingDefaults = inPars.UsingDefaults;
    
    inArgs = inPars.Results;


end
