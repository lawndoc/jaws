#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char BITSTR[65];
char SUBSTR[65];

char *genOctet(char *octet) {
  // calling fn char *SUBSTR
  int arr[8];
  int dec = atoi(octet);
  int i = 0;

  while(dec > 0) {  // builds array of binary ints backwards
    arr[i] = dec % 2;
    i++;
    dec = dec / 2;
  } // end while
  while(i<8) {  // fill the rest of the array with 0's
    arr[i] = 0;
    i++;
  }
 
  for (i=7; i>=0; i--) {  // builds array of chars from flipped int array
    if (arr[i] == 1) {
      strcat(SUBSTR, "1");
//      strcat(SUBSTR, "\t");
    } else {
      strcat(SUBSTR, "0");
//      strcat(SUBSTR, " ");
    } // end if
  } // end for
  printf("Octet: %s\n", SUBSTR);
  return SUBSTR;
} // end genOctet

char *genPort(char *port) {
  // calling fn char *SUBSTR
  int arr[16];
  int dec = atoi(port);
  int i = 0;

  while(dec > 0) {  // builds array of binary ints backwards
    arr[i] = dec % 2;
    i++;
    dec = dec / 2;
  } // end while
  while(i<16) {  // fill the rest of the array with 0's
    arr[i] = 0;
    i++;
  }

  for (i=15; i>=0; i--) {  // builds array of chars from flipped int array
    if (arr[i] == 1) {
      strcat(SUBSTR, "1");
//      strcat(SUBSTR, "\t");
    } else {
      strcat(SUBSTR, "0");
//      strcat(SUBSTR, " ");
    } // end if
  } // end for
  printf("Port: %s\n", SUBSTR);
  return SUBSTR;
} // end genPort

char *genNetCon(char *netcon) {
  int i = 0;
  char *octet = (char *) malloc(4);
  char *port = (char *) malloc(6);
  // generate IPv4 bitstring
  do {
    if (netcon[i] == '.' || netcon[i] == ':') {
      strcat(BITSTR, genOctet(octet));
      memset(octet, '\0', sizeof(octet));
      memset(SUBSTR, '\0', sizeof(SUBSTR));
    } else {
      strncat(octet, &netcon[i], 1);
    } // end if
    i++;
  } while (netcon[i-1] != ':'); // end do-while
  // generate port bitstring
  while (netcon[i] != ':') {
    strncat(port, &netcon[i], 1);
    i++;
  } // end while
  strcat(BITSTR, genPort(port));
  memset(SUBSTR, '\0', sizeof(SUBSTR));
  i++;
  // generate ops bitstring
  if (strcmp(netcon+i, "tcp") == 0)
    printf("Adding tcp op\n");
    strcat(BITSTR, "0000000000000001");
  // end parameter
  strcat(BITSTR, "\n");
  free(octet);
  free(port);
  return strdup(BITSTR);  //TODO: fix memory leak
} // end genNetCon

int main() {
  printf("Netcon: %s\n", genNetCon("127.0.0.1:1234:tcp"));
}
