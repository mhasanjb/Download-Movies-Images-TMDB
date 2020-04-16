; https://api.themoviedb.org/3/search/movie?api_key=cb57ee66a67aa68b4100a90d9a7821af&language=en-US&query=A Beautiful Mind
; https://www.themoviedb.org/talk/53c11d4ec3a3684cf4006400
; https://image.tmdb.org/t/p/w500/ifn7yLH7W69MdrEEkNzCyO8rTmL.jpg
; https://www.autoitscript.com/forum/topic/191687-get-data-from-json/

#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <Inet.au3>
#include <Json.au3>
#include <StringConstants.au3>
#include <FileConstants.au3>
#include <WinAPIFiles.au3>

; Vars
Global $docURL = "https://api.themoviedb.org/3/search/movie?api_key="
Global $API = ""

getFilesList("C:\Users\Hasan\Desktop\Film" , ".jpg" , "original") ; "w45", "w92", "w154", "w185", "w342", "w500", "w780" , "w780", "w1280" , "original"


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

		; Display a progress bar window.
		ProgressOn("Downloading...", "Downloading Images", "0%")

		$filmName = $aFileList[$i] ; Film name without address ( The Matrix 1999 )
		$filmAddress = $aFileAddress[$i] ; Film name with address ( C:\Desktop\Film\The Matrix 1999 )
		$regFilmName = StringRegExpReplace($filmName, '\d', '') ; Film name without year ( The Matrix )
		$regFilmYear = StringRegExpReplace($filmName, '[^[:digit:]]', '') ; Film name without name  ( 1999 )
		If FileExists( $filmAddress & "\" & $filmName & $fileType ) Then
			ProgressOff()
			MsgBox(0,"File Exist","You Do Not Need To Download This Files" & @CRLF & "Files Exists")
			Return False
		Else
			InetGet( getImage($regFilmName,$regFilmYear , $size), $filmAddress & "\" & $filmName & $fileType) ; Get film poster and put it in folder directory
;~ 			WriteMovieList( $filmName & " ---- " & getImage($regFilmName,$regFilmYear , "w500") ) ; Get Poster And Write Address To "movies.txt"

			; Progress
			For $j = 1 To 100 Step 1
				ProgressSet($j, $j & "%")
			Next
		EndIf

		; Progress
		ProgressSet(100, "", $filmName & " -- Complete")
		Sleep(1000)

		ProgressOff()

	Next


EndFunc   ;==> getFilesList


Func getImage($movieName , $movieYear , $size)

	$URL = $docURL & $API & "&query=" & $movieName & "&year=" & $movieYear
	$data = _INetGetSource($URL)
	$object = json_decode($data)
	$imageURL = "https://image.tmdb.org/t/p/" & $size

	$results = json_get($object, '[results]')
	$i = json_get($results, '[0]')
	$poster = json_get($i, '[poster_path]')
	$finalPoster = $imageURL & $poster
	Return $finalPoster

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


Func regexString()

;~ 	Local $sString = '12345679 Test 987654321'
;~ 	$regString = StringRegExpReplace($sString, '\d', '') ; Just String
;~ 	$regString = StringRegExpReplace($sString, '[^[:digit:]]', '') ; Just Number
;~ 	MsgBox(0,0, $regString)

EndFunc
