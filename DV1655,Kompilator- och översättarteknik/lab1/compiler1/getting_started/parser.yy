%skeleton "lalr1.cc" 
%defines
%define parse.error verbose
%define api.value.type variant
%define api.token.constructor

%code requires{
  #include <string>
  #include "Node.h"
  #define USE_LEX_ONLY false
}
%code{
  #define YY_DECL yy::parser::symbol_type yylex()

  YY_DECL;
  
  Node* root;
  extern int yylineno;
  
}
// definition of set of tokens. All tokens are of type string
%token <std::string> PLUSOP MINUSOP MULTOP DOT LENGTH RP LP TRUE FALSE THIS NEW NOT INT IDENTIFIER CLASS PUBLIC LC RC STATIC VOID MAIN STRTYPE LB RB SEMICOLON INTTYPE BOOL IF ELSE COMMA WHILE SYSTEMOUTPRINTLN ASSIGN AND OR LESSTHAN GREATERTHAN EQUALTO DVISON RETURN
%token END 0 "end of file"

//defition of operator precedence. See https://www.gnu.org/software/bison/manual/bison.html#Precedence-Decl



%left ASSIGN
%left OR
%left AND
%left GREATERTHAN LESSTHAN
%left EQUALTO
%left NEW
%left PLUSOP MINUSOP
%left MULTOP DVISON
%left LB RB LP RP
%right NOT

// definition of the production rules. All production rules are of type Node
// non-terminal
%type <Node *>  Declar new_par Mret MCmethods MCmethod root Goal mainclass Args MethodDs  ID Statements cont expression parameters  else_statement  expressions classD classDs VarD MethodD Type Statement  VarDs

%%
root:       Goal {root = $1;};

Goal: mainclass classDs END {
    $$ = new Node("Goal","",yylineno);
    $$->children.push_back($1);
    $$->children.push_back($2);
};


mainclass: PUBLIC CLASS ID LC MCmethods RC{
    $$ = new Node("Mainclass","",yylineno);
    $$->children.push_back($3);
    $$->children.push_back($5);
};



MCmethods: MCmethod {$$ = new Node("Methods", "", yylineno);
                     $$->children.push_back($1);}

        | MCmethods MCmethod {$$ = $1;
                            $$->children.push_back($2);
};

MCmethod:  PUBLIC STATIC VOID MAIN LP STRTYPE LB RB Args RP LC Statement RC {
        $$ = new Node("Method", "", yylineno);
        $$->children.push_back($9);
        $$->children.push_back($12);
};
Args: ID {$$ = new Node("Args", "", yylineno); 
        $$->children.push_back($1); }
    | Args ID{
        $$=$1;
        $$->children.push_back($2);
};

classDs: classD {$$=new Node("ClassDeclarations", "", yylineno); 
                $$->children.push_back($1);}
        | classDs classD {
        $$ = $1;
        $$->children.push_back($2);
};

classD: CLASS ID LC Declar RC { 
    $$ = new Node("ClassD","",yylineno);
    $$->children.push_back($2);
    $$->children.push_back($4);
};

VarDs: VarD {$$=new Node("VarDeclarations", "", yylineno); 
            $$->children.push_back($1);}
    | VarDs VarD{
    $$ = $1;
    $$->children.push_back($2);
};

Declar: VarDs{$$ = new Node("ClassBody","",yylineno);
              $$->children.push_back($1);}
        | MethodDs{$$ = new Node("ClassBody","",yylineno);
              $$->children.push_back($1);}
        | VarDs MethodDs {$$ = new Node("ClassBody", "", yylineno);
    $$->children.push_back($1);
    $$->children.push_back($2);
};


MethodDs: MethodD {$$ = new Node("MethodDeclarations", "", yylineno); 
                    $$->children.push_back($1);}
    | MethodDs MethodD{
    $$ = $1;
    $$->children.push_back($2);
};

VarD: Type ID SEMICOLON {
    $$ = new Node("VarD", "", yylineno);
    $$->children.push_back($1);
    $$->children.push_back($2);};
    /* | Type ID ASSIGN ID SEMICOLON{
    $$ = new Node("VarD", "", yylineno);
    $$->children.push_back($1);
    $$->children.push_back($2);
    $$->children.push_back($4);}; */

//parameters = ( Type Identifier ( "," Type Identifier )* )? 
//cont = ( VarDeclaration | Statement )* 
MethodD: PUBLIC Type ID LP parameters RP LC cont Mret RC{
    $$ = new Node("MethodD", "", yylineno);
    $$->children.push_back($2);
    $$->children.push_back($3);
    $$->children.push_back($5);
    $$->children.push_back($8);
    $$->children.push_back($9);
};

Mret: RETURN expression SEMICOLON{
        $$ = new Node("Return","",yylineno);
        $$->children.push_back($2);
};

//parametersloop = ("," Type Identifier)*
parameters: %empty {$$ = new Node("empty", "", yylineno);} 
  |new_par {
    $$ = new Node("parameters", "", yylineno);
    $$->children.push_back($1);}

  | parameters COMMA new_par {
    $$ = $1;
    $$->children.push_back($3);
};

new_par: Type ID {$$ = new Node("Parameter","",yylineno);
                    $$->children.push_back($1);
                    $$->children.push_back($2);};

//cont = ( VarDeclaration | Statement )* 
cont: %empty {$$ = new Node("empty", "", yylineno);}
    |VarD {
    $$ = new Node("contV", "", yylineno);
    $$->children.push_back($1);
    }
    |Statement {
    $$ = new Node("contS", "", yylineno);
    $$->children.push_back($1); }
    |cont VarD {
    $$ =$1;
    $$->children.push_back($2);
    }
    |cont Statement {
    $$ =$1;
    $$->children.push_back($2);};



Type: INTTYPE LB RB {
    $$ = new Node("ARRAY", "", yylineno);
    }
    | BOOL {
    $$ = new Node("BOOLEN", "", yylineno);
    }
    | INTTYPE {
    $$ = new Node("INT", "", yylineno);
    }
    | ID {
    $$ = new Node("Identifier", "", yylineno);
    $$->children.push_back($1);
};


// else_statement "(else statement)?"
else_statement: %empty {$$ = new Node("empty", "", yylineno);}
| ELSE Statement{
    $$ = $2;
};

Statements: Statement  
    {$$ = new Node("Statments", "", yylineno);
    $$->children.push_back($1);} 

    | Statements Statement 
    {
    $$=$1;
    $$->children.push_back($2);
};

Statement: LC Statements RC {
              $$ = new Node("Statment", "", yylineno);
              $$->children.push_back($2);}

          | IF LP expression RP Statement else_statement{
              $$ = new Node("IFStatment", "", yylineno);
              $$->children.push_back($3);
              $$->children.push_back($5);
              $$->children.push_back($6);
           }
           | WHILE LP expression RP Statement {
                      $$ = new Node("WhileStatment", "", yylineno);
                      $$->children.push_back($3);
                      $$->children.push_back($5); 
           }
           | SYSTEMOUTPRINTLN LP expression RP SEMICOLON {
                      $$ = new Node("PrintStatment", "", yylineno);
                      $$->children.push_back($3);
           }
           | ID ASSIGN expression SEMICOLON{
                      $$ = new Node("varStatment", "", yylineno);
                      $$->children.push_back($1);
                      $$->children.push_back($3); 
           }
           | ID LB expression RB ASSIGN expression SEMICOLON//maybe something wrong here
           {
                      $$ = new Node("ArrayStatement", "", yylineno);
                      $$->children.push_back($1);
                      $$->children.push_back($3);
                      $$->children.push_back($6);  
           };

// (expression( COMMA expression)*)?
expressions: expression { $$ = new Node("expression", "", yylineno);
                    $$->children.push_back($1);}
            | expressions COMMA expression{$$ = $1;
                          $$->children.push_back($3);};
                          
 
ID: IDENTIFIER {$$ = new Node("ID",$1, yylineno);};

expression:  expression AND expression{$$ = new Node("ANDExpression", "", yylineno);
                            $$->children.push_back($1);
                            $$->children.push_back($3);
                            /* printf("r1 "); */}
           | expression OR expression{$$ = new Node("ORExpression", "", yylineno);
                            $$->children.push_back($1);
                            $$->children.push_back($3);
                            /* printf("r1 "); */}
           | expression LESSTHAN expression{$$ = new Node("LTExpression", "", yylineno);
                            $$->children.push_back($1);
                            $$->children.push_back($3);
                            /* printf("r1 "); */}
           | expression GREATERTHAN expression{$$ = new Node("GTExpression", "", yylineno);
                            $$->children.push_back($1);
                            $$->children.push_back($3);
                            /* printf("r1 "); */}
           | expression EQUALTO expression{$$ = new Node("EQExpression", "", yylineno);
                            $$->children.push_back($1);
                            $$->children.push_back($3);
                            /* printf("r1 "); */}
           | expression PLUSOP expression{
                            $$ = new Node("AddExpression", "", yylineno);
                            $$->children.push_back($1);
                            $$->children.push_back($3);
                            /* printf("r1 "); */}
           | expression MINUSOP expression{
                            $$ = new Node("SubExpression", "", yylineno);
                            $$->children.push_back($1);
                            $$->children.push_back($3);
                            /* printf("r1 "); */}
           | expression MULTOP expression{
                            $$ = new Node("MultExpression", "", yylineno);
                            $$->children.push_back($1);
                            $$->children.push_back($3);
                            }
           | expression DVISON expression{$$ = new Node("DivExpression", "", yylineno);
                            $$->children.push_back($1);
                            $$->children.push_back($3);
                            }
           | expression LB expression RB {$$ = new Node("ArrayExpression", "", yylineno);
                            $$->children.push_back($1);
                            $$->children.push_back($3);

                           }
           | expression DOT LENGTH {
                            $$ = new Node("LengthExpression", "", yylineno);
                            $$->children.push_back($1);
                           }
           | expression DOT ID LP expressions RP{
                            $$ = new Node("Expression", "", yylineno);
                            $$->children.push_back($1);
                            $$->children.push_back($3);
                            $$->children.push_back($5);
                            }  
           | expression DOT ID LP RP{
                            $$ = new Node("Expression", "", yylineno);
                            $$->children.push_back($1);
                            $$->children.push_back($3);
                            }

           | INT            {$$ = new Node("INTExpression", "", yylineno);}

           | TRUE           {$$ = new Node("TRUE", "", yylineno);}

           | FALSE          {$$ = new Node("FALSE", "", yylineno);}

           | ID             {$$ = $1;}

           | THIS           {$$ = new Node("THIS", "", yylineno);}

           | NEW INTTYPE LB expression RB{
                            $$ = new Node("ArrayDic", "", yylineno);
                            $$->children.push_back($4);
           }
           | NEW ID LP RP {
                            $$ = new Node("DeclarationEXP", "", yylineno);
                            $$->children.push_back($2);

           }
           | NOT expression {
                            $$ = new Node("Negation", "", yylineno);
                            $$->children.push_back($2);}

           | LP expression RP {
                            $$ = new Node("Parameter", "", yylineno);
                            $$->children.push_back($2);
                            };