//%attributes = {}
/* Purpose: display an alert message
 ------------------
AlertDialog ()
 Created by: Kirk Brooks as Designer, Created: 05/21/25, 14:40:46
*/
#DECLARE($message : Text; $title : Text)

If ($message="") || (Application type=4D Server)
	return 
End if 

$title:=$title || "Alert"

var $window : Integer
$window:=Open form window("Alert_dlog"; Movable form dialog box)

DIALOG("Alert_Dlog"; {message: $message; title: $title})
CLOSE WINDOW($window)

