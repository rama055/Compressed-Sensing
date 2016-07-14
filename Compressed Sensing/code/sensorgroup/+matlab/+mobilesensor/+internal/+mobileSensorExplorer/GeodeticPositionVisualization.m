
%   Copyright 2013 The MathWorks, Inc.

classdef GeodeticPositionVisualization < matlab.mobilesensor.internal.mobileSensorExplorer.SensorVisualization
    
    methods
        function obj = GeodeticPositionVisualization(varargin)
            obj@matlab.mobilesensor.internal.mobileSensorExplorer.SensorVisualization('LatitudeLongitude',varargin{:});
        end
    end
    
    methods (Access=protected)
        function processDataImpl(obj, data, ~)   
             if isempty(obj.hLine)
                obj.hLine = plot(obj.a, data(:,1),data(:,2));
                title(obj.a,obj.sensorName)
                xlabel(obj.a,'Latitude');
                ylabel(obj.a,'Longitude');
            else
                for iColumn = 1:size(data,2)
                    set(obj.hLine,'XData',data(:,1),'YData',data(:,2));
                end
            end
        end
    end

    properties(GetAccess = private, SetAccess = private)
        hLine
    end
    
end

