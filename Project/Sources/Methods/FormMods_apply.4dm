//%attributes = {}
/* Purpose: applies some 4D transformation code to 
form objects on the forms passed in
 ------------------
FormMods_apply ()
 Created by: Kirk Brooks as Designer, Created: 06/17/25, 23:07:26
*/

#DECLARE($files : Collection; $obj_types : Text; $obj_names : Text; $data_types : Text; $transformCode : Text)->$result : Object
var $file : 4D.File
var $formDef; $page; $pageObjects; $formObject : Object
var $thisName; $code : Text
var $isChanged : Boolean

If ($files=Null) || ($files.length=0)
	$result:={success: False; message: "No form definition files"}
	return 
End if 

If ($transformCode="")
	$result:={success: False; message: "No transformation code"}
	return 
End if 

// these may be empty
var $names : Collection
$names:=Split string($obj_names; ";"; sk ignore empty strings+sk trim spaces)
var $types : Collection
$types:=Split string($obj_types; ";"; sk ignore empty strings+sk trim spaces)
var $dataTypes : Collection
$dataTypes:=Split string($data_types; ";"; sk ignore empty strings+sk trim spaces)


For each ($file; $files)
	
	$formDef:=JSON Parse($file.getText())
	$isChanged:=False
	
	// loop through each page 
	For each ($page; $formDef.pages)
		
		If ($page=Null)  // some of the first project conversions have null page 0
			continue
		End if 
		
		$pageObjects:=$page.objects
		
		For each ($thisName; $pageObjects)
			$formObject:=$pageObjects[$thisName]  // the actual form object
			
			// is this an object name we care about?
			If ($names.length>0) && ($names.indexOf($thisName)=-1)
				continue
			End if 
			
			// is this an object type we care about?
			If ($types.length>0) && ($types.indexOf($formObject.type)=-1)
				continue
			End if 
			
			//  is this a data type we care about?
			If ($dataTypes.length>0) && ($dataTypes.indexOf($formObject.dataSourceTypeHint)=-1)
				continue
			End if 
			
			//mark:  ---   apply the transformation code
			// wrap in tags
			$code:="<!--#4DCODE\n"
			$code+=$transformCode
			$code+="\n-->"
			
			PROCESS 4D TAGS($code; $code; $formObject)
			
			$isChanged:=True  // don't bother updating the file if nothing changes
			
		End for each 
	End for each 
	
	If ($isChanged)
		// write the new form def back to the file
		$file.setText(JSON Stringify($formDef; *))
	End if 
	
End for each 

// reload to update any forms currently open in the editor
RELOAD PROJECT

return {success: True}