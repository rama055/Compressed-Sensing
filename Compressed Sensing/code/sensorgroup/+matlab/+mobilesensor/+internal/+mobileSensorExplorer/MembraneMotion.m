
%   Copyright 2013 The MathWorks, Inc.

classdef MembraneMotion < matlab.mobilesensor.internal.mobileSensorExplorer.SensorVisualizationInstanteous
    
    
    methods
        function obj = MembraneMotion(varargin)
            obj@matlab.mobilesensor.internal.mobileSensorExplorer.SensorVisualizationInstanteous('MagneticField',varargin{:});
        end
    end
    
    methods (Access=protected)
        function processDataImpl(obj, data, ~)   
            % You can literally do this -- feed the magnetometer right to
            % view, but it isn't as nice as it could be
            % view(obj.a,data);
            
            if all(data == 0)
                % It seems like the first few data points can be zero,
                % which leads to invalid calculations.
                return;
            end
            
            inclination = acos(data(3) / sqrt(sum(data.^2))) * 180 / pi;
            azimuth = atan(data(2) / data(1)) * 180 / pi;

            if isempty(obj.InitialInclination)
                L = membrane();
                x = linspace(-1,1,size(L,1));
                surf(obj.a,x,x',L);
                obj.InitialInclination = inclination;
                obj.InitialAzimuth = azimuth;
                [obj.InitialViewAzimuth, obj.InitialViewInclination] = view(obj.a);
            end
            
            viewAzimuth = obj.InitialViewAzimuth + (azimuth - obj.InitialAzimuth);
            viewInclination = obj.InitialViewInclination - (inclination - obj.InitialInclination);
            view(obj.a,viewAzimuth,viewInclination)
        end
    end

    properties(GetAccess = private, SetAccess = private)
        InitialInclination
        InitialAzimuth
        InitialViewAzimuth
        InitialViewInclination
    end
    
end

