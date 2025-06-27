//%attributes = {}
/* Purpose:
 ------------------
GREP ()
 Created by: Kirk Brooks as Designer, Created: 09/05/24, 21:13:10
 https://www.man7.org/linux/man-pages/man1/grep.1.html

Common options include:

-i: Ignore case distinctions.
-r: Read all files under each directory, recursively.
-n: Prefix each line of output with the line number within its input file.
-l: Print only names of files with matching lines.

The -F flag tells grep to treat the pattern as fixed strings (literal text) rather than regular expressions
The @ symbol in 4D is a wildcard that matches any characters after "Fixed"

The -E flag enables extended regular expressions (ERE) in grep

The -P flag enables Perl Compatible Regular Expressions

the -G flag, which specifies basic regular expressions (BRE) - this is grep's default behavior
*/
#DECLARE($options : Object) : Object
var $systemworker : 4D.SystemWorker
var $cmd : Text
var $folder : 4D.Folder

If (Value type($options.folder)=Is object)
	$folder:=$options.folder
Else
	ABORT
End if

$pathStr:=$folder.path

If (Not($folder.exists))
	$options.success:=False
	$options.error:="Folder does not exist. "
	return
End if

//$csParams:=cs.Params.new()
$csParams:=cs.SysWorkerParams.new()
$csParams.currentDirectory:=$folder
$csParams.hideWindow:=False

//mark:  --- build the grep command
$cmd:="grep "

Case of
	: ($options.pattern="Fixed@")
		$cmd+="-F "
	: ($options.pattern="Extended@")
		$cmd+="-E "
	: ($options.pattern="PCRE")
		$cmd+="-P "
	Else   //  default
		$cmd+="-G "
End case

If (Not(Bool($options.caseSensitive)))
	$cmd+="-i "  //  case insensitive
End if

If (Bool($options.recursive))
	$cmd+="-r "
End if

If (Bool($options.lineNumbers))
	$cmd+="-n "
End if

If (Bool($options.listFiles))
	$cmd+="-l "
End if

If (Bool($options.wholeWord))  //--word-regexp
	$cmd+="-w "
End if

If (String($options.fileType)#"")
	//  must be comma delimited
	$col:=Split string($options.fileType; ","; sk ignore empty strings+sk trim spaces)

	$cmd+="--include='*."

	If ($col.length=1)
		$cmd+=$col[0]+"' "
	Else
		$cmd+="{"+$col.join(",")+"}' "
	End if

End if

$cmd+="'"+$options.queryStr+"' '"+$pathStr+"'"
$options.cmd:=$cmd
//mark:  --- run

$resFolder:=Folder(Folder(fk resources folder).platformPath; fk platform path)
$file:=$resFolder.file("shell.sh")

$shellScript:="#!/bin/sh\nexport PATH=/usr/local/bin:$PATH\n<!--#4DHTML $1-->"
PROCESS 4D TAGS($shellScript; $shellScript; $cmd)

$file.setText($shellScript)
// make the file executable
$command:="chmod +x '"+$file.path+"'"
$systemworker:=4D.SystemWorker.new($command; $csParams)

$command:="'"+$file.path+"'"

$systemworker:=4D.SystemWorker.new($command; $csParams)
$systemworker.wait(60)


//mark:  ---
$col:=[]

If ($csParams.data#"")
	$col:=Split string($csParams.data; "\n"; sk trim spaces+sk ignore empty strings)
	$options.success:=True
	$options.searchResultsCount:=$col.length
	$options.searchResults:=$col

Else
	$options.success:=False
	$options.searchResultsCount:=0
	$options.searchResults:=$col
	$options.error:="No results found. "

End if
