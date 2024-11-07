#include<iostream>
#include "parser.tab.hh"
#include "Node.h"

extern Node* root;
extern FILE* yyin;
extern int yylineno;
extern int lexical_errors;
extern yy::parser::symbol_type yylex();

SymbolTable program;
enum errCodes
{
	SUCCESS         = 0,
	LEXICAL_ERROR   = 1,
	SYNTAX_ERROR    = 2,
	AST_ERROR       = 3,
	SEMANTIC_ERROR  = 4,
	SEGMENTATION_FAULT   = 139 
};

int errCode = errCodes::SUCCESS;


void yy::parser::error(std::string const&err)
{ 
	if(!lexical_errors) {
		std::cout << "Syntax errors found! See the logs below:" << std::endl;
		std::cout << "\t@error at line "<< yylineno << ". Cannot generate a syntax for this input:" << err.c_str() << std::endl; 
		std::cout << "End of syntax errors!" << std::endl;
		errCode = errCodes::SYNTAX_ERROR;
	}
}


int main(int argc, char **argv)
{
//Reads from file if a file name is passed as an argument. Otherwise, reads from stdin.
	if(argc > 1) {
		if(!(yyin = fopen(argv[1], "r"))) {
			perror(argv[1]);
			return 1;
		}
	}
	//
	if(USE_LEX_ONLY) 
		yylex();
	else {
		yy::parser parser;

		bool parseSuccess = !parser.parse();

		if(lexical_errors)
			errCode = errCodes::LEXICAL_ERROR;

		if(parseSuccess && !lexical_errors) {
			printf("\nThe compiler successfuly generated a syntax tree for the given input! \n");

			printf("\nPrint Tree:  \n");
			try {
				//root->print_tree();
				root->generate_tree();
				root->traverseTree(program);
				// program.printTable();
				program.get_root()->generate_st_tree();
				root->run_semantic(root,program);
			} catch(...) {
				errCode = errCodes::AST_ERROR;
			}
		}
	}

	return errCode;
}