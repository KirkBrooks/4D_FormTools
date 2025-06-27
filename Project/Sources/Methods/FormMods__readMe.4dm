//%attributes = {}
_executeSnippet()

//mark:  --- grep form folders

$options:={}
$options.folder:=cs.HostProject.new().Forms
$options.folder:=cs.HostProject.new().Sources.folder("TableForms")
$options.recursive:=True
$options.listFiles:=True
$options.queryStr:="\"type\": \"button\""
$options.queryStr:="\"class\": \"Entry_Fields\""

GREP($options)

