#include "dhun.h"

void print_usage(int exit_code) {
  printf("Usage: dhun <query>\n");
  exit(exit_code);
}


int main(int argc, char *argv[])
{
  if (argc < 2) print_usage(1);

  const char* query = argv[1];

  // Songs will be held in queryResults
  getFilesForQuery(query);

  //printf("No. of Songs : %d\n", queryResults->size);

  if (queryResults && queryResults->size > 0) {
    for(int idx=0; idx<queryResults->size; idx++){
      printf("Now Playing %s\n",queryResults->files[idx]);
      playFile(queryResults->files[idx]);
    }
  }
  return 0;
}
