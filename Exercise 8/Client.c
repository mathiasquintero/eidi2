#include <stdio.h>
#include <stdlib.h>
#include <netdb.h>
#include <netinet/in.h>
#include <string.h>

int main(int argc, char const *argv[]) {

  // Constants
  int portNumber = 9000;

  // Creating Socket
  int socketAddress = socket(AF_INET, SOCK_STREAM, 0);
  if (socketAddress < 0) {
    printf("Error getting Socket\n");
    return 1;
  }



  // Setting all bits in the serverAddress to zero.

  struct sockaddr_in serverAddress;
  struct hostent *server;

  // Getting hostname

  char name[1023];
  bzero((char *) name,1023);
  gethostname(name,1023);

  server = gethostbyname(name);
  bzero((char *) &serverAddress, sizeof(serverAddress));

  serverAddress.sin_family = AF_INET;
  serverAddress.sin_addr.s_addr = INADDR_ANY;
  serverAddress.sin_port = htons(portNumber);


  // Connecting
  int connection = connect(socketAddress, (struct sockaddr *)&serverAddress, sizeof(serverAddress));

  if (connection < 0) {
    printf("Error with connection\n");
    return 3;
  }

  // Sending
  int status = write(socket,"Hello World!",12);

  if (status < 0) {
    printf("Error with sending\n");
    return 4;
  }

  printf("Message sent!");

  return 0;
}
