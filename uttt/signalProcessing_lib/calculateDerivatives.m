function outArgs = calculateDerivatives(data, time, derivOrder, varargin)
%% calculateDerivatives
%  Calculates the derivatives of the given matrix 'data'. The data can be multidimensional.
%  Each row of 'data' corresponds to a different dimension.
%  The order of the highest derivative must be specified.
%  The sampling time or the a vector with the timestamps of the data must be provided.
%  Optionally, the data can be smoothed. The default smoothing function is matlab's smooth
%  function. A user specified function can also be used. The parameters of the smoothing 
%  function can be specified. The smoothing is applied on the highest calculated derivative. 
%  Additonally, the lower order derivatives of the signals can be recomputed based on 
%  the filtered derivative with the highest order using Euler numerical integration (so that
%  the lower derivative are consistent with the highest order derivative).
%
%  Required arguments:
%  @param[in] data: D x N matrix with input data, where D is the number of dimensions and N the number of data points.
%  @param[in] time: 1 x N vector of timestamps or scalar value denoting the sampling time.
%  @param[in] derivOrder: The order of the highest derivative to be calculated.
%  @param[out] outArgs: Cell array where the i-th entry is the derivative of order (i-1).
%                       If only the highest order derivative is requested as the sole output
%                       then outArgs is a cell array with the only entry the highest order derivative.
%
%  Variable argument Name-Value pairs:
%  @param[in] useSmoothing: If true enables smoothing (optinal, default = false).
%  @param[in] smoothTimes: The number of times to apply smoothing (optinal, default = 1).
%  @param[in] smoothMethod: method used for smoothing (optional, default = 'moving', see matlab's smooth function for other available methods).
%  @param[in] smoothMethodDegree: The degree of smoothing for the 'sgolay' smoothing method (optinal, default = 1).
%  @param[in] recomputeLowerDerivatives: If true recomputes all derivatives based on the highest order derivative (optinal, default = false).
%  @param[in] returnAllDerivatives: If true, all derivatives (and the zero order) will be returned (optinal, default = true).
%  @param[in] padPoints: Number of points padded at the beginning and end of each dimension (optinal, default = 0).
%  @param[in] smoothSpan: Number of points used for the smoothing window of each dimension (optinal, default = 5).
%  @param[in] saturationLimit: Saturation limit for the values of the calculated derivatives (optinal, default = 1e100).
%  @param[in] customSmoothingFunction: User specified smoothing function (optinal, default = []).
%


[inArgs, usingDefaults, unmatchedNames] = parseInputArguments(varargin{:});

if (~isempty(unmatchedNames))
    str = sprintf('calculateDerivatives: Found unmatched argument names:\n');
    for i=1:length(unmatchedNames)
        str = [str sprintf('%s\n', unmatchedNames{i})];
    end
    warning('%s', str);
end

n_data = size(data,2);
if (length(time) == 1)
   time = (0:(n_data-1))*time;
end

if (inArgs.padPoints)
    data = [repmat(data(:,1),1,inArgs.padPoints) data repmat(data(:,end),1,inArgs.padPoints)];
    dt1 = time(2)-time(1);
    dt2 = time(end)-time(end-1);
    time1 = (0:(inArgs.padPoints-1))*dt1;
    time = time+time1(end)+dt1;
    time2 = (0:(inArgs.padPoints-1))*dt2 + time(end)+dt2;
    time = [time1 time time2];
end
n_data = size(data,2);
D = size(data,1);

outArgs = cell(derivOrder + 1, 1);
outArgs{1} = data;

for d=1:derivOrder
    outArgs{d+1} = [zeros(D,1) diff(outArgs{d}')'./diff(time)];
    outArgs{d+1}(outArgs{d+1}>inArgs.saturationLimit) = inArgs.saturationLimit;
end

if (inArgs.useSmoothing)
    for d=1:(derivOrder+1)
        for i=1:D
            for k=1:inArgs.smoothTimes
                % if (customSmoothingFunction)
                % outArgs{d}(i,:) = movingAverageFilter(outArgs{d}(i,:),smooth_points);
                outArgs{d}(i,:) = smooth(time, outArgs{d}(i,:), inArgs.smoothSpan, inArgs.smoothMethod, inArgs.smoothMethodDegree);
            end
        end
    end
end


if (inArgs.returnAllDerivatives && inArgs.recomputeLowerDerivatives) 
    for d=derivOrder:-1:1
        for j=1:size(outArgs{1},2)-1
            outArgs{d}(:,j+1) = outArgs{d}(:,j) + outArgs{d+1}(:,j)*(time(j+1)-time(j));
        end
    end
end

if (~inArgs.returnAllDerivatives)
    outArgs = outArgs(end);
end

end


function [inArgs, usingDefaults, unmatchedNames] = parseInputArguments(varargin)

    % function for validating input arguments
    is_bool = @(x) assert( islogical(x), 'Value must be boolean.');
    is_numeric_scalar_nonnegative = @(x) assert(isnumeric(x) && isscalar(x) && (x >= 0), 'Value must be non-negative, scalar, and numeric.');
    empty_assert = @(x) assert(true, 'None');
    is_numeric_scalar_positive = @(x) assert(isnumeric(x) && isscalar(x) && (x > 0), 'Value must be positive, scalar, and numeric.');  
    is_string = @(x) assert( ischar(x), 'Value must be a string.');
    
    % initialize parser with the names and default values of the input arguments
    inPars = inputParser;
    
    inPars.KeepUnmatched = true;
    inPars.PartialMatching = false;
    inPars.CaseSensitive = false;
    
    inPars.addParameter('useSmoothing', false, is_bool);
    inPars.addParameter('smoothTimes', 1.0, is_numeric_scalar_nonnegative);
    
    inPars.addParameter('smoothMethod', 'moving', is_string);
    inPars.addParameter('smoothMethodDegree', 1, is_numeric_scalar_positive);
    inPars.addParameter('recomputeLowerDerivatives', false, is_bool);
    inPars.addParameter('returnAllDerivatives', true, is_bool);
    
    inPars.addParameter('padPoints', 0, is_numeric_scalar_nonnegative);
    inPars.addParameter('smoothSpan', 5, is_numeric_scalar_positive);
    inPars.addParameter('saturationLimit', 1e100, is_numeric_scalar_positive);

    inPars.addParameter('customSmoothingFunction', [], empty_assert);
    
    
    % Parse input arguments
    inPars.parse(varargin{:});
    
    unmatchedNames = fieldnames(inPars.Unmatched);
    usingDefaults = inPars.UsingDefaults;
    
    inArgs = inPars.Results;


end
