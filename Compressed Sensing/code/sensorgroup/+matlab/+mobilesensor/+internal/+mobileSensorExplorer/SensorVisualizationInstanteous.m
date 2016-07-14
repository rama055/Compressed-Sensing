
%   Copyright 2013 The MathWorks, Inc.

classdef SensorVisualizationInstanteous < matlab.mobilesensor.internal.mobileSensorExplorer.SensorVisualization
    
    methods
        function obj = SensorVisualizationInstanteous(varargin)
            obj@matlab.mobilesensor.internal.mobileSensorExplorer.SensorVisualization(varargin{:});
        end
    end

    methods (Access=protected)
        function handleUpdate(obj,~,~)        
            data = obj.sg.(obj.sensorName);
            ts = [];
            try
                obj.processDataImpl(data,ts);
            catch e
                % If the axes is deleted, then the object should delete
                % itself automatically.
                if strcmp(e.identifier,'MATLAB:class:InvalidHandle')
                    delete(obj)
                    return
                end
            end
        end
    end
end

