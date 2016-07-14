classdef (Sealed, CaseInsensitiveProperties=true, TruncatedProperties=true) sensorgroup < handle & dynamicprops
    %     SENSORGROUP Reads sensor data from app running on mobile device
    %     
    %     SUPPORTED APPS
    %     Apple iOS: “Sensor Monitor Pro” by Ko, Young-woo
    %     Android: “SensorUdp” by Takashi, Sasaki
    %     Support for specific apps may change in future versions.
    %     
    %     obj = sensorgroup(deviceType) creates an object, obj, that reads sensor data from a mobile device 
    %     connected to the same network as the PC running MATLAB.
    %
    %     deviceType - the type of mobile device. The value is either 'AppleMobile' or 'AndroidMobile'.
    %
    %     obj = sensorgroup(deviceType, Name, Value) uses additional options specified by one or more Name,Value 
    %     pair arguments.
    %
    %     deviceType - the type of mobile device. The value is either 'AppleMobile' or 'AndroidMobile'.
    %
    %     Specify optional comma-separated pairs of Name, Value arguments. Name is the argument name and 
    %     Value is the corresponding value. Name must appear inside single quotes ('  '). You can specify several 
    %     name and value pair arguments in any order as Name1, Value1, ..., NameN, ValueN.
    %
    %     'IPAddress' - Specify the Ethernet device that receives the data. The value is 'any' or the IPv4 
    %                   address of a specific Ethernet device on the host computer. 
    %                   Use single quotes with the IP address. The default value is 'any'.
    %     'Port'      - Specify the Ethernet port that is receives the data. The value is either 'auto' or a 
    %                   port number, from 0 to 65535. Do not use single quotes with the port number. 
    %                   The default value is 'auto'.
    %     'HideTip'   - Suppresses help message that describes steps that need to be done on device.
    %                   The value is either ‘true’ or ‘false’. The default value is ‘false’.
    %     
    %     sensorgroup methods:
    %         showLatestValues - display a list of measurement names and the most recent value for each one
    %         accellog - returns logged acceleration data
    %         angvellog - returns logged angular velocity data
    %         magfieldlog - returns logged magnetic field data
    %         orientlog - returns logged orientation data
    %         poslog - returns logged position data
    %         delete - deletes sensorgroup
    %         discardlogs - discard all logged data
    %
    %     sensorgroup properties:
    %         IPAddress - IPv4 IP Address of the Ethernet interface on the
    %                     host computer
    %         Port - The Ethernet port number on the host computer
    %         InitialTimestamp - Timestamp when the first packet arrived
    %         Acceleration - Latest Acceleration reading: X, Y, Z in m/s^2
    %         AngularVelocity - Latest AngularVelocity reading: X, Y, Z in radians per second
    %         MagneticField - Latest MagneticField reading:  X, Y, Z in tesla
    %         MagneticDeclination - Latest MagneticDeclination reading: Magnetic Heading - True Heading in degrees (iOS only)
    %         Orientation - Latest orientation reading: [1x3] matrix representing Azimuth, Roll and Pitch
    %         Latitude - Latest Latitude in degree
    %         Longitude - Latest Longitude in degree
    %         HorizontalAccuracy - Latest Horizontal Accuracy in meters
    %         Altitude - Altitude in meters
    %         AltitudeAccuracy - Altitude Accuracy in meters up or down (iOS only)
    %         Speed - Latest Speed reading in meters per second m/s
    %         Course - Latest Course reading in degrees relative to true north (iOS only)    
    %
    %     EXAMPLES
    %     Before you start using it, please connect your device to the same network as 
    %     the host computer where you are running MATLAB. You may use Wi-Fi or 
    %     cellular network and depending on your network setup in some cases you 
    %     may need to use a VPN. Please note, that due to the nature of communication 
    %     protocol (UDP) that is used by the mobile app, the app won’t complain if data 
    %     packets cannot reach the host machine.  
    %
    %     Set up and read data from an Apple device
    %     1. Open App Store and search iPhone Apps for “Sensor Monitor” by Ko, Young-woo.
    %     2. Install and open Sensor Monitor.
    %     3. Make an in-app purchase to upgrade to the Pro version.
    %     4. Select the Network tab and change Current Send Mode to Binary.
    %     5. In MATLAB, enter:  obj = sensorgroup('AppleMobile') 
    %        MATLAB displays instructions for configuring Sensor Monitor Pro.
    %     6. In Sensor Monitor Pro, choose which sensors to send data, and how often to send it.
    %     7. Update the host and port values. Then, tap the Start Send button. 
    %        MATLAB displays a message that it is logging data from the mobile device, including a list of 
    %        measurements.  
    %        Leave Sensor Monitor Pro app open and running on foreground. If it goes to the background iOS will 
    %        stop the app after some time and it stops sending data.
    %     8. In MATLAB, display the current data by entering: showLatestValues(s) 
    %        MATLAB displays the measurements, latest values, units, and log size for each measurement. It 
    %        identifies measurements for which it has not received data.
    %     9. When you are done, in Sensor Monitor Pro, tap Stop Send.
    %     
    %     Set up and log data from an Android device
    %     1. Open Google Play and search for “SensorUdp” by Takashi, Sasaki.
    %     2. Install and open SensorUdp.
    %     3. In MATLAB, enter:  obj = sensorgroup('AndroidMobile') 
    %        MATLAB displays instructions for configuring SensorUdp.    
    %     4. In SensorUdp, update the dest. host and port values. 
    %     5. In SensorUdp, use the check boxes for accelerometer cvs line, magnetic field cvs line, and
    %        orientation cvs line to choose which sensors send data. 
    %        Then, tap the send button. MATLAB displays a message that it is logging 
    %        data from the mobile device, including a list of sensors.
    %     6. In MATLAB, display the current data by entering: showLatestValues(s)
    %        MATLAB displays the measurements, latest values, units, and log size for each measurement. It
    %        also identifies measurements for which it has not received data.
    %     7. When you are done, exit from the app by pressing the Android back button. In order to increase
    %        battery life, it’s recommended to open the Android Task Manager and make sure that SensorUdp is
    %        not running.
    %     
    %     ACCESS RECIEVED DATA
    %     Use showLatestValues to display a list of measurement names and the most recent value for 
    %     each one. For example:
    %
    %         showLatestValues(obj)
    %
    %     You can also get the latest value of a specific measurement listed by showLatestValues. For 
    %     example:
    %
    %         obj.Acceleration
    %
    %     You can use sensorgroup methods to access the logged measurement values. 
    %     For example, to get logged acceleration values call:
    %
    %         [a, t] = accellog(obj)
    %     
    %     RECEIVE DATA FROM MULTIPLE DEVICES
    %     Create separate objects for each mobile device. 
    %     Specify the IPv4 address of the Ethernet devices on the host computer. 
    %     If multiple mobile devices send data to the same Ethernet address on the host computer, use 
    %     different port numbers for each mobile device. 
    %
    %     For example, enter:
    %
    %         SamsungGalaxyTab =  sensorgroup('AndroidMobile', 'IPAddress', '192.168.1.1', 'Port', 49152) 
    %         iPhone =  sensorgroup('AppleMobile', 'IPAddress', '192.168.1.1', 'Port', 50000)
    %         iPad =  sensorgroup('AppleMobile', 'IPAddress', '172.28.194.136', 'Port', 50000)
    %     
    %     TROUBLESHOOTING
    %     MATLAB does not receive data from the mobile device
    %     Symptom: MATLAB does not display “logging data from the mobile device” message after you 
    %     tap the send or Start Send button in the app on the mobile device.
    %     Verify or try the following:
    %     - In the app on the mobile device:
    %         Enable the sensors.
    %         Set the IP address and port number provided by MATLAB. 
    %         If MATLAB provides multiple IP addresses, try each one.
    %         Tap the send or Start Send button.
    %     -	The mobile device is connected to the correct Wi-Fi network. Airplane mode is off.
    %     -	The host computer running MATLAB is connected to the network.
    %     -	Routers on the network are configured to pass UDP traffic for the specified port number.
    %
    %    See also: sensorgroup,
    %           <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'CapturingAzimuthRollPitchExample.html'))">Example of Capturing of Azimuth, Roll and Pitch</a>,
    %           <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'CapturingAndMappingGPSExample.html'))">Example of Capturing and Mapping GPS</a>,
    %           <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'StepCounter.html'))">Example of Step Counting with Acceleration Data</a>

    %   Copyright 2013 The MathWorks, Inc.
    
    properties(GetAccess = public, SetAccess = private, Dependent)
        % IPAddress - IPv4 IP Address of the Ethernet interface on the host computer.
        IPAddress
        
        % Port - IP Port that we are currently listening on.
        Port
        
        % InitialTimestamp - Timestamp when the first packet arrived.
        InitialTimestamp
        
        % Acceleration - Latest Acceleration reading: X, Y, Z in m/s^2.
        %
        % Acceleration is defined in relation to the X, Y and Z axes.
        %
        % If you set the phone down face up on a table, the positive X-axis
        % extends out of the right side of the phone, positive Y-axis
        % extends out of the top side, and the positive Z-axis extends out
        % of the front face of the phone. This is independent of the
        % orientation of the phone.
        %
        % For an image of the axes see
        % <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'CapturingAzimuthRollPitchExample.html'))">Example of Capturing of Azimuth, Roll and Pitch</a>
        %
        % See also: accellog
        Acceleration 
        
        % AngularVelocity - Latest AngularVelocity reading: X, Y, Z in radians per second.
        %
        % AngularVelocity is defined in relation to the X, Y and Z axes and
        % in standard right-hand rotational vector notation.
        %
        % If you set the phone down face up on a table, the positive X-axis
        % extends out of the right side of the phone, positive Y-axis
        % extends out of the top side, and the positive Z-axis extends out
        % of the front face of the phone. This is independent of the
        % orientation of the phone.
        %
        % For an image of the axes see
        % <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'CapturingAzimuthRollPitchExample.html'))">Example of Capturing of Azimuth, Roll and Pitch</a>
        %
        % See also: angvellog
        AngularVelocity

        % MagneticField - Latest MagneticField reading:  X, Y, Z in Tesla.
        %
        % MagneticField is defined in relation to the X, Y and Z axes.
        %
        % If you set the phone down face up on a table, the positive X-axis
        % extends out of the right side of the phone, positive Y-axis
        % extends out of the top side, and the positive Z-axis extends out
        % of the front face of the phone. This is independent of the
        % orientation of the phone.
        %
        % For an image of the axes see
        % <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'CapturingAzimuthRollPitchExample.html'))">Example of Capturing of Azimuth, Roll and Pitch</a>
        %
        % See also: magfieldlog
        MagneticField

        % MagneticDeclination - Latest MagneticDeclination reading: Magnetic Heading - True Heading in degrees. (iOS only)
        MagneticDeclination 
        
        % Orientation - Latest orientation reading: [1x3] matrix representing Azimuth, Roll and Pitch.
        %
        % Orientation is defined in relation to the X, Y and Z axes.
        %
        % If you set the phone down face up on a table, the positive X-axis
        % extends out of the right side of the phone, positive Y-axis
        % extends out of the top side, and the positive Z-axis extends out
        % of the front face of the phone. This is independent of the
        % orientation of the phone.
        %
        % Azimuth is angle between the positive Y-axis and magnetic north
        % and its range is between 0 and 360 degrees.
        %
        % Positive Roll is defined when the phone starts by laying flat on
        % a table and the positive Z-axis begins to tilt towards the
        % positive X-axis. (Android only)
        %
        % Positive Pitch is defined when the phone starts by laying flat on
        % a table and the positive Z-axis begins to tilt towards the
        % positive Y-axis. (Android only)
        %
        % For an image of the axes and a full example, see
        % <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'CapturingAzimuthRollPitchExample.html'))">Example of Capturing of Azimuth, Roll and Pitch</a>
        %
        % See also: orientlog
        Orientation
        
        % Latitude - Latest Latitude in degrees.
        %
        % Position data is obtained from GPS, Wi-Fi or cellular network,
        % which ever is most appropriate.
        % <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'CapturingAndMappingGPSExample.html'))">Example of Capturing and Mapping GPS</a>
        %
        % See also: poslog
        Latitude 
 
        % Longitude - Latest Longitude in degrees.
        %
        % Position data is obtained from GPS, Wi-Fi or cellular network,
        % which ever is most appropriate.
        % <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'CapturingAndMappingGPSExample.html'))">Example of Capturing and Mapping GPS</a>
        %
        % See also: poslog
        Longitude                 
        
        % HorizontalAccuracy - Latest Horizontal Accuracy in meters.
        %
        % Position data is obtained from GPS, Wi-Fi or cellular network,
        % which ever is most appropriate.
        % <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'CapturingAndMappingGPSExample.html'))">Example of Capturing and Mapping GPS</a>
        %
        % See also: poslog
        HorizontalAccuracy
        
        % Altitude - Altitude in meters.
        %
        % Position data is obtained from GPS, Wi-Fi or cellular network,
        % which ever is most appropriate.
        % <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'CapturingAndMappingGPSExample.html'))">Example of Capturing and Mapping GPS</a>
        %
        % See also: poslog
        Altitude 
        
        % AltitudeAccuracy - Altitude Accuracy in meters up or down. (iOS only)
        %
        % Position data is obtained from GPS, Wi-Fi or cellular network,
        % which ever is most appropriate.
        % <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'CapturingAndMappingGPSExample.html'))">Example of Capturing and Mapping GPS</a>
        %
        % See also: poslog
        AltitudeAccuracy 
         
        % Speed - Latest Speed reading in meters m/s.
        Speed
        
        % Course - Latest Course reading in degrees relative to true north. (iOS only)
        Course 
    end
    
    properties(Access = private)
        Controller
        ParsedConstructorArgs
        AccelerationLog % Logged Acceleration readings: X, Y, Z m/s^2.
        AngularVelocityLog % Logged AngularVelocity readings: X, Y, Z in in radians per second.
        MagneticFieldLog % Logged MagneticField readings:  X, Y, Z in Tesla.
        OrientationLog % Logged Orientation reading: [1x3] matrix representing Azimuth, Roll and Pitch 
        LatitudeLog % Logged Latitude readings
        LongitudeLog % Logged Longitude readings
        HorizontalAccuracyLog % Logged Horizontal Accuracy readings
        AltitudeLog % Logged Altitude readings.
        AltitudeAccuracyLog % Logged AltitudeAccuracy readings.
        SpeedLog % Logged Speed readings.
        CourseLog % Logged Course readings. (iOS only)
    end
    
    properties(Access = private)
        ShowMessages
        HasSaveWarningBeenIssued = false;
    end
    
    properties(Dependent = true, Access = private)
        ListeningAddress
        OpenedPort
    end
    
    properties(Constant, Access = private, Hidden)
        LocationTimeout = 1;
        IPAndPortPrompt = 1;
        SecondsWithoutInitialData = 60;
        LoopSleepTime = 0.1;
    end
    
    methods(Access = public)
        function obj = sensorgroup(deviceType, varargin)
            % sensorgroup - Create a SENSORGROUP object.
            %   obj = SENSORGROUP(DEVICETYPE, 'Property1', 'Value1', 'Property2', 'Value2', ...),
            %   creates obj, a SENSORGROUP object.
            %
            %   See also: sensorgroup
            
            try
                p = inputParser;
                p.addParamValue('HideTip', false);
                varargin = obj.fixParams(varargin, 'HideTip');
                p.addParamValue('Port', 'auto');
                varargin = obj.fixParams(varargin, 'Port');
                p.addParamValue('IPAddress', 'any');
                varargin = obj.fixParams(varargin, 'IPAddress');
                
                p.parse(varargin{:});
                res = p.Results;
                % verify ShowMessages
                if ~islogical(res.HideTip) && ~isa(res.HideTip, 'function_handle')
                    throw(MException('MATLAB:sensorgroup:InvalidShowMessagesValue', 'The HideTip value should be a logical value.'));
                else
                    if islogical(res.HideTip)
                        res.HideTip = logical(res.HideTip);
                        obj.ShowMessages = ~res.HideTip;
                    else
                        obj.ShowMessages = res.HideTip;        
                    end
                end
                               
                % verify Port
                if isnumeric(res.Port)
                    if res.Port < 0 || res.Port > 65535
                        throw(MException('MATLAB:sensorgroup:InvalidPortNumber', 'The Port value must be between 0 and 65535.'));
                    end
                elseif ischar(res.Port)
                    switch lower(res.Port)
                        case {'a', 'au', 'aut', 'auto'}
                            res.Port = 'auto';
                        otherwise
                            throw(MException('MATLAB:sensorgroup:InvalidPortValue', ...
                                'The Port value must be specified as ''auto'' or be numeric between 0 and 65535.'));
                    end
                end
                % verify IPAddress
                if ischar(res.IPAddress)
                    switch lower(res.IPAddress)
                        case {'a', 'an', 'any'}
                            res.IPAddress = 'any';
                        otherwise
                            if isempty(regexp(res.IPAddress, ...
                                    '\<\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\>', 'once'))
                                % not a dotted quad
                                throw(MException('MATLAB:sensorgroup:InvalidIPAddressForm', ...
                                    'The IPAddress value must be specified as ''any'' or be a valid IP address in the form A.B.C.D.'));
                            else
                                % a dotted quad, but possibly not a valid
                                % IP address
                                try
                                    addr = java.net.InetAddress.getByName(res.IPAddress); %#ok<NASGU>
                                catch %#ok<CTCH>
                                    throw(MException('MATLAB:sensorgroup:InvalidIPAddress', ...
                                        'The IPAddress value must be specified as a valid IP address.'));
                                end
                            end
                    end
                else
                    throw(MException('MATLAB:sensorgroup:InvalidIPAddressForm', ...
                                    'The IPAddress value must be specified as ''any'' or be a valid IP address in the form A.B.C.D.'));
                end
                
                obj.Controller = matlab.mobilesensor.internal.MobileSensorController(deviceType, res);
                obj.ParsedConstructorArgs.DeviceType = deviceType;
                obj.ParsedConstructorArgs.Arguments = res;
                try
                    obj.Controller.open();
                catch e
                    if strcmp(e.identifier, 'MATLAB:UDPListener:startUDPServer:unableToOpen') && ...
                            isnumeric(res.Port)
                        if(strcmp(res.IPAddress, 'any'))
                            throw(MException('MATLAB:sensorgroup:CannotOpenPortAnyIP', ...
                                'The UDP port %d cannot be opened for listening. Type %s for more information', res.Port, obj.getHelpString()));
                        else
                            throw(MException('MATLAB:sensorgroup:CannotOpenPortGivenIP', ...
                                'The UDP port %d at address %s cannot be opened for listening. Type %s for more information', res.Port, res.IPAddress, obj.getHelpString()));
                        end
                    else
                        rethrow(e);
                    end
                end
                sleepTime = obj.LoopSleepTime;

                for t = 0:sleepTime:obj.SecondsWithoutInitialData
                    % check if anything has been received
                    if obj.Controller.getPointsAvailable() > 0
                        return;
                    end
                    
                    pause(sleepTime);
                    
                    if (islogical(res.HideTip) && obj.ShowMessages) || isa(res.HideTip, 'function_handle')
                        if t == obj.IPAndPortPrompt;
                            if strcmp(obj.Controller.Platform, 'iOS')
                                str = ['Waiting for data...\n' ...
                                       'To configure your mobile device:\n' ...
                                       '  1.  Open the Sensor Monitor app.\n' ...
                                       '  2.  Select the Network tab.\n' ...
                                       sprintf('  3.  For Host, enter %s\n', obj.getInterfacesString()) ...
                                       sprintf('  4.  For Port, enter %d\n', obj.port()) ...
                                       '  5.  Choose one or more sensors.\n' ...
                                       '  6.  Set Current Send Mode to Binary.\n' ...
                                       '  7.  Tap Start Send.\n' ...
                                       ];
                                if isa(res.HideTip, 'function_handle')
                                    res.HideTip(str);
                                else
                                    fprintf(str);
                                end
                            elseif strcmp(obj.Controller.Platform, 'Android')
                                str = ['Waiting for data...\n' ...
                                       'To configure your mobile device:\n' ...
                                       '  1.  Open the SensorUdp app.\n' ...
                                       sprintf('  2.  For dest. host, enter %s\n', obj.getInterfacesString()) ...
                                       sprintf('  3.  For port, enter %d\n', obj.port()) ...
                                       '  4.  Choose one or more sensors.\n' ...
                                       '  5.  Tap send.\n' ...
                                       ];
                                if isa(res.HideTip, 'function_handle')
                                    res.HideTip(str);
                                else
                                    fprintf(str);
                                end
                            else
                            end
                        end
                        
                    end
                end
                throw(MException('MATLAB:sensorgroup:NoDataReceived', 'No data received. Type %s for help diagnosing the problem.', obj.getHelpString()));
            catch e
                switch e.identifier
                    case 'mobilesensor:MobileSensorChannel:UnknownDeviceType'
                        throw(MException(e.identifier, 'The deviceType should be ''AppleMobile'' or ''AndroidMobile''. Type %s for more information.', obj.getHelpString()));
                    otherwise
                        throwAsCaller(e);
                end
            end
        end
        
        function disp(obj)
            try
                if strcmp(obj.Controller.Platform, 'iOS')
                    fprintf('%s logging data from Apple device on port %d\n\n', ...
                        obj.getSensorgroupString(), obj.port());
                    fprintf('  Measurements: (%s)\n\n', obj.getShowLatestValuesString());
                    fprintf('    Acceleration                        Orientation\n');
                    fprintf('\n');
                    fprintf('    Latitude                            Speed\n');
                    fprintf('    Longitude                           Course\n');
                    fprintf('    Altitude\n');
                    fprintf('                                        MagneticField\n');
                    fprintf('    AngularVelocity                     MagneticDeclination\n');
                    fprintf('    \n\n');
                else % AndroidMobile
                    fprintf('%s logging data from Android device on port %d\n\n', ...
                        obj.getSensorgroupString(), obj.port());
                    fprintf('  Measurements: (%s)\n\n', obj.getShowLatestValuesString());
                    fprintf('    Acceleration                        Orientation\n');
                    fprintf('\n');
                    fprintf('    Latitude                            Speed\n');
                    fprintf('    Longitude\n');
                    fprintf('    Altitude                            MagneticField\n');
                end
                
            catch e
                throwAsCaller(e);
            end
        end
        
        function showLatestValues(obj)
            % showLatestValues - Shows the latest values of the
            % Measurements that have been logged using the sensorgroup
            % object. Those that are available for the given platform of
            % the device (iOS vs. Android) that have not yet had a value
            % logged will be noted at the bottom of the the table in the
            % line that begins with, "Waiting for."
            %
            % MagneticDeclination does not have a corresponding Log
            % property as it does not naturally change over small
            % geographic distances and therefore its Log Size is left blank
            % at all times.
            %
            % When a Measurement has not had a value logged yet, there are
            % several possible reasons. The first reason is that the
            % device simply may not have sent an update to MATLAB yet and
            % this might be due to the update  frequency chosen within the 
            % app itself. The second reason is that you may need to turn on 
            % the measurement within the app. Another possible reason is that 
            % while other measurements may have been successfully transmitted, 
            % it is possible that the packet/s for one or more specific 
            % measurements may have been lost.
            %
            % See also: sensorgroup
            try
                props = obj.baseProperties();
                colOneWidth = max(cellfun(@(x)length(x), props));
                colOneStr = sprintf('\n%s%s', 'Measurement', repmat(' ', 1, colOneWidth - length('Measurement')));
                propValues = cellfun(@(x)obj.(x), props, 'UniformOutput', false);
                maxLengthPropValues = max(cellfun(@(x)length(x), propValues));
                % We want 2 spaces miniumum between columns when in
                % scientific notation such as:
                % MagneticField          1.48e-05,   1.25e-05,  -1.84e-05
                % so we are using 10.2e or 10.2f format specifiers
                colTwoWidth = max(10 * maxLengthPropValues + 2 * (maxLengthPropValues - 1), length('Latest Values'));
                spacesBefore = floor(colTwoWidth / 2 - length('Latest Values') / 2);
                spacesAfter = ceil(colTwoWidth / 2 - length('Latest Values') / 2);
                colTwoStr = sprintf('%s%s%s', repmat(' ', 1, spacesBefore), 'Latest Values', repmat(' ', 1, spacesAfter));
                fprintf('%s  %s   Units   %s\n', colOneStr, colTwoStr, obj.getLogSizeLink());
                fprintf('%s  %s  -------  %s\n', repmat('-', 1, colOneWidth), repmat('-', 1, colTwoWidth), repmat('-', 1, length('Log Size')));
                emptyProps = {};
                for pp = 1:length(props)
                    values = propValues{pp};
                    if isempty(values)
                        emptyProps = {emptyProps{:} props{pp}}; %#ok<CCAT>
                        continue;
                    end
                    measStr = sprintf('%s%s', props{pp}, repmat(' ', 1, colOneWidth - length(props{pp}) + 2));
                    for vv = 1:length(values)
                        if abs(values(vv)) < 0.01
                            if vv ~= length(values)
                                measStr = [measStr sprintf('%10.2e  ', values(vv))]; %#ok<AGROW>
                            else
                                measStr = [measStr sprintf('%10.2e', values(vv))]; %#ok<AGROW>
                            end
                        else
                            if vv ~= length(values)
                                measStr = [measStr sprintf('%10.2f  ', values(vv))]; %#ok<AGROW>
                            else
                                measStr = [measStr sprintf('%10.2f', values(vv))]; %#ok<AGROW>
                            end
                        end
                    end
                    measStr = [measStr sprintf('%s  %s', repmat(' ', 1, colOneWidth + 2 + colTwoWidth - length(measStr)), obj.getUnits(props{pp}))]; %#ok<AGROW>
                    if ~strcmp(props{pp}, 'MagneticDeclination')
                        [measLogM, measLogN] = size(obj.([props{pp} 'Log']));
                        fprintf('%s  <%ix%i>\n', measStr, measLogM, measLogN);
                    else
                        fprintf('%s\n', measStr);
                    end
                end
                if ~isempty(emptyProps)
                    fprintf('\nWaiting for: ');
                    if length(emptyProps) == 1
                        fprintf('%s.  %s.\n\n', emptyProps{end}, obj.getShowLatestValuesMoreInfoString());
                        
                    elseif length(emptyProps) > 1
                        for pp = 1:length(emptyProps) - 1
                            fprintf('%s, ', emptyProps{pp});
                        end
                        fprintf('and %s.  %s.\n\n', emptyProps{end}, obj.getShowLatestValuesMoreInfoString());
                    end
                else
                    fprintf('\n');
                end
                
            catch e
                throwAsCaller(e);
            end
        end

        
        function delete(obj)
            % delete - Stops listening and frees all associated resources
            % delete(obj)
            try
                if isvalid(obj)
                    obj.Controller.delete();
                end
            catch e
                throwAsCaller(e);
            end
        end
        
        function discardlogs(obj)
            % discardlogs - Discards all logged measurements and InitialTimestamp 
            % discardlogs(obj)
            try
                obj.Controller.discardLogs();
            catch e
                throwAsCaller(e);
            end
        end

        function [a, t] = accellog(obj)
            % accellog - Returns logged acceleration data
            % [a, t] = accellog(obj)
            % a is an [m x 3] matrix containing acceleration data points 
            % t is an [m x 1] vector of timestamps
            %
            % See also: <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'StepCounter.html'))">Example of step counting with acceleration data</a>
            [a, t] = obj.Controller.accellog();
        end

       
        function [a, t] = angvellog(obj)
            % angvellog - Returns logged angular velocity data
            % [a, t] = angvellog(obj)
            % a is an [m x 3] matrix containing angular velocity data points
            % t is an [m x 1] vector of timestamps
            [a, t] = obj.Controller.angvellog();
        end
        
        function [m, t] = magfieldlog(obj)
            % magfieldlog - Returns logged magnetic field data
            % [m, t] = magfieldlog(obj)
            % m is an [m x 3] matrix containing magnetic field data points 
            % t is an [m x 1] vector of timestamps
            [m, t] = obj.Controller.magfieldlog();
        end
        
        function [o, t] = orientlog(obj)
            % orientlog - Returns logged orientation data
            % [o, t] = orientlog(obj)
            % o is an [m x 3] matrix containing orientation data points
            % t is an [m x 1] vector of timestamps. Each row in matrix o represents azimuth, roll and pitch. 
            % If some values are unavailable, they are represented as NaN
            %
            % See also: <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'CapturingAzimuthRollPitchExample.html'))">Example of Capturing of Azimuth, Roll and Pitch</a>    
            [o, t] = obj.Controller.orientlog();
        end
        
        function [lat, long, sp, alt, crse, t, llacc, altacc] = poslog(obj)
            % poslog – Returns logged position data
            % [lat, long, sp, alt, crse, t, llacc, altacc] = poslog(obj)
            % lat - [m x 1] vector of latitude values
            % long - [m x 1] vector of longitude values 
            % sp - [m x 1] vector of speed values
            % alt – [m x 1] vector of altitude values
            % crse – [m x 1] vector of course values
            % t – [m x 1] vector of timestamps
            % llacc – [m x 1] vector of horizontal accuracy values
            % altacc – [m x 1] vector of vertical accuracy values
            % Position data is obtained from GPS, Wi-Fi or cellular
            % network, which ever is most appropriate
            %
            % See alos: <a href="matlab:web(fullfile(fileparts(which('sensorgroup')), 'Examples', 'html', 'CapturingAndMappingGPSExample.html'))">Example of Capturing and Mapping GPS</a>
            [lat, long, sp, alt, crse, t, llacc, altacc] = obj.Controller.poslog(); 
        end
    end
    
    methods
        function S = saveobj(obj)
            try
                % Only issue the warning once per object lifetime
                if obj.HasSaveWarningBeenIssued
                    S = [];
                    return
                end
                obj.HasSaveWarningBeenIssued = true;
                
                sWarningBacktrace = warning('off','backtrace');
                oc = onCleanup(@()warning(sWarningBacktrace));
                warning('MATLAB:sensorgroup:SaveNotSupported', ...
                    'sensorgroup objects cannot be saved, for help on saving your data, type %s', ...
                    obj.getHelpString());
                S = [];
            catch e
                throwAsCaller(e);
            end
        end
        
        function value = get.IPAddress(obj)
            value = obj.Controller.ListeningAddress;
        end
        
        function value = get.Port(obj)
            value = obj.Controller.OpenedPort;
        end

        function value = get.InitialTimestamp(obj)
            if isempty(obj.Controller.InitialTimestamp)
                obj.Controller.readData();
            end
            value = datestr(obj.Controller.InitialTimestamp);
        end
        
        function value = get.Acceleration(obj)
            try
                value = obj.Controller.getCurrentValueFor('Acceleration');
                if isempty(value)
                    value = zeros(0, 3);
                end
            catch e
                if strcmp(e.identifier, 'MATLAB:badsubscript')
                    value = zeros(0, 3);
                else
                    throwAsCaller(e);
                end
            end
        end
        
        function value = get.AccelerationLog(obj)
            try
                value = obj.Controller.getLoggedValuesFor('Acceleration');
                if isempty(value)
                    value = zeros(0, 3);
                end
            catch e
                throwAsCaller(e);
            end
        end
        
        function value = get.AngularVelocity(obj)
            try
                value = obj.Controller.getCurrentValueFor('AngularVelocity');
                if isempty(value)
                    value = zeros(0, 3);
                end
            catch e
                if strcmp(e.identifier, 'MATLAB:badsubscript')
                    value = zeros(0, 3);
                else
                    throwAsCaller(e);
                end
            end
        end
        
        function value = get.AngularVelocityLog(obj)
            try
                value = obj.Controller.getLoggedValuesFor('AngularVelocity');
                if isempty(value)
                    value = zeros(0, 3);
                end
            catch e
                throwAsCaller(e);
            end
        end
               
        function value = get.Orientation(obj)
            try
                value = obj.Controller.getCurrentValueFor('Orientation');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                if strcmp(e.identifier, 'MATLAB:badsubscript')
                    value = zeros(0, 1);
                else
                    throwAsCaller(e);
                end
            end
        end
        
        
        function value = get.OrientationLog(obj)
            try
                value = obj.Controller.getLoggedValuesFor('Orientation');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                throwAsCaller(e);
            end
        end
        
        
        function value = get.MagneticField(obj)
            try
                value = obj.Controller.getCurrentValueFor('MagneticField');
                if isempty(value)
                    value = zeros(0, 3);
                end
            catch e
                if strcmp(e.identifier, 'MATLAB:badsubscript')
                    value = zeros(0, 3);
                else
                    throwAsCaller(e);
                end
            end
        end
        
        function value = get.MagneticFieldLog(obj)
            try
                value = obj.Controller.getLoggedValuesFor('MagneticField');
                if isempty(value)
                    value = zeros(0, 3);
                end
            catch e
                throwAsCaller(e);
            end
        end
                        
        function value = get.MagneticDeclination(obj)
            try
                value = obj.Controller.getCurrentValueFor('MagneticHeading') ...
                    - obj.Controller.getCurrentValueFor('TrueHeading');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                if strcmp(e.identifier, 'MATLAB:badsubscript')
                    value = zeros(0, 1);
                else
                    throwAsCaller(e);
                end
            end
        end
               
        function value = get.HorizontalAccuracy(obj)
            try
                value = obj.Controller.getCurrentValueFor('HorizontalAccuracy');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                throwAsCaller(e);
            end
        end
        
        function value = get.HorizontalAccuracyLog(obj)
            try
                value = obj.Controller.getLoggedValuesFor('HorizontalAccuracy');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                throwAsCaller(e);
            end
        end
        
        function value = get.Latitude(obj)
            try
                value = obj.Controller.getCurrentValueFor('Latitude');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                throwAsCaller(e);
            end
        end
        
        function value = get.LatitudeLog(obj)
            try
                value = obj.Controller.getLoggedValuesFor('Latitude');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                throwAsCaller(e);
            end
        end
        
        function value = get.Longitude(obj)
            try
                value = obj.Controller.getCurrentValueFor('Longitude');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                throwAsCaller(e);
            end
        end
        
        function value = get.LongitudeLog(obj)
            try
                value = obj.Controller.getLoggedValuesFor('Longitude');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                throwAsCaller(e);
            end
        end
        
        
        function value = get.Altitude(obj)
            try
                value = obj.Controller.getCurrentValueFor('Altitude');
                if isempty(value)
                    value = zeros(0, 2);
                end
            catch e
                if strcmp(e.identifier, 'MATLAB:badsubscript')
                    value = zeros(0, 2);
                else
                    throwAsCaller(e);
                end
            end
        end
        
        function value = get.AltitudeLog(obj)
            try
                value = obj.Controller.getLoggedValuesFor('Altitude');
                if isempty(value)
                    value = zeros(0, 2);
                end
            catch e
                throwAsCaller(e);
            end
        end
        
        
        function value = get.AltitudeAccuracy(obj)
            try
                value = obj.Controller.getCurrentValueFor('AltitudeAccuracy');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                throwAsCaller(e);
            end
        end
        
        function value = get.AltitudeAccuracyLog(obj)
            try
                value = obj.Controller.getLoggedValuesFor('AltitudeAccuracy');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                throwAsCaller(e);
            end
        end
        
        function value = get.Speed(obj)
            try
                value = obj.Controller.getCurrentValueFor('Speed');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                if strcmp(e.identifier, 'MATLAB:badsubscript')
                    value = zeros(0, 1);
                else
                    throwAsCaller(e);
                end
            end
        end
        
        function value = get.SpeedLog(obj)
            try
                value = obj.Controller.getLoggedValuesFor('Speed');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                throwAsCaller(e);
            end
        end
               
        function value = get.Course(obj)
            try
                value = obj.Controller.getCurrentValueFor('Course');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                if strcmp(e.identifier, 'MATLAB:badsubscript')
                    value = zeros(0, 1);
                else
                    throwAsCaller(e);
                end
            end
        end
        
        function value = get.CourseLog(obj)
            try
                value = obj.Controller.getLoggedValuesFor('Course');
                if isempty(value)
                    value = zeros(0, 1);
                end
            catch e
                throwAsCaller(e);
            end
        end        
    end
    
    methods(Access = private)
        function str = getInterfacesString(obj)
            str = '';
            cellArray = obj.Controller.AvailableInterfaces;
            if length(cellArray) == 1
                str = cellArray{1};
            elseif length(cellArray) > 1
                for ii = 1:length(cellArray) - 1
                    if ii == 1
                        str = cellArray{1};
                    else
                        str = [str ', ' cellArray{ii}]; %#ok<AGROW>
                    end
                end
                str = [str ', or ' cellArray{length(cellArray)}];
            end
        end
        
        function props = baseProperties(obj)
            
            if strcmp(obj.Controller.Platform, 'iOS')
                props = { ...
                    'Acceleration', ...
                    'AngularVelocity', ...
                    'MagneticField', ...                    
                    'MagneticDeclination', ...
                    'Orientation', ...
                    'Latitude', ...
                    'Longitude', ...
                    'Altitude', ...
                    'Speed', ...
                    'Course' ...
                    };
            else % AndroidMobile
                props = { ...
                    'Acceleration', ...
                    'MagneticField', ...
                    'Orientation', ...
                    'Latitude', ...
                    'Longitude', ...
                    'Altitude', ...
                    'Speed' ...
                    };
            end
            %props = sort(props);
        end
        
        function units = getUnits(~, prop)
            switch prop
                case 'Acceleration'
                    units = 'm/s^2  ';
                case 'AngularVelocity'
                    units = 'rad/s  ';
                case 'MagneticField'
                    units = 'Tesla  ';
                case 'Altitude'
                    units = 'm      ';
                case 'Speed'
                    units = 'm/s    ';
                case {'Azimuth', 'MagneticDeclination', 'Orientation', 'Latitude', 'Longitude', 'Course'}
                    units = 'degrees';
            end
        end
        
        function helpString = getHelpString(obj) %#ok<MANU>
            if feature('hotlinks')
                helpString = '<a href="matlab:helpPopup sensorgroup">"help sensorgroup"</a>';
            else
                helpString = '"help sensorgroup"';
            end
        end
        
        function str = getShowLatestValuesString(obj) %#ok<MANU>
            if feature('hotlinks')
                str = '<a href="matlab:helpPopup sensorgroup/showLatestValues">showLatestValues</a>';
            else
                str = 'showLatestValues';
            end
        end
        
        function str = getShowLatestValuesMoreInfoString(obj) %#ok<MANU>
            if feature('hotlinks')
                str = '<a href="matlab:helpPopup sensorgroup/showLatestValues">More information</a>';
            else
                str = 'More information';
            end
        end
        
        function str = getLogSizeLink(obj) %#ok<MANU>
            if feature('hotlinks')
                str = '<a href="matlab:helpPopup sensorgroup">Log Size</a>';
            else
                str = 'Log Size';
            end
        end
        
        function str = getSensorgroupString(obj) %#ok<MANU>
            if feature('hotlinks')
                str = '<a href="matlab:helpPopup sensorgroup">sensorgroup</a>';
            else
                str = 'sensorgroup';
            end
        end
        
        function out = fixParams(obj, in, param)   %#ok<INUSL>
            out = in;
            param = lower(param);
            for pp = 1:2:length(in)
                lowerIn = lower(in{pp});
                if length(strfind(param, lowerIn)) == 1 && ...
                        strfind(param, lowerIn) == 1
                    out{pp} = param;
                    continue;
                elseif length(strfind(param, lowerIn)) >= 2
                    indices = strfind(param, lowerIn);
                    if indices(1) == 1
                        out{pp} = param;
                        continue;
                    end
                end
                
            end
        end
    end
    
    methods (Hidden)
        % Hide methods inherited from base classes
        
        function c = horzcat(varargin)
            if (nargin == 1)
                c = varargin{1};
            else
                throw(MException('MATLAB:sensorgroup:nohconcatenation', 'Horizontal concatenation of sensorgroup objects is not allowed'));
            end
        end
        function c = vertcat(varargin)
            if (nargin == 1)
                c = varargin{1};
            else
                throw(MException('MATLAB:sensorgroup:novconcatenation', 'Vertical concatenation of sensorgroup objects is not allowed'));
            end
        end
        function c = cat(varargin)
            if (nargin > 2)
                throw(MException('MATLAB:sensorgroup:noconcatenation', 'Concatenation of sensorgroup objects is not allowed'));
            else
                c = varargin{2};
            end
        end
        
        function res = addlistener(obj, varargin)
            res = addlistener@hgsetget(obj, varargin{:});
        end
        function res = addprop(obj, varargin)
            res = addprop@dynamicprops(obj, varargin{:});
        end
        function res = eq(obj, varargin)
            res = eq@handle(obj, varargin{:});
        end
        function res = findobj(obj, varargin)
            res = findobj@handle(obj, varargin{:});
        end
        function res = findprop(obj, varargin)
            res = findprop@handle(obj, varargin{:});
        end
        function res = ge(obj, varargin)
            res = ge@handle(obj, varargin{:});
        end
        function res = gt(obj, varargin)
            res = gt@handle(obj, varargin{:});
        end
        function res = le(obj, varargin)
            res = le@handle(obj, varargin{:});
        end
        function res = lt(obj, varargin)
            res = lt@handle(obj, varargin{:});
        end
        function res = ne(obj, varargin)
            res = ne@handle(obj, varargin{:});
        end
        function res = notify(obj, varargin)
            res = notify@handle(obj, varargin{:});
        end
        
        
    end
    
end
