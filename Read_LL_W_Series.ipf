#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

////////////////////////////////////////////////////////////////////////////////
/// @file		Read_W_Series.ipf
/// @breif		The tools for reading W-series logger data from raw text data
/// @author		Takaaki K. Abe (E-mail: t.abe.hpa@gmail.com)
/// @date		
/// Version:	1.0
/// Revision:	0
/// @note		
/// 
/// @attention	The author takes no responsibility for its use or misuse. 
///				Copies of this code should be distributed with their original identification headers.
///				Any code derived from this code should not be sold for commercial purposes.
///				Please cite the use of this code whenever possible.
///
////////////////////////////////////////////////////////////////////////////////

Menu "Read Logger Data"
	"W series",/Q, Read_W_Series_LoggerData() 
End

//	================================================================================================
//		About proceadures for header
//	================================================================================================

Function Read_W_Series_LoggerData() ///abe edit

	Variable refNum
	String message = "Select one or more files"
	String outputPaths
	String fileFilters = "Data Files (*.txt,*.dat,*.csv):.txt,.dat,.csv;"

	fileFilters += "All Files:.*;"

	Open /D /R /MULT=1 /F=fileFilters /M=message refNum
	string Paths = S_fileName
	
	if (strlen(Paths) == 0)
		Print "Cancelled"
	else
		Variable numFiles = ItemsInList(Paths, "\r")
		variable i
			for(i=0; i<numFiles; i+=1)
				string path = StringFromList(i, Paths, "\r")
				Read_W_Logger(FileName = path)
			endfor
	endif
end

/// @brief		W seriesのヘッダーに描かれたロガーデータの情報のうち、指定した情報を抜き出す。
///				ヘッダーの情報はWvInfo0とWvInfo1に格納されている。
/// @param		descriptionOfData (string): 読み取るデータの種類
/// @return		Output (string): 読み取った情報 
function Read_W_Logger([FileName])
	String FileName
	
	string savDF = GetDataFolder(1)
		NewDataFolder/O/S root:Ethographer
		
		if(DataFolderExists("ReadLoggerData"))
			SetDataFolder ReadLoggerData
		Else
			NewDataFolder/S ReadLoggerData
		Endif
		killvariables/A/Z
		killstrings/A/Z
		killwaves/A/Z
			
	if(ParamIsDefault(FileName))
		LoadWave/J/Q/A=WvInfo/K=2/L={0, 0, 10, 0, 0}
	Else
		FileName = ParseFilePath(5, FileName, "*", 0, 0)
		LoadWave/J/Q/A=WvInfo/K=2/L={0, 0, 10, 0, 0} FileName
	Endif	
	
	if(StrLen(S_filename) == 0)
		SetDataFolder savDF
		return 0
	Endif
	
	wave/T WvInfo0, WvInfo1
	variable DataID
	
	String FileType = FindValueFromLoggerDataHeader("Channel:")
	// print FileType
	String startDate = FindValueFromLoggerDataHeader("Start date:")
	// print StartDate
	String startTime = FindValueFromLoggerDataHeader("Start time:")
	// print StartTime
	String IntervalStr = FindValueFromLoggerDataHeader("Interval(Sec):")
	// print IntervalStr

	if(StrLen(FileType) == 0 || StrLen(StartDate) == 0 || StrLen(StartTime) == 0 || StrLen(IntervalStr) == 0)
		print "//   Error."
	Endif

	killwaves WvInfo0, WvInfo1
	
	String FileWithPath = S_Path + S_FileName
	FileName = FileWithPath
	
	LoadWave/G/Q/D/A=EthographerTempWv/L={0, 0, 0, 0, 0} FileWithPath

	SetDataFolder savDF
	//	---------------------------------------------------	

	String WvName = DefineWaveName(FileType)
		duplicate/O root:Ethographer:ReadLoggerData:EthographerTempWv0, $WvName

	Printf "\r %s was created\r", wvName

	variable startDatetime = ReturnDateTimeFromString(startDate, startTime)
	
	variable Interval = str2num(IntervalStr)
	
	SetScale/P x, startDatetime, Interval, "dat", $WvName
	Note $WvName, FileName
	killDataFolder root:Ethographer:ReadLoggerData
	
	print "Read_W_Logger(FileName = \"" + FileName + "\")"
End

/// @brief		W seriesのヘッダーに描かれたロガーデータの情報のうち、指定した情報を抜き出す。
///				ヘッダーの情報はWvInfo0とWvInfo1に格納されている。
/// @param		descriptionOfData (string): 読み取るデータの種類
/// @return		Output (string): 読み取った情報 
static Function/S FindValueFromLoggerDataHeader(descriptionOfData)
	String descriptionOfData

	wave/T WvInfo0, WvInfo1
	variable DataID
	// print descriptionOfData
	
	For(DataID = 0; DataID <= 9; DataID += 1)
			// print DataID
			// print WvInfo0[DataID]
			// print stringMatch(WvInfo0[DataID], descriptionOfData)
		If(stringMatch(WvInfo0[DataID], descriptionOfData))
			String Output = WvInfo1[DataID]
			Output = ReplaceString("\"", Output, "")
			Output = ReplaceString(" ", Output, "") 	
			Break
		Elseif(DataID >= 9)
			return ""
		Endif
	EndFor
	
	Return Output
End

/// @brief		
/// @param		
/// @return		
static Function/S DefineWaveName(FileType)
	string FileType
	String WvName
	
	StrSwitch(FileType)
		case "Temperature":
			WvName = "Temp"
			Break
		case "Depth":
			WvName = "Depth"
			Break
		case "Acceleration-X":
			WvName = "XG"
			Break
		case "Acceleration-Y":
			WvName = "YG"
			Break
		case "Acceleration-Z":
			WvName = "ZG"
			Break
		case "Compass-X":
			WvName = "XM"
			Break	
		case "Compass-Y":
			WvName = "YM"
			Break	
		case "Compass-Z":
			WvName = "ZM"
			Break	
		case "Propeller":
			WvName = "Pera"
			Break
		default:
			WvName = FileType
			Break
	EndSwitch
	
	string Output = MakeManyNameForLoad(WvName)
	
	Return Output
End

/// @brief		重複する名前のウェーブがあったときに連番をつけて新しい名前を返す
/// @param		wvName (string): 元ウェーブ名
/// @return		renameWaveName (string): 新しいwave名
/// @example	MakeManyNameForLoad(wvName)
Static Function/S MakeManyNameForLoad(wvName)
	string wvName
	variable Number = 0
	String renamedWaveName
	
	if(waveExists($wvName))
		do
			Number += 1
			renamedWaveName = wvName + num2istr(Number)
		while(WaveExists($renamedWaveName))
	Else
		renamedWaveName = wvName
	Endif
		
	Return renamedWaveName
end

/// @brief		日付と時間の文字列からIgor timeを返す
/// @param		dateString (string): 日付の文字列 (e.g. "2022/01/01")
/// @param		timeString (string): 時間の文字列 (e.g. "00:11:22")
/// @return		datetimeSeconds (variable):　Igor time
/// @example	
///	variable datetimeSeconds = ReturnDateTimeFromString(dateString, timeString)
static Function ReturnDateTimeFromString(dateString, timeString)

	string dateString, timeString
	
	variable dVal1, dVal2, dVal3
	sscanf dateString, "%d/%d/%d", dVal1, dVal2, dVal3	

	variable year, month, day
	if( dVal3 > 1000 )
		year = dVal3
		month = dVal1
		day = dVal2
	else
		year = dVal1
		month = dVal2
		day = dVal3
	endif

	variable dateSeconds = Date2Secs(year, month, day)

	variable hh, mm, ss
	sscanf timeString, "%d:%d:%d", hh, mm, ss

	variable timeSeconds = 60*60*hh + 60*mm + ss

	variable datetimeSeconds = dateSeconds + timeSeconds
	
	Return datetimeSeconds
End