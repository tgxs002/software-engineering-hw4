%{
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>

  #ifdef _WIN32
  #include <io.h>
  char * const nulFileName = "NUL";
  #define CROSS_DUP(fd) _dup(fd)
  #define CROSS_DUP2(fd, newfd) _dup2(fd, newfd)
  #else
  #include <unistd.h>
  char * const nulFileName = "/dev/null";
  #define CROSS_DUP(fd) dup(fd)
  #define CROSS_DUP2(fd, newfd) dup2(fd, newfd)
  #endif
  // convert cpp to c
  #define bool int
  #define true 1
  #define false 0

  extern int yylex();
  extern int yyparse();
  extern FILE *yyin;
  extern int line_num;
  extern bool reading_records;
  extern int name_index;
  extern int current_index;
  extern int max_index;
  extern void init();
  bool isError = false;
  bool shouldQuote = false;
  bool quoted = false;

  typedef struct info{
    char* name;
    int number;
  }info;
  extern info* infos;
  extern bool add(char* name);
  extern int size;
 
  void yyerror(const char *s);
%}

%union {
  int ival;
  float fval;
  char *sval;
}

%token COMMA CRLF CR LF
%token <sval> TEXTDATA

%%
file:
  header ENTER c_records;
header:
  /* after reading tags, start reading records. get max index. check name. */
  names{
    reading_records = true;
    max_index = current_index;
    if (name_index == -1){
      return -1;
    }
  } ;
names:
  names name | name;
name:
  field;
c_records:
  record ENTER | c_records record ENTERS | c_records record | record;
record:
  /* after a new line is read, check the max index. */
  fields {
    if (current_index != max_index){
      return 1;
    }
  };
fields:
  field | fields field ;
field:
  textdata | textdata comma;
field:
  comma {
    if (name_index + 1 == current_index){
      /* if a tweeter without name appears. */
      if (shouldQuote)
        return -1;
      char* mal = malloc(6*sizeof(char));
      strcpy(mal, "empty");
      add(mal);
    }
  };
textdata:
  TEXTDATA { 
    int len = strlen($1);
    if (len > 1 && $1[0] == '"' && $1[len - 1] == '"'){
      /* as described in pizza, we need to check whether quote match */
      quoted = true;
      char* temp = malloc((len + 1) * sizeof(char));
      strcpy(temp, $1 + 1);
      temp[strlen(temp) - 1] = '\0';
      free($1);
      $1 = temp;
    }
    else if ($1[0] == '"' || $1[len - 1] == '"'){
      return 1;
    }
    else{
      quoted = false;
    }
    if (!reading_records){
      /* reading the header, and found 'name' tag. */
      if (strcmp($1, "name") == 0)
        if (name_index != -1){
          return 1;
        }
        else{
          name_index = current_index;
          shouldQuote = quoted;
        }
    }
    else if (current_index == name_index){
      /* when meet name tag */
      if (quoted != shouldQuote){
        return 1;
      }
      if (strlen($1) == 0){
        char* mal = malloc(6*sizeof(char));
        strcpy(mal, "empty");
        free($1);
        $1 = mal;
      }
      if (!add($1)){
        free($1);
      }
    }
   };
comma:
  /* increase column index by 1 when met comma */
  COMMA{ current_index ++;};
ENTERS:
  ENTERS ENTER | ENTER ;
ENTER:
  /* when start a new line, column index reset to 0 */
  ENTER_{
    current_index = 0;
    line_num+=1; 
  };
ENTER_:
  CRLF | CR | LF;
%%

int main(int argv, char** argu) {
  if (argv != 2){
    printf("Invalid Input Format\n"); 
    exit(0);
  }
  // Open a file handle to a particular file:
  FILE *myfile = fopen(argu[1], "r");
  // Make sure it is valid:
  if (!myfile) {
    printf("Invalid Input Format\n");
    return -1;
  }
  yyin = myfile;

  // init binary tree for storage
  init();

  // disable any output
  int stdoutBackupFd;
  FILE *nullOut;
  stdoutBackupFd = CROSS_DUP(STDOUT_FILENO);
  fflush(stdout);
  nullOut = fopen(nulFileName, "w");
  CROSS_DUP2(fileno(nullOut), STDOUT_FILENO);

  // Parse through the input:
  int ret = yyparse();

  /* restore output */
  fflush(stdout);
  fclose(nullOut);
  CROSS_DUP2(stdoutBackupFd, STDOUT_FILENO);
  close(stdoutBackupFd);

  if (ret != 0 || isError){
    printf("Invalid Input Format %d\n", line_num);
    exit(0);
  }

  int o = 10;
  if (o > size){
    o = size;
  }
  for (int i = 0; i < o; i++){
    int maxj, max = 0;
    for (int j = 0; j < size; j++){
      if (infos[j].number > max){
        max = infos[j].number;
        maxj = j;
      }
    }
    printf("%s: %d\n", infos[maxj].name, infos[maxj].number);
    infos[maxj].number = 0;
  }
  for (int i = 0; i < size; i++){
    free(infos[i].name);
  }
  free(infos);
}

void yyerror(const char *s) {
  printf("%s\n", s);
  isError = true;
}
