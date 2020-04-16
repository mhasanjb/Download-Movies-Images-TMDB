#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <Inet.au3>
#include <Json.au3>
#include <StringConstants.au3>
#include <FileConstants.au3>
#include <WinAPIFiles.au3>

#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#Region ### START Koda GUI section ### Form=C:\- App -\Autoit\Get Film Image\GUI\Form_FilmImages.kxf
$Form_FilmImages = GUICreate("Get Film Images", 602, 148, -1, -1)
$FolderGroup = GUICtrlCreateGroup("Folder", 8, 8, 585, 121)
$Input_Folder = GUICtrlCreateInput("Insert Your Movies Folder", 24, 40, 553, 21)
$Button_Download = GUICtrlCreateButton("Download", 376, 80, 75, 25)
$Combo_Type = GUICtrlCreateCombo("", 24, 80, 73, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, ".jpg|.jpeg|.png|.bmp", ".jpg")
$Combo_Quality = GUICtrlCreateCombo("", 120, 80, 145, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "original|w1280|w780|w780|w600_and_h900_bestv2|w500|w342|w185|w154|w92|w45", "original")
$Button_Config = GUICtrlCreateButton("Config", 504, 80, 75, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

; Vars
Global $cFilePath = @TempDir & "\GetFilmImage-config.ini"
Global $docURL = "https://api.themoviedb.org/3/search/movie?api_key="
Global $API = IniRead($cFilePath, "API", "Key", "Default Value")

If FileExists($cFilePath) = False Then
	createIniFile() ; Create config.ini
EndIf

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

		Case $Button_Download
			downloadImage()

		Case $Button_Config
			ShellExecute($cFilePath)

	EndSwitch
WEnd


Func downloadImage()

	$folder = GUICtrlRead($Input_Folder)
	$type = GUICtrlRead($Combo_Type)
	$quality = GUICtrlRead($Combo_Quality)

	getFilesList($folder , $type , $quality)

EndFunc


Func getFilesList($dir , $fileType , $size)

    ; List all the files and folders
    Local $aFileList = _FileListToArray($dir, "*")
    Local $aFileAddress = _FileListToArray($dir, Default,Default,True)

	; Error Handler
    If @error = 1 Then
        MsgBox($MB_SYSTEMMODAL, "", "Path was invalid.")
        Exit
    EndIf
    If @error = 4 Then
        MsgBox($MB_SYSTEMMODAL, "", "No file(s) were found.")
        Exit
    EndIf


	$maxArray = UBound($aFileList, 1) ; Get Total Arrays
	For $i = 1 To $maxArray Step 1
		$filmName = $aFileList[$i] ; Film name without address ( The Matrix 1999 )
		$filmAddress = $aFileAddress[$i] ; Film name with address ( C:\Desktop\Film\The Matrix 1999 )
		$regFilmName = StringRegExpReplace($filmName, '\d', '') ; Film name without year ( The Matrix )
		$regFilmYear = StringRegExpReplace($filmName, '[^[:digit:]]', '') ; Film name without name  ( 1999 )

		If FileExists( $filmAddress & "\" & $filmName & " - " & $size & $fileType ) Then
			ProgressOff()
		Else
			; Display a progress bar window.
			ProgressOn("Downloading...", "Downloading Images", "0%" , "" , "" , 16)

			 ; Get film poster and put it in folder directory
			InetGet( getImage($regFilmName,$regFilmYear , $size), $filmAddress & "\" & $filmName & " - " & $size & $fileType)

			; Get Poster And Write Address To "movies.txt"
;~ 			WriteMovieList( $filmName & " ---- " & getImage($regFilmName,$regFilmYear , "w500") )

			; Progress
			For $j = 1 To 100 Step 1
				ProgressSet($j, $j & "%")
			Next
		EndIf

		; Progress
		ProgressSet(100, "", $filmName & " -- Complete")
		Sleep(150)

		ProgressOff()

	Next


EndFunc   ;==> getFilesList


Func getImage($movieName , $movieYear , $size)

	If $API = "YOUR_API_HERE" Then
		MsgBox(0,"API Key Required","You need a API key from TMDB website")
	Else
		$URL = $docURL & $API & "&query=" & $movieName & "&year=" & $movieYear
		$data = _INetGetSource($URL)
		$object = json_decode($data)
		$imageURL = "https://image.tmdb.org/t/p/" & $size

		$results = json_get($object, '[results]')
		$i = json_get($results, '[0]')
		$poster = json_get($i, '[poster_path]')
		$finalPoster = $imageURL & $poster
		Return $finalPoster
	EndIf

EndFunc


Func WriteMovieList($data)

    ; Create a File
    Local Const $sFilePath = @DesktopDir & "\movies.txt"

    ; Open File (append)
    Local $hFileOpen = FileOpen($sFilePath, $FO_APPEND)

    ; Write Data
    FileWrite($hFileOpen, $data & @CRLF)

    ; Close File
    FileClose($hFileOpen)

EndFunc   ;==> WriteMovieList


Func createIniFile()

	MsgBox(0,"API Key Required","You need a API key from TMDB website")
	IniWrite ($cFilePath , "API" , "Key", "Your_API_HERE")

EndFunc


Func regexString()

;~ 	Local $sString = '12345679 Test 987654321'
;~ 	$regString = StringRegExpReplace($sString, '\d', '') ; Just String
;~ 	$regString = StringRegExpReplace($sString, '[^[:digit:]]', '') ; Just Number
;~ 	MsgBox(0,0, $regString)

EndFunc
