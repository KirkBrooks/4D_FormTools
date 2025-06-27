/*  HostProject class
 Created by: Kirk Brooks as Designer, Created: 04/06/25, 12:14:02
 ------------------
Designed for use in components where you need to manipulate
files in the host component.

*/
property isComponent : Boolean  // true if this is running as a component
property root : 4D.Folder
property _docFolder : 4D.Folder  //  documentation root
property name : Text

Class constructor($structureFilePath : Text)
	$structureFilePath:=$structureFilePath || Structure file(*)
	var $file : 4D.File
	$file:=File($structureFilePath; fk platform path)
	
	This.isComponent:=Structure file#Structure file(*)
	This.name:=$file.name
	//This.root:=Folder(Folder(fk database folder; *).platformPath; fk platform path)
	This.root:=$file.parent.parent
	
	This._docFolder:=This.root.folder("Documentation")
	
	//mark:  --- getters
Function get Project : 4D.Folder
	If (This.root.folder("Project").exists)
		return This.root.folder("Project")
	Else 
		return This.root
	End if 
	
Function get Sources : 4D.Folder
	return This.Project.folder("Sources")
	
Function get Classes : 4D.Folder
	return This.Sources.folder("Classes")
	
Function get Methods : 4D.Folder
	return This.Sources.folder("Methods")
	
Function get Documentation : 4D.Folder
	return This.root.folder("Documentation")
	
Function get Components : 4D.Folder
	return This.root.folder("Components")
	
Function get Plugins : 4D.Folder
	return This.root.folder("Plugins")
	
Function get Macros : 4D.Folder
	return This.root.folder("Macros v2")
	
Function get Forms : 4D.Folder
	return This.Sources.folder("Forms")
	
Function get catalog : 4D.File
	return This.Sources.file("catalog.4DCatalog")
	
Function get folders : 4D.File
	return This.Sources.file("folders.json")
	
	//mark:  --- Host Information
	
	
	//mark:  --- functions
Function getForm($name : Text; $documentation : Boolean) : 4D.Folder
	If ($documentation)
		return This._docFolder.folder("Forms").file($name+".md")
	Else 
		return This.Forms.folder($name)
	End if 
	
Function getClass($name : Text; $documentation : Boolean) : 4D.File
	If ($documentation)
		return This._docFolder.folder("Classes").file($name+".md")
	Else 
		return This.Classes.file($name+".4dm")
	End if 
	
Function getMethod($name : Text; $documentation : Boolean) : 4D.File
	If ($documentation)
		return This._docFolder.folder("Methods").file($name+".md")
	Else 
		return This.Methods.file($name+".4dm")
	End if 
	
Function getLocalFileFromPath($path : Text) : 4D.File
	If ($path="")
		return Null
	End if 
	
	return This.root.file($path)
	
Function getLocalFolderFromPath($path : Text) : 4D.Folder
	If ($path="")
		return This.root
	End if 
	return This.root.folder($path)
	
	//mark:  --- github paths
Function getClassPath($name : Text; $documentation : Boolean) : Text
	If ($documentation)
		return "Documentation/Classes/"+$name+".md"
	Else 
		return "Project/Sources/Classes/"+$name+".4dm"
	End if 
	
Function getMethodPath($name : Text; $documentation : Boolean) : Text
	If ($documentation)
		return "Documentation/Methods/"+$name+".md"
	Else 
		return "Project/Sources/Methods/"+$name+".4dm"
	End if 
	
Function getFormPath($name : Text; $documentation : Boolean) : Text
	If ($documentation)
		return "Documentation/Forms/"+$name+".md"
	Else 
		return "Project/Sources/Forms/"+$name+"/"
	End if 
	