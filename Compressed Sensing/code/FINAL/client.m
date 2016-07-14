function client(serverIp, serverPort, fileToSend)
% CLIENT connect to a server and send file
% serverIp - IP of server to connect to
% serverPort - port of server to connect to
% fileToSend - filename (string) to send

	% uses java
    import java.net.ServerSocket
    import java.io.*
    import java.nio.*
    import java.net.Socket;
    import java.io.FileInputStream;

    BUFFER_SIZE = 1000000; % anything suitable for you
    
    % connect to server
    clientSocket = Socket(serverIp, serverPort);
    
    fprintf(1, '\n\nConnected to server\n');

    % create buffer to write data into
    array	= zeros(1,BUFFER_SIZE,'int8');
    buffer	= java.nio.ByteBuffer.wrap(array);

    % open file to send
    fin = FileInputStream(fileToSend);
    bin = java.nio.channels.Channels.newChannel(fin);
    
    % create channel to write to
    cis = clientSocket.getOutputStream();
    myChannel = java.nio.channels.Channels.newChannel(cis);
        
    fprintf(1, 'Starting to Send File\n');

    while bin.read(buffer) > 0 % till there is nothing to read
        % output read data to socket
        buffer.flip();
        myChannel.write(buffer);
        buffer.clear();
    end
        
    % close everything
    cis.close()
    clientSocket.close();
	bin.close();
    fin.close();
            
    fprintf(1, 'File Sent\n');
end