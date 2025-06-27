/*  modify_forms - form method
 Created by: Kirk Brooks as Designer, Created: 06/17/25, 13:43:11
 ------------------
4D Project
Default to the current database. Allow user to choose other.


*/

var $objectName; $message : Text
var $forms_LB : cs.listbox
var $col : Collection
$col:=[]
var $result; $obj : Object
var $codeTransforms : Collection
var $host : cs.HostProject  //  host is 4D project we are modifying forms on
var $file : 4D.File

If (Form=Null)
	return 
End if 

$objectName:=String(FORM Event.objectName)
$forms_LB:=Form.forms_LB || cs.listbox.new("form_LB")
$host:=Form.host || cs.HostProject.new()  //  defaults to the current database

//mark:  --- form actions
If (FORM Event.code=On Load)  //  catches all objects
	Form.host:=$host
	
	Form.withProjectForms:=True
	Form.withTableForms:=True
	
	Form.forms_LB:=$forms_LB
	Form.grep_pattern:=""
	
	Form.object_names:=""
	Form.object_types:=""
	Form.object_data_types:=""
	
	// keep a list of the code transforms you create during this session
	If (Storage._code_transforms=Null)
		Use (Storage)
			Storage._code_transforms:=New shared collection()
		End use 
	End if 
	
End if 

$codeTransforms:=Storage._code_transforms.copy()

//mark:  --- object actions
If ($objectName="btn_project")
	$path:=Select folder("Choose a 4D Project folder:")
	If ($path#"")
		//  get the structure file platform name
		$file:=Folder($path; fk platform path).folder("Project").files().query("extension = :1"; ".4DProject").first()
		
		If (OB Is defined($file) && ($file.exists))
			Form.host:=cs.HostProject.new($file.platformPath)
		Else 
			$message:="Please select a 4D Project folder. "
		End if 
		
	End if 
End if 

If ($objectName="btn_search")
	// Grep has a lot of options, some of them are useful here
	var $options : Object
	$options:={}
	$options.recursive:=True
	$options.listFiles:=True
	$options.caseSensitive:=Not(Form.caseInsensitive)
	$options.pattern:=Form.withRegx ? "-G" : "-F"
	$options.queryStr:=Form.grep_pattern
	
	// we will run two grep queries - one for Form and Table Forms
	If (Form.withTableForms)
		$options.folder:=$host.Sources.folder("TableForms")
		GREP($options)
		
		For each ($path; $options.searchResults)
			$file:=File($path)
			$tableName:=Table name(Num($file.parent.parent.name))
			$obj:={file: $file; name: $file.parent.name; table: $tableName; ck: False}
			$col.push($obj)
		End for each 
	End if 
	
	If (Form.withProjectForms)
		$options.folder:=$host.Forms
		$options.searchResults:=[]
		
		GREP($options)
		
		For each ($path; $options.searchResults)
			$file:=File($path)
			$obj:={file: $file; name: $file.parent.name; ck: False}
			$col.push($obj)
		End for each 
	End if 
	
	$forms_LB.setSource($col)
	
End if 

If ($objectName="forms_LB")
	Case of 
		: (FORM Event.code=On Double Clicked) & ($forms_LB.isSelected)
			$obj:=$forms_LB.currentItem
			
			// open the form
			If (String($obj.table)#"")
				var $ptr : Pointer
				$ptr:=Table(Num($obj.file.parent.parent.name))
				FORM EDIT($ptr->; $obj.name)
			Else 
				FORM EDIT(String($obj.name))
			End if 
			
		: (FORM Event.code=On Clicked) & (Contextual click)
			var $menu : Text
			$menu:="Toggle selected;All false;All true;---;Clear list;Remove selected"
			var $i : Integer
			$i:=Pop up menu($menu)
			
			Case of 
				: ($i=5)  // clear list
					$forms_LB.setSource([])
					
				: ($i=1) & ($forms_LB.isSelected)
					For each ($obj; $forms_LB.selectedItems)
						$obj.ck:=Not($obj.ck)
					End for each 
					
				: ($i=2)
					For each ($obj; $forms_LB.data)
						$obj.ck:=False
					End for each 
					
				: ($i=3)
					For each ($obj; $forms_LB.data)
						$obj.ck:=True
					End for each 
					
				: ($i=6) && ($forms_LB.isSelected)
					For each ($obj; $forms_LB.selectedItems)
						$forms_LB.data.remove($forms_LB.data.indexOf($obj))
					End for each 
					$forms_LB.redraw()
					
			End case 
			
			$forms_LB.redraw()
			
		: (FORM Event.code=On Drop)
			$i:=1
			Repeat 
				$filePath:=Get file from pasteboard($i)
				
				If ($filePath#"")
					$filePath+="form.4dform"
					
					$file:=File($filePath; fk platform path)
					
					//  table or project
					If (Match regex("^\\d+$"; $file.parent.parent.name; 1))
						$tableName:=Table name(Num($file.parent.parent.name))
						$obj:={file: $file; name: $file.parent.name; table: $tableName; ck: True}
						
					Else   // project
						$tableName:=""
						$obj:={file: $file; name: $file.parent.name; ck: True}
					End if 
					
					
					Case of 
						: ($forms_LB.source=Null)
							$forms_LB.setSource([$obj])
							
						: ($forms_LB.data.query("name = :1 AND table = :2"; $file.parent.name; $tableName).length>0)
							// is it already there?
							
						Else 
							$forms_LB.data.insert(0; $obj)
					End case 
					
					$i+=1
				End if 
				
			Until ($filePath="")
	End case 
End if 

If ($objectName="btn_apply")
	// if both object names and types are empty the transform is
	// applied to all objects on the form
	
	Case of 
		: ($forms_LB.dataLength=0) || ($forms_LB.data.query("ck = :1"; True).length=0)
			$message:="No forms to apply to."
	End case 
	
	var $files : Collection
	$files:=$forms_LB.data.query("ck = :1"; True)
	$files:=$files.extract("file")
	
	If ($message="")
		// save this transform code
		var $hash : Text
		$hash:=Generate digest(Form.transformCode; MD5 digest)
		
		If ($codeTransforms.query("hash = :1"; $hash).first()=Null)
			
			Use (Storage._code_transforms)
				Storage._code_transforms.push(OB Copy({hash: $hash; code: Form.transformCode}; ck shared))
			End use 
			
		End if 
		
		// loop through the selected listbox data
		$result:=FormMods_apply(\
			$files; \
			Form.object_types; \
			Form.object_names; \
			Form.object_data_types; \
			Form.transformCode)
		
		If (Not($result.success))
			$message:=$result.message
		End if 
	End if 
	
End if 

If ($objectName="btn_code")
	$menu:=Create menu
	
	For each ($obj; $codeTransforms)
		APPEND MENU ITEM($menu; Substring($obj.code; 1; 25); *)
		SET MENU ITEM PARAMETER($menu; -1; $obj.hash)
	End for each 
	
	// ---- display the menu, get the result
	$hash:=Dynamic pop up menu($menu)
	RELEASE MENU($menu)
	// ----
	
	If ($hash#"")
		Form.transformCode:=$codeTransforms.query("hash= :1"; $hash).first().code
	End if 
	
End if 


//mark:  --- update state and formats

AlertDialog($message)
