#include <bits/stdc++.h>
#include <list>
#include <iostream>
#include <fstream>
#include <vector>
#include <unistd.h>
#include <sys/wait.h>
#include <string>
#include <iterator>

#include <map>
#include <stack>
#include <algorithm>
#include <cctype>
using namespace std;
class Variable;
class Method;

class Record {
public:
  std::string getId() const {
    return id;
  }

  void setId(const std::string& newId) {
    id = newId;
  }

  std::string getType() const {
    return type;
  }

  std::string getRecord() const {
    return record;
  }

  void setType(const std::string& newtype) {
    type = newtype;
  }
  // for debugging purposes printing the symbol table
  void printRecord() const {
    std::cout << "record: " << record << ", type: "<< type <<std::endl;
  }

  void setRecord(const std::string& newRecord) {
    record = newRecord;
  }
  void setline( int line_number) {
	  linenumber = line_number;
  }

  int getline() {
	return linenumber;
  }
  //additional functions to check if the record was visited before
  int getVisited() {
	return visited;
  }
  void setVisited( int visit) {
	  visited = visit;
  }
private:
  std::string id;
  std::string type;
  std::string record;
  mutable int visited;
  int linenumber;
};

class Variable : public Record {
public:
};

class Method : public Record {
public:
  void addParameter(const Variable& parameter) {
    if (lookupParameter(parameter.getId()))
    {
      Dparameters.push_back(parameter);
    }
    else{
      parameters.push_back(parameter);
    }
    
  }

  void addVariable(const Variable& variable) {
    if (variables.find(variable.getId()) != variables.end())
    {
      Dvariables.push_back(variable);
    }
    else 
    {
      variables.insert({variable.getId(), variable});
    }
  }
  bool lookupVariable(const std::string& id) {
    
    if (variables.find(id)!=variables.end())
    {
      return true;
    }
    else{
      return false;
    }
  }
  bool lookupParameter(const std::string& id) {
    for (auto& parameter : parameters) {
      if (parameter.getId() == id) {
        return true;
      }
    }
    return false;
  }


  const std::vector<Variable>& getParameters() const {
        return parameters;
    }

    const std::vector<Variable>& getDparameters() const {
        return Dparameters;
    }

    const std::map<std::string, Variable>& getVariables() const {
        return variables;
    }

    const std::vector<Variable>& getDvariables() const {
        return Dvariables;
    }

private:
  std::vector<Variable> parameters;
  std::map<std::string, Variable> variables;
  std::vector<Variable> Dvariables;
  std::vector<Variable> Dparameters;
  
};

class Class : public Record {
public:
  void addVariable(const Variable& variable) {
    //check if the variable is already declared in the class
    if (variables.find(variable.getId()) != variables.end()){
      Dvariables.push_back(variable);
      }
    else {
      variables.insert({variable.getId(), variable});
    }
  }
  
  void addMethod(Method* method) {
    //check if the method is already declared in the class
    if (methods.find(method->getId()) != methods.end()){
      Dmethods.push_back(method);
      }
    else {
      methods.insert({method->getId(), method});
    }
  }

  Method* lookupMethod(const std::string& id) {

    if (methods.find(id) != methods.end()) 
    {
      return methods.at(id);
    } 
    else 
    {
      return nullptr;
    }

  }
  // we do not use it
  bool lookupVariable(const std::string& id) {
    
    if (variables.find(id)!=variables.end())
    {
      return true;
    }
    else{
      return false;
    }
  }


    const std::map<std::string, Variable>& getVariables() const {
        return variables;
    }

    const std::vector<Variable>& getDvariables() const {
        return Dvariables;
    }

    const std::map<std::string, Method*>& getMethods() const {
        return methods;
    }

    const std::vector<Method*>& getDmethods() const {
        return Dmethods;
    }

private:
  std::map<std::string, Variable> variables;
  std::map<std::string, Method*> methods;
  std::vector<Variable> Dvariables;
  std::vector<Method*> Dmethods;
};

class Scope {
public:
  Scope(Scope* parent = nullptr) : parentScope(parent) {
    }

  Scope* nextChild() {
    Scope* nextChild = new Scope(this);
    childrenScopes.push_back(nextChild);
    return nextChild;
  }

  Scope* getParentScope() const {
    return parentScope;
  }
    
  vector<Scope*> getChildren() const {
    return childrenScopes;
  }

  std::map<std::string, Record>& getScopeRecords() {
    return records;
  }

  void printScope() const {
    for (auto& pair : records) {
      cout<<"name: "<<pair.first<<";   ";
      pair.second.printRecord();
    }
  }

  void resetScope() {
    records.clear();
    childrenScopes.clear();
  }
  
  //add the record to the symbol table
  void put(const std::string& key, const Record& item) const 
  {
    if (in_insertionOrder(key))
    {
      insertionOrder.push_back(key);
    }
    else 
    {
      records[key] = item;
      insertionOrder.push_back(key);
    }
  }

  Record* lookUp(const std::string& key) const {
    if (records.find(key) != records.end()) 
    {
      return &records.at(key);
    } 
    else if (parentScope != nullptr) 
    {
      return parentScope->lookUp(key);
    } 
    else 
    {
      return nullptr;
    }
  }

  Class* get_class()
  {
    return class_f;
  }
  
  Method* get_method()
  {
    return method_f;
  }

  void set_class(Class* new_class)
  {
    class_f = new_class;
    classes.push_back(class_f);

  }

  Class* lookup_class(std::string& key){

    for (Class* class_ : classes){
      if (class_->getType() == key)
      {
        return class_;
      }
    }
    return nullptr;
  }

  void set_method(Method* new_method, Class* class_)
  {
    method_f = new_method;
    method_classes[class_->getType()].push_back(new_method);
  }

  string look_for_class_name(std::string& key, int line ){
    for (const auto& pair : method_classes){
      for (const auto& method : pair.second)
      {
        if (method->getId()== key && method->getline() == line){

          return pair.first;
        }
      }
    }
    return " ";

  }

// In Scope class
  void generate_st_tree() {
    std::ofstream outStream("stree.dot");
    outStream << "digraph {" << std::endl;

    int count = 0;
    int rootId = count++;
    // Build the root node label including class records
    std::string rootLabel = "Program: Goal\\n";
    for (Class* cls : classes) {
        rootLabel += "name: " + cls->getType() + "; record: class; type: " + cls->getType() + "\\n";
    }
    outStream << "n" << rootId << " [label=\"" << rootLabel << "\"];" << std::endl;

    // For each class in the 'classes' vector
    for (Class* cls : classes) {
        generate_class_node(cls, rootId, count, outStream);
    }

    outStream << "}" << std::endl;
    outStream.close();
}

// Helper function to generate class nodes recursively
  void generate_class_node(Class* cls, int parentId, int& count, std::ofstream& outStream) {
    int classId = count++;

    // Build the class node label including method records
    std::string classLabel = "Class: " + cls->getType() + "\\n";
    for (const auto& methodPair : cls->getMethods()) {
        const Method* method = methodPair.second;
        classLabel += "name: " + method->getId() + "; record: method; type: " + method->getType() + "\\n";
    }
    for (const auto& method : cls->getDmethods()) {
        classLabel += "name: " + method->getId() + "; record: method; type: " + method->getType() + "\\n";
    }
    for (const auto& varPair : cls->getVariables()) {
        const Variable variable = varPair.second;
        classLabel += "name: " + variable.getId() + "; record: variable; type: " + variable.getType() + "\\n";
    }

    for (const auto& variable : cls->getDvariables()) {
        classLabel += "name: " + variable.getId() + "; record: variable; type: " + variable.getType() + "\\n";
    }
    outStream << "n" << classId << " [label=\"" << classLabel << "\"];" << std::endl;

    // Edge from parent to class
    outStream << "n" << parentId << " -> n" << classId << ";" << std::endl;

    // Process methods in the class
    for (const auto& methodPair : cls->getMethods()) {
        const Method* method = methodPair.second;
        generate_method_node(method, classId, count, outStream);
    }
    for (const auto& method : cls->getDmethods()) {
        generate_method_node(method, classId, count, outStream);
    }

}

// Helper function to generate method nodes recursively
  void generate_method_node(const Method* method, int parentId, int& count, std::ofstream& outStream) {
    int methodId = count++;

    // Build the method node label including parameter and variable records
    std::string methodLabel = "Method: " + method->getId() + "\\n";

    // Add parameters to the method label
    for (const Variable& param : method->getParameters()) {
        methodLabel += "name: " + param.getId() + "; record: " + param.getRecord() + "; type: " + param.getType() + "\\n";
    }

    for (const Variable& param : method->getDparameters()) {
        methodLabel += "name: " + param.getId() + "; record: " + param.getRecord() + "; type: " + param.getType() + "\\n";
    }
    // Add variables to the method label
    for (const auto& varPair : method->getVariables()) {
        const Variable& var = varPair.second;
        methodLabel += "name: " + var.getId() + "; record: " + var.getRecord() + "; type: " + var.getType() + "\\n";
    }

    for (const auto& var : method->getDvariables()) {
        methodLabel += "name: " + var.getId() + "; record: " + var.getRecord() + "; type: " + var.getType() + "\\n";
    }

    outStream << "n" << methodId << " [label=\"" << methodLabel << "\"];" << std::endl;

    // Edge from parent (class) to method
    outStream << "n" << parentId << " -> n" << methodId << ";" << std::endl;
  }

  bool in_insertionOrder(const std::string& key) const
  {
    return std::find(insertionOrder.begin(), insertionOrder.end(), key) != insertionOrder.end();
  }
  
  vector<string> get_insertionOrder(){
    return insertionOrder;
  }

  Scope* look_in_insertion(string str){
    auto it = std::find(insertionOrder.begin(), insertionOrder.end(), str);
    if (it != insertionOrder.end()) {
        int indx = std::distance(insertionOrder.begin(), it);  // Return the index if found
        return childrenScopes[indx];
    }
    return nullptr;
  }

private:
  Class* class_f;
  Method* method_f;
  mutable std::map<std::string, Record> records;
  mutable std::vector<std::string> insertionOrder;
  Scope* parentScope;
  std::vector<Scope*> childrenScopes;
  std::vector<Class*> classes;
  std::map<std::string, std::vector<Method*>> method_classes;
};

class SymbolTable {

public:
  SymbolTable() {
    root = new Scope(nullptr);
    current = root;
  }

  void enterScope() {
    current = current->nextChild();
  }

  void exitScope() {
    current = current->getParentScope();
  }
  
  template <typename T>
  void put(const std::string& key, const T& item) {
  
  current->put(key, item);

  }
  
  Scope* getParentScope() const {
    return current->getParentScope();
  }
    
  vector<Scope*> getChildren() const {
    return current->getChildren();
  }

  void setCurrent(Scope* newCurrent) const {
    current = newCurrent;
  }

  Scope* getCurrent() const {
    return current;
  }

  Record* lookUp(const std::string& key) {
    return root->lookUp(key);
  }

  void printTable() {
    root->printScope();
  }

  void resetTable() {
    root->resetScope();
  }

  Class* get_class()
  {
    return current->get_class();
  }

  void set_class(Class* class_setter)
  {
    current->set_class(class_setter);
    classes.push_back(class_setter);
  }

  Method* get_method()
  {
    return current->get_method();
  }

  void set_method(Method* method_setter, Class* class_)
  {
    current->set_method(method_setter, class_);
  }

  vector<Scope*> getScopeChildren(){
    return current->getChildren();
  }

  std::map<std::string, Record> getRecords()
  {
    return current->getScopeRecords();
  }
  
  Scope *get_root()
  {
    return root;
  }

  bool in_insertionOrder(const std::string& key) const
  {
    return current->in_insertionOrder(key);
  }

  
private:
  Scope* root;
  mutable Scope* current;
  std::vector<Class*> classes;
  
};