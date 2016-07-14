function setupmobile
%   SETUPMOBILE Adds directory where sensorgroup functionality resides to MATLAB path.
%
%   SETUPMOBILE Adds directory where sensorgroup functionality resides to
%   MATLAB path. It uses addpath and savepath functions which modify pathdef.m
%
%   If direcory where sensorgroup functionality resides is deleted 
%   in order to prevent warning during MATLAB startup MATLAB path has to be 
%   cleared by running savepath command.
%
%   Copyright 2013 The MathWorks, Inc.

if verLessThan('matlab', '8.1.0')
    error('MATLAB:setupmobile:matlabVersionNotSupported', 'Mobile sensor support requires R2013a or later.');
end


installedDir = fileparts(which('setupmobile'));
mainfilePresent = exist(fullfile(installedDir, 'sensorgroup.m'), 'file') == 2;
if ~mainfilePresent
    error('MATLAB:setupmobile:sensorgroupNotPresent', 'sensorgroup.m is missing');
end

addpath(installedDir);
savePathStatus = savepath;


insFile = fullfile(installedDir, 'Mobile Sensor Explorer.ins');
installFile = fullfile(installedDir, 'Mobile Sensor Explorer.mlappinstall');

if exist(insFile, 'file') >= 0
    movefile(insFile, installFile);
end

try
    if exist(installFile, 'file') ~= 0
        matlab.apputil.install('Mobile Sensor Explorer.mlappinstall');
        
        if  savePathStatus == 0
            delete(fullfile(installedDir, 'Mobile Sensor Explorer.mlappinstall'));
            delete(fullfile(installedDir, char([mfilename, '.m'])));
        else
            warning('setupmobile was trying to add %s to pathdef.m but could not succeed.\nPlease consider adding %s to the path manually.', ...
                installedDir, installedDir);
        end
    end
    % Display our main example as a getting started guide.
    fprintf('    Installation finished.\n');
    fprintf('    To see a demonstration start Mobile Sensor Explorer app or run %s command.\n', ...
        '<a href="matlab:MobileSensorExplorer">MobileSensorExplorer</a>');
    fprintf('    More examples: \n    <a href="Examples/html/CapturingAzimuthRollPitchExample.html">Example of Capturing of Azimuth, Roll and Pitch</a>\n');
    fprintf('    <a href="Examples/html/CapturingAndMappingGPSExample.html">Example of Capturing and Mapping GPS</a>\n');
    fprintf('    <a href="Examples/html/StepCounter.html">Example of Step Counting with Acceleration Data</a>\n');
    
catch e
    if exist(installFile, 'file') ~= 0
        movefile(installFile, insFile);
    end
   
    w = warning('backtrace', 'off');
    warning('MATLAB:setupmobile:installationFailed', 'Installation failed.');
    warning(w);
    rethrow(e);
    
end

end

