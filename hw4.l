%{
  #include <stdio.h>
  #include "hw4.tab.h"  // to get the token types from Bison
  #define bool int
  #define true 1
  #define false 0
  int line_num = 1;
  bool reading_records = false;
  int name_index = -1;
  int current_index = 0;
  int max_index = 0;

  typedef struct info{
  	char* name;
  	int number;
  }info;

  info* infos = NULL;
  int limit = 100;
  int size = 0;

  void init(){
  	infos = (info*)malloc(100 * sizeof(info));
  }

  /* return true if it is new */
  bool add(char* name){
  	/* stable O(n^2) */
  	for (int i  = 0; i < size; i++){
  		if (strcmp(infos[i].name, name) == 0){
  			infos[i].number ++;
  			return false;
  		}
  	}
  	if (size >= limit){
  		limit *= 2;
  		info* temp = (info*)(malloc(limit * sizeof(info)));
  		for (int i = 0; i < size; i++){
  			temp[i].name = infos[i].name;
  			temp[i].number = infos[i].number;
  		}
  		free(infos);
  		infos = temp;
  	}
  	infos[size].name = name;
		infos[size].number = 1;
		size++;
		return true;
  }
%}
%option noyywrap
%%
,			{ return COMMA; }
\t\n		{ return CRLF; }
\n			{ return LF; }
\t			{ return CR; }
[\x20-\x2b\x2d-\x7e]+ { yylval.sval = strdup(yytext); return TEXTDATA; }	
%%