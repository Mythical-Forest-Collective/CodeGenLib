import std/[tables, sequtils, strutils]

var globalNamespace* = "example"  # Can be overridden by the user

import java/[keywords, types, class, fileconstruction]
export java.keywords, java.types, java.class, java.fileconstruction


proc newJavaFile*(subpackage: string = "", namespace: string = ""): JavaFile =
  result = JavaFile()

  result.jparent = nil  # Can't have a parent for a Java file!

  if namespace == "":
    result.jnamespace = globalNamespace
  else:
    result.jnamespace = namespace

  result.jsubpackage = subpackage


proc imports*(jf: var JavaFile, importStmts: varargs[string]) =
  for importStmt in importStmts:
    jf.jimportStatements.add importStmt


proc newJavaVariableDeclaration*(typ: string, name: string, value:string="", final: bool = false,
    public: bool = false,
    statik: bool = false): JavaVariableDeclaration =
  result = JavaVariableDeclaration()

  result.jtyp = typ
  result.jname = name
  result.jvalue = value
  result.jpublic = public
  result.jstatik = statik
  result.jfinal = final


proc newJavaMethodDeclaration*(name:string, returnTyp:string="void",
    public: bool = false,
    statik: bool = false,
    final: bool = false): JavaMethodDeclaration =
  result = JavaMethodDeclaration()

  result.jname = name
  result.jreturnTyp = returnTyp
  result.jpublic = public
  result.jstatik = statik
  result.jfinal = final


proc newJavaBlock*(): JavaBlock =  # Empty
  return JavaBlock()


proc addMethodArgument*(jmethod:var JavaMethodDeclaration, typ:string, name:string) =
  jmethod.jarguments[name] = typ


proc addSnippetToMethodBody*(jmethod:var JavaMethodDeclaration, body:varargs[JavaBaseType]) =
  for item in body:
    item.jparent = jmethod
    jmethod.jbody.add item


proc setjparent(jb:JavaBlock):proc =
  return proc(snippet:JavaBaseType) =
    snippet.jparent = jb


proc addSnippetToBlock*(jb: var JavaBlock, name:string, snippets:openArray[JavaBaseType]) =
  jb.jnames.add name

  snippets.apply setjparent(jb)
  jb.jsnippets.add toSeq(snippets)

proc addSnippetToBlock*(jb: var JavaBlock, name:string, snippets:varargs[JavaBaseType]) =
  jb.jnames.add name

  toSeq(snippets).apply setjparent(jb)
  jb.jsnippets.add toSeq(snippets)


proc javacode*(code:string, suffix:string=""):JavaCodeEmission = JavaCodeEmission(jcode:code&suffix)
const jc* = javacode


proc constructMethodCall*(qualifiedMethodName:string, args:varargs[JavaBase]):string =
  result = qualifiedMethodName & "("

  var strargs = args.map(tostring)
  result &= strargs.join(", ")

  result &=  ")"
  # Don't terminate the line automatically because it may be used in a nested function call


proc initialiseClass*(className:string, args:varargs[JavaBase]):string =
  result = "new" & className & "("

  var strargs = args.map(tostring)
  result &= strargs.join(", ")

  result &=  ")"