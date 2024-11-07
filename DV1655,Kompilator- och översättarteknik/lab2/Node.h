#ifndef NODE_H
#define NODE_H

#include <bits/stdc++.h>
#include <list>
#include <iostream>
#include <fstream>
#include <vector>
#include <unistd.h>
#include <sys/wait.h>
#include <string>
#include <iterator>
using namespace std;
#include <map>
#include <stack>
#include <algorithm>
#include <cctype>
#include "table.hh"

class Node {
public:
    int id, lineno;
    std::vector<Scope*> scopes;
    Scope* scope;
    vector<Scope*>::iterator current;
    string type, value;
    list<Node*> children;

    struct Result {
        vector<Scope*>::iterator current;
        Scope* scope;
    };

    /**
     * Constructor for Node.
     * parameter t The type of the node.
     * parameter v The value associated with the node.
     * parameter l The line number in the source code.
     */
    Node(string t, string v, int l) : type(t), value(v), lineno(l) {}

    /**
     * Default constructor for Node. Sets type and value to "uninitialised".
     * Required by Bison (parser generator).
     */
    Node() {
        type = "uninitialised";
        value = "uninitialised";
    }

    /**
     * Recursively prints the syntax tree starting from this node.
     * parameter depth The current depth in the tree for indentation (default is 0).
     */
    void print_tree(int depth = 0) {
        for (int i = 0; i < depth; i++)
            cout << "  ";
        cout << type << ":" << value << endl;
        for (auto i = children.begin(); i != children.end(); i++)
            (*i)->print_tree(depth + 1);
    }

    /**
     * Traverses the syntax tree to build the symbol table.
     * parameter program The symbol table to populate during traversal.
     * parameter parent Pointer to the parent node (default is nullptr).
     */
    void traverseTree(SymbolTable program, Node* parent = nullptr) {
        // Loop through each child node in the current node's children list
        for (auto i = children.begin(); i != children.end(); i++) {

            // If the current node represents a "Mainclass"
            if ((*i)->type == "Mainclass") {
                Class* new_class;
                new_class = new Class(); // Create a new class instance for "Mainclass"
                string name = (*i)->children.front()->value; // Get the class name
                new_class->setId("class"); // Set class ID as "class"
                new_class->setRecord("class"); // Set record type as "class"
                new_class->setType(name); // Set class type to the name of the main class
                new_class->setVisited(0); // Initialize visited status
                new_class->setline((*i)->children.front()->lineno); // Set line number for class
                program.set_class(new_class); // Register class in the program
                program.put(name, *new_class); // Add the new class to the symbol table
                program.enterScope(); // Enter scope specific to this class
                (*i)->children.back()->traverseTree(program); // Recursively traverse inner class content
                program.exitScope(); // Exit the class scope after traversal
            }

            // If the current node contains "ClassDeclarations"
            if ((*i)->type == "ClassDeclarations") {
                (*i)->traverseTree(program); // Traverse class declarations recursively
            }

            // If the node represents a "Method"
            else if ((*i)->type == "Method") {
                Method* new_method;
                new_method = new Method(); // Create a new method instance
                new_method->setId("method"); // Set method ID as "method"
                new_method->setType("void"); // Initialize type as "void"
                new_method->setRecord("method"); // Set record type as "method"
                new_method->setVisited(0); // Initialize visited status
                new_method->setline((*i)->children.front()->lineno); // Set line number for method
                program.set_method(new_method, program.getParentScope()->get_class()); // Link method to its class scope
                program.put("main", *new_method); // Add the new method to the symbol table
                program.getParentScope()->get_class()->addMethod(new_method); // Register method with the parent class
                program.enterScope(); // Enter method scope for argument addition
                string arg = (*i)->children.front()->children.front()->value; // Get method argument name
                Variable new_arg;
                new_arg.setId("Arg"); // Set argument ID as "Arg"
                new_arg.setType("string[]"); // Set argument type as "string[]"
                new_arg.setRecord("arg"); // Set record type as "arg"
                new_arg.setVisited(0); // Initialize visited status
                new_arg.setline((*i)->children.front()->children.front()->lineno); // Set line number for argument
                program.put(arg, new_arg); // Add argument to symbol table
                program.getParentScope()->get_method()->addParameter(new_arg); // Register parameter with method
                program.exitScope(); // Exit the method scope
            }

            // If the current node represents a "ClassD" (another class declaration)
            else if ((*i)->type == "ClassD") {
                Class* new_class;
                new_class = new Class(); // Create a new class instance for "ClassD"
                string name = (*i)->children.front()->value; // Get class name
                new_class->setId("class"); // Set class ID as "class"
                new_class->setType(name); // Set class type to the name of the class
                new_class->setRecord("class"); // Set record type as "class"
                new_class->setline((*i)->children.front()->lineno); // Set line number for class
                new_class->setVisited(0); // Initialize visited status
                program.set_class(new_class); // Register class in the program
                program.put(name, *new_class); // Add the new class to the symbol table
                program.enterScope(); // Enter scope specific to this class

                (*i)->children.back()->traverseTree(program, (*i)); // Recursively traverse inner class content
                program.exitScope(); // Exit the class scope after traversal
            }

            // If the current node contains "MethodDeclarations"
            else if ((*i)->type == "MethodDeclarations") {
                (*i)->traverseTree(program); // Recursively traverse method declarations
            }

            // If the node represents a specific method declaration, "MethodD"
            else if ((*i)->type == "MethodD") {
                Method* new_method;
                new_method = new Method; // Create a new method instance
                Node* name = *std::next((*i)->children.begin(), 1); // Get method name node
                new_method->setId(name->value); // Set method ID to its name
                if ((*i)->children.front()->type == "Identifier") { // Check if the type is an identifier
                    new_method->setType((*i)->children.front()->children.front()->value); // Set to identifier value if true
                } else {
                    new_method->setType((*i)->children.front()->type); // Otherwise, set to front type
                }
                new_method->setRecord("method"); // Set record type as "method"
                new_method->setline((*i)->children.front()->lineno); // Set line number for method
                new_method->setVisited(0); // Initialize visited status
                program.set_method(new_method, program.getParentScope()->get_class()); // Link method to parent class
                program.put(name->value, *new_method); // Add method to the symbol table
                program.getParentScope()->get_class()->addMethod(new_method); // Register method with class
                program.enterScope(); // Enter method scope for parameter addition
                Node* parameter = *std::next((*i)->children.begin(), 2); // Retrieve parameter node
                parameter->traverseTree(program); // Traverse parameter
                Node* variables = *std::next((*i)->children.begin(), 3); // Retrieve variables node
                variables->traverseTree(program, (*i)); // Traverse method variables
                program.exitScope(); // Exit method scope
            }

            // If the current node represents a "Parameter"
            else if ((*i)->type == "Parameter") {
                string parameter_name = (*i)->children.back()->value; // Get parameter name
                string parameter_type = (*i)->children.front()->type; // Get parameter type
                if (parameter_type == "Identifier") {
                    parameter_type = (*i)->children.front()->children.front()->value; // Adjust if type is identifier
                }
                Variable new_parameter;
                new_parameter.setId(parameter_name); // Set parameter ID
                new_parameter.setType(parameter_type); // Set parameter type
                new_parameter.setRecord("parameter"); // Set record type as "parameter"
                new_parameter.setline((*i)->lineno); // Set line number for parameter
                new_parameter.setVisited(0); // Initialize visited status
                program.put(parameter_name, new_parameter); // Add parameter to symbol table
                program.getParentScope()->get_method()->addParameter(new_parameter); // Register with method
            }

            // If the current node represents a "VarD" (variable declaration)
            else if ((*i)->type == "VarD") {
                string variable_type = (*i)->children.front()->type; // Get variable type
                if (variable_type == "Identifier") {
                    variable_type = (*i)->children.front()->children.front()->value; // Adjust if type is identifier
                }
                string variable_name = (*i)->children.back()->value; // Get variable name
                Variable new_variable;
                new_variable.setId(variable_name); // Set variable ID
                new_variable.setType(variable_type); // Set variable type
                new_variable.setRecord("variable"); // Set record type as "variable"
                new_variable.setVisited(0); // Initialize visited status
                new_variable.setline((*i)->children.back()->lineno); // Set line number for variable
                program.put(variable_name, new_variable); // Add variable to symbol table
                if (parent->type == "VarDeclarations") {
                    program.getParentScope()->get_class()->addVariable(new_variable); // Register with class if in class scope
                } else {
                    program.getParentScope()->get_method()->addVariable(new_variable); // Register with method if in method scope
                }
            }

            // If the current node contains "VarDeclarations"
            else if ((*i)->type == "VarDeclarations") {
                (*i)->traverseTree(program, (*i)); // Recursively traverse variable declarations
            }
        }
    }

    /**
     * Collects all scopes from the scope tree into the scopes vector, starting from the root.
     * parameter root The root scope to start collecting from.
     */
    void collect_rest(Scope* root) {
        // If root is null, terminate the function
        if (!root) {
            return;
        }

        int counter = 0; // Initialize counter to track if root has been added

        // Iterate through each child scope of the root
        for (Scope* child : root->getChildren()) {
            // Add the root scope to the scopes list only once for the first child
            if (counter == 0) {
                scopes.push_back(root); // Add root to scopes
                counter += 1; // Increment counter to avoid adding root again
            }

            // Visit the child scope for further processing
            visit_child(child);

            // Add the root scope to the scopes list again after visiting each child
            scopes.push_back(root);
        }
    }

    /**
     * Recursively visits child scopes, adding them to the scopes vector for semantic analysis.
     * parameter child The child scope to visit.
     */
    void visit_child(Scope* child) {
        // Add the child to the scopes vector
        scopes.push_back(child);

        // Iterate through the children of the current child
        for (Scope* grandchild : child->getChildren()) {
            visit_child(grandchild);
            // If the grandchild is not the last child in the list, add the current child scope to scopes
            if (grandchild != child->getChildren().back()) {
                scopes.push_back(child);
            }
        }
    }

    /**
     * Initiates scope collection by calling collect_rest with the root scope.
     * parameter root The root scope.
     */
    void collecting_scops(Scope* root) {
        collect_rest(root);
    }

    /**
     * Collects all scopes from the symbol table and initializes the current iterator.
     * parameter program The symbol table whose scopes will be traversed.
     */
    void scopesTraversal(SymbolTable program) {

    // Collect all scope information from the current scope in the symbol table
    collecting_scops(program.getCurrent());

    // Swap the positions of scopes at index 1 and 2 in the scopes vector 
    std::swap(scopes[1], scopes[2]);// the left side of the stree should swap the scops main and method ( because of our tree structure )

    // Set the current iterator to the beginning of the scopes vector
    current = scopes.begin();
}

    /**
     * Advances the iterator to the next scope and returns a Result struct with the updated iterator and scope.
     * parameter curr Reference to the current iterator in the scopes vector.
     * return Result containing the updated iterator and scope.
     */
    Result nextscope(vector<Scope*>::iterator& curr) {
        if (curr == scopes.end()) {
            return {curr, nullptr};
        }

        ++curr; // Increment the iterator by reference
        if (curr == scopes.end()) // Avoid dereferencing if we've reached the end
        {
            return {curr, nullptr};
        }

        Scope* scope = *curr;
        return {curr, scope};
    }

    /**
     * Moves the iterator to the previous scope and returns a Result struct with the updated iterator and scope.
     * parameter curr Reference to the current iterator in the scopes vector.
     * return Result containing the updated iterator and scope.
     */
    Result previousscope(vector<Scope*>::iterator& curr) {
        if (curr == scopes.end()) {
            return {curr, nullptr};
        }

        --curr; // Decrement the iterator by reference
        if (curr == scopes.end()) // Avoid dereferencing if we've reached the end
        {
            return {curr, nullptr};
        }

        Scope* scope = *curr;
        return {curr, scope};
    }

    /**
     * Performs semantic analysis on the syntax tree starting from this node.
     * Checks for declarations, duplicates, and semantic correctness.
     * parameter current Reference to the current iterator in the scopes vector.
     * parameter scopes Vector of collected scopes.
     */
    void semantic(vector<Scope*>::iterator& current, std::vector<Scope*> scopes) {

        // Loop through each child node in the current node's children list
        for (auto i = children.begin(); i != children.end(); i++) {

            // If the current node represents a "Mainclass"
            if ((*i)->type == "Mainclass") {
                scope = *current; // Set current scope
                string name = (*i)->children.front()->value; // Get class name
                int line = (*i)->children.front()->lineno; // Get line number
                checkDuplicate(scope->getScopeRecords(), name, line); // Check for duplicates in the scope
                (*i)->children.back()->semantic(current, scopes); // Recursively apply semantic analysis to child nodes
            }

            // If the current node represents a "Method"
            if ((*i)->type == "Method") {
                Result res = nextscope(current); // Move to the next scope
                scope = res.scope; // Update current scope
                current = res.current; // Update iterator position
                string name = (*i)->children.front()->children.front()->value; // Get method name
                int line = (*i)->children.front()->children.front()->lineno; // Get line number
                checkDuplicate(scope->getScopeRecords(), name, line); // Check for duplicates in the method scope

                res = nextscope(current); // Move to the next scope for the main method
                scope = res.scope; // Update scope
                current = res.current; // Update iterator
                name = "main"; // Set method name as "main"
                line = (*i)->children.front()->lineno; // Get line number
                checkDuplicate(scope->getScopeRecords(), name, line); // Check for duplicates
            }

            // If the node contains "ClassDeclarations"
            if ((*i)->type == "ClassDeclarations") {
                (*i)->semantic(current, scopes); // Recursively apply semantic analysis to class declarations
            }

            // If the current node represents a "ClassD"
            if ((*i)->type == "ClassD") {
                Result res = nextscope(current); // Move to the next scope
                scope = res.scope; // Update scope
                current = res.current; // Update iterator
                string name = (*i)->children.front()->value; // Get class name
                int line = (*i)->children.front()->lineno; // Get line number
                checkDuplicate(scope->getScopeRecords(), name, line); // Check for duplicates
                (*i)->children.back()->semantic(current, scopes); // Recursively apply semantic analysis to class content
            }

            // If the current node contains "VarDeclarations"
            if ((*i)->type == "VarDeclarations") {
                Result res = nextscope(current); // Move to the next scope
                scope = res.scope; // Update scope
                current = res.current; // Update iterator
                (*i)->semantic(current, scopes); // Apply semantic analysis to variable declarations
                res = previousscope(current); // Move back to previous scope
                scope = res.scope; // Restore previous scope
                current = res.current; // Restore iterator
            }

            // If the current node contains "MethodDeclarations"
            if ((*i)->type == "MethodDeclarations") {
                (*i)->semantic(current, scopes); // Recursively apply semantic analysis to method declarations
            }

            // If the current node represents a specific method declaration, "MethodD"
            if ((*i)->type == "MethodD") {
                Result res = nextscope(current); // Move to the next scope
                scope = res.scope; // Update scope
                current = res.current; // Update iterator
                Node* id = *std::next((*i)->children.begin(), 1); // Retrieve method ID
                string record_type = scope->getScopeRecords()[id->value].getRecord(); // Get record type
                if (record_type == "variable") {
                    string class_name = scope->look_for_class_name(id->value, id->lineno); // Look up class name
                    Class* wanted_class = scope->getParentScope()->lookup_class(class_name); // Look up class in parent scope
                    int cc = wanted_class->lookupMethod(id->value)->getVisited(); // Check if method was visited
                    if (cc == 0) {
                        wanted_class->lookupMethod(id->value)->setVisited(1); // Mark method as visited
                    } else {
                        cout << "Method " << id->value << ": already declared @line " << id->lineno << endl; // Output duplicate warning
                    }
                } else {
                    checkDuplicate(scope->getScopeRecords(), id->value, id->lineno); // Check for duplicates
                }
                res = nextscope(current); // Move to the next scope
                scope = res.scope; // Update scope
                current = res.current; // Update iterator
                (*i)->semantic(current, scopes); // Recursively apply semantic analysis to method body
            }

            // If the current node represents a "Return" statement
            if ((*i)->type == "Return") {
                scope = *current; // Set current scope
                if ((*i)->children.size() > 1) {
                    string name = (*i)->children.front()->value; // Get return variable name
                    int line = (*i)->children.front()->lineno; // Get line number
                    checkDecleration(name, line, scope); // Check if variable is declared
                }
            }

            // If the current node represents "parameters"
            if ((*i)->type == "parameters") {
                (*i)->semantic(current, scopes); // Recursively apply semantic analysis to parameters
            }

            // If the current node represents a single "Parameter"
            if ((*i)->type == "Parameter") {
                scope = *current; // Set current scope
                string parameter_name = (*i)->children.back()->value; // Get parameter name
                int line = (*i)->children.back()->lineno; // Get line number
                checkDuplicate(scope->getScopeRecords(), parameter_name, line); // Check for duplicates
            }

            // If the node represents either "contV" or "contS"
            if ((*i)->type == "contV" || (*i)->type == "contS") {
                (*i)->semantic(current, scopes); // Recursively apply semantic analysis to these nodes
            }

            // If the current node represents a "VarD" (variable declaration)
            if ((*i)->type == "VarD") {
                scope = *current; // Set current scope
                string variable_name = (*i)->children.back()->value; // Get variable name
                int line = (*i)->children.back()->lineno; // Get line number
                string variable_type = (*i)->children.front()->type; // Get variable type
                if (variable_type == "Identifier") {
                    variable_type = (*i)->children.front()->children.front()->value; // Adjust if type is identifier
                    if (checkDecleration(variable_type, line, scope) != nullptr) {
                        checkDuplicate(scope->getScopeRecords(), variable_name, line); // Check for duplicates if declared
                    }
                } else {
                    checkDuplicate(scope->getScopeRecords(), variable_name, line); // Check for duplicates
                }
            }

            // If the node represents a variable statement, "varStatment"
            if ((*i)->type == "varStatment") {
                scope = *current; // Set current scope
                string name = (*i)->children.front()->value; // Get variable name
                int line = (*i)->children.front()->lineno; // Get line number
                checkDecleration(name, line, scope); // Check if variable is declared
                (*i)->semantic(current, scopes); // Recursively apply semantic analysis to statement body
            }

            // If the node represents an "IFStatment"
            if ((*i)->type == "IFStatment") {
                (*i)->semantic(current, scopes); // Recursively apply semantic analysis to the "IF" statement
            }

            // If the node represents a "LTExpression" (less than expression)
            if ((*i)->type == "LTExpression") {
                scope = *current; // Set current scope
                if ((*i)->children.front()->type == "ArrayExpression") {
                    string name = (*i)->children.front()->children.front()->value; // Get array expression name
                    int line = (*i)->children.front()->children.front()->lineno; // Get line number
                    checkDecleration(name, line, scope); // Check if declared
                } else {
                    if ((*i)->children.front()->type == "Expression") {
                        (*i)->semantic(current, scopes); // Recursively apply semantic analysis to expression
                    } else {
                        string name = (*i)->children.front()->value; // Get expression name
                        int line = (*i)->children.front()->lineno; // Get line number
                        checkDecleration(name, line, scope); // Check if declared
                    }
                }
            }

            // If the node represents an "ArrayStatement"
            if ((*i)->type == "ArrayStatement") {
                string name = (*i)->children.front()->value; // Get array name
                int line = (*i)->children.front()->lineno; // Get line number
                checkDecleration(name, line, scope); // Check if array is declared
            }

            // If the node represents an "ElseStatment"
            if ((*i)->type == "ElseStatment") {
                (*i)->semantic(current, scopes); // Recursively apply semantic analysis to the "else" statement
            }

            // If the node represents a "MultExpression" (multiplication expression)
            if ((*i)->type == "MultExpression") {
                scope = *current; // Set current scope
                string name = (*i)->children.front()->value; // Get variable name
                int line = (*i)->children.front()->lineno; // Get line number
                checkDecleration(name, line, scope); // Check if declared
                (*i)->children.back()->semantic(current, scopes); // Apply semantic analysis to the expression's body
            }

            // If the node represents an "Expression"
            if ((*i)->type == "Expression") {
                scope = *current; // Set current scope
                Node* id = *std::next((*i)->children.begin(), 1); // Get expression ID
                if ((*i)->children.front()->type == "ID") {
                    string name = (*i)->children.front()->value; // Get name
                    int line = (*i)->children.front()->lineno; // Get line number
                    Record* record = scope->lookUp(name); // Look up record for name
                    if (record != nullptr) {
                        string record_type = record->getType(); // Get record type
                        Scope* scop_ind = scopes[(scopes.size() - 1)]->look_in_insertion(record_type); // Check scope for record
                        checkDecleration(id->value, id->lineno, scop_ind); // Check declaration of expression ID
                    }
                } else {
                    checkDecleration(id->value, id->lineno, scope); // Check declaration if ID
                }
                (*i)->children.back()->semantic(current, scopes); // Apply semantic analysis to expression's child
            }

            // If the node represents a "SubExpression"
            if ((*i)->type == "SubExpression") {
                scope = *current; // Set current scope
                if ((*i)->children.front()->type != "INTExpression") {
                    string name = (*i)->children.front()->value; // Get sub-expression name
                    int line = (*i)->children.front()->lineno; // Get line number
                    checkDecleration(name, line, scope); // Check if declared
                }
            }
        }
    }

    /**
     * Initiates semantic analysis by collecting scopes and invoking the semantic method.
     * parameter root The root node of the syntax tree.
     * parameter program The symbol table for semantic analysis.
     */
    void run_semantic(Node* root, SymbolTable program) {
        scopesTraversal(program);
        semantic(current, scopes);
    }

    /**
     * Checks if an identifier is declared in the given scope or any parent scope.
     * Reports an error if not declared.
     * parameter key The identifier name to check.
     * parameter lineno The line number where the identifier is used.
     * parameter scope The scope to check in.
     * return Pointer to the Record if found, or nullptr if not declared.
     */
    Record* checkDecleration(const std::string& key, int lineno, Scope* scope) const {

        Record* record = scope->lookUp(key);
        if (record == nullptr) {
            cout << key << ": is not declared @line --" << lineno << endl;
            return nullptr;
        } else {
            if (record->getRecord() == "variable" || record->getRecord() == "parameter") {
                if (record->getline() > lineno) {
                    cout << key << ": is not declared @line " << lineno << endl;
                    return nullptr;
                }
            }
            return record;
        }
    }

    /**
     * Checks if an identifier has already been declared in the current scope.
     * Reports an error if it's a duplicate.
     * parameter records Reference to the scope's records map.
     * parameter key The identifier name to check.
     * parameter lineno The line number where the identifier is declared.
     */
    void checkDuplicate(std::map<std::string, Record>& records, const std::string& key, int lineno) {

        if (records[key].getVisited()) {
            cout << records[key].getRecord() << " " << key << ": already declared @line " << lineno << endl;
        } else {
            records[key].setVisited(1);
        }
    }

    /**
     * Generates a DOT file (tree.dot) representing the syntax tree for visualization.
     */
    void generate_tree() {
        std::ofstream outStream;
        char* filename = "tree.dot";
        outStream.open(filename);

        int count = 0;
        outStream << "digraph {" << std::endl;
        generate_tree_content(count, &outStream);
        outStream << "}" << std::endl;
        outStream.close();

        printf("\nBuilt a parse-tree at %s. Use 'make tree' to generate the pdf version.", filename);
    };

    /**
     * Recursively writes the syntax tree nodes and edges to the DOT file.
     * parameter count Reference to the node ID counter.
     * parameter outStream Output file stream.
     */
    void generate_tree_content(int& count, ofstream* outStream) {
        id = count++;
        *outStream << "n" << id << " [label=\"" << type << ":" << value << "\"];" << endl;

        for (auto i = children.begin(); i != children.end(); i++) {
            (*i)->generate_tree_content(count, outStream);
            *outStream << "n" << id << " -> n" << (*i)->id << endl;
        }
    };

};

#endif
