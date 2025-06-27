/*  SysWorkerParams class
 Created by: Kirk as Designer, Created: 03/05/23, 00:17:48
 ------------------
Instantiate before calling a System Worker and 
pass to the system worker to act as the callback.

Then you can access the various returns
https://developer.4d.com/docs/API/SystemWorkerClass/#4dsystemworkernew
*/

Class constructor($dir : 4D.Folder; $verbose : Boolean)
	
	If (Bool($dir.exists))
		This.currentDirectory:=$dir
	End if 
	
	This.timeout:=30  // seconds
	This._error:=""
	This._data:=""
	This._dataError:=""
	This._dataType:="text"
	This._response:=""
	This._terminated:=""
	
	This._verbose:=Bool($verbose)
	
	//mark:  --- public functions
Function reset
	This._error:=""
	This._dataError:=""
	This._dataType:="text"
	This._data:=""
	This._response:=""
	This._terminated:=""
	
Function onResponse($systemWorker : Object)
	This._response:=$systemWorker.response
	
	//If ($systemWorker.response#"") && (This._verbose)
	//openForm("showMessage"; New object("msg"; "Response: \r\r"+$systemWorker.response))
	//End if 
	
Function onData($systemWorker : Object; $data : Variant)
	This._data+=$data.data
	
Function onDataError($systemWorker : Object; $info : Object)
	This._dataError:=$info.data
	
Function onError($systemWorker_o : Object; $error_o : Object)
	This._error:=This._error+$error_o.data
	
Function onTerminate($systemWorker : Object)
	This._terminated:="Response: "+$systemWorker.response
	This._terminated+="ResponseError: "+$systemWorker.responseError
	
	//If (This._error#"") && (This._verbose)
	//openForm("showMessage"; New object("msg"; "Error: \r\r"+This.error))
	//End if 
	
	//If (This._dataError#"") && (This._verbose)
	//openForm("showMessage"; New object("msg"; "Data Error: \r\r"+This.dataError))
	//End if 
	
	//mark:  --- computed properties
Function get isError : Boolean
	return This._dataError#""
	
Function get data : Variant
	return This._data
	
Function get dataError : Text
	return This._dataError
	
Function get response : Variant
	return This._response
	