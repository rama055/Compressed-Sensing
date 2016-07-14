function clientIp = server(serverPort, fileName)
% SERVER Receive a message over the specified port and write to file
% serverPort - port to bind socket to
% fileName - file to write data to (string)
% clientIp - IP address of client that connects

    BUFFER_SIZE = 1000000; % anything suitable for you

	% uses java
    import java.net.ServerSocket
    import java.io.*
    import java.nio.*
    
    % create server socket
    serverSocket = ServerSocket(serverPort);
    
    fprintf(1, ['Server up on port %d\n'], serverPort);

    % accept incoming connection 
    clientSocket = serverSocket.accept();
    clientIp = clientSocket.getInetAddress().toString().substring(1);

    fprintf(1, 'Client Connected, IP = %s\n', char(clientIp));

    % create buffer to put read data into
    array	= zeros(1,BUFFER_SIZE,'int8');
    buffer	= java.nio.ByteBuffer.wrap(array);

    % create channel to read from
    cis = clientSocket.getInputStream();
    myChannel = java.nio.channels.Channels.newChannel(cis);

    % create output file to put received image in
    fout = FileOutputStream(fileName);
    bof = java.nio.channels.Channels.newChannel(fout);
        
    fprintf(1, 'Starting to Write File\n');

    while myChannel.read(buffer) > 0 % till there is nothing to read
        % output read data to file
        buffer.flip();
        bof.write(buffer);
        buffer.clear();
    end
        
    % close everything
    cis.close();
    fout.flush();
	bof.close();
    fout.close();
        
    clientSocket.close;
    serverSocket.close;
        
    fprintf(1, 'File Written\n');
end