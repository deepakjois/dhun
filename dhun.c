#include "dhun.h"

void print_usage(int exit_code) {
  printf("Usage: dhun /path/to/file\n");
  exit(exit_code);
}


int main(int argc, char *argv[])
{
  if (argc < 2) print_usage(1);

  const char* filePath = argv[1];

  playFile(argv[1]);

  return 0;
}
