#include <stdio.h>
#include <stdlib.h>
#include <netdb.h>
#include <netinet/in.h>
#include <string.h>

int main(int argc, char const *argv[]) {

  // Constants
  char buffer[256];
  int clilen;
  int portNumber = 9000;

  // Creating Socket
  int socketAddress = socket(AF_INET, SOCK_STREAM, 0);
  if (socketAddress < 0)
    return 1;


  // Setting all bits in the serverAddress to zero.
  struct sockaddr_in serverAddress, cli_addr;
  bzero((char *) &serverAddress, sizeof(serverAddress));

  serverAddress.sin_family = AF_INET;
  serverAddress.sin_addr.s_addr = INADDR_ANY;
  serverAddress.sin_port = htons(portNumber);

  // Doing the Binding
  int binding = bind(socketAddress, (struct sockaddr *) &serverAddress, sizeof(serverAddress));
  if (binding < 0)
    return 2;

  // Listening
  listen(socketAddress,5);
  clilen = sizeof(cli_addr);

  // Accepting Messages
  int connection = accept(socketAddress, (struct sockaddr *)&cli_addr, &clilen);

  if (connection < 0)
    return 3;

  // Setting everything in the buffer to zero. I was getting problems with long mesages...
  bzero(buffer,256);

  // Reading!
  int status = read(connection,buffer,256);

  if (status < 0)
    return 4;

  printf("Message received! %s\n", buffer);

  return 0;
}
