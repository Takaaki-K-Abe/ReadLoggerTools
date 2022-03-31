#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

////////////////////////////////////////////////////////////////////////////////
/// @file		Read_LAT_Series.ipf
/// @breif		Read ORI series logger tools
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
	"LAT, Lotek",/Q, Read_LAT() 
End

//	================================================================================================
//										About proceadures for header
//	================================================================================================



/// @brief          Read LAT data
/// @param[in]      fileName
/// @param[out]     ExtTemp (wave)
/// @param[out]     IntTemp (wave)
/// @param[out]     Pressure (wave)
/// @param[out]     Light (wave)
/// @param[out]     DimFlag (wave)
Function Read_LAT([fileName, newDF])

	string fileName, newDF
	
	variable moveWaveTF = 0
	string saveDF = GetDataFolder(1)

	If(ParamIsDefault(newDF))
		newDF = "ReadLogger"
		movewaveTF = 1
	Endif

	if( DataFolderExists(newDF) )
		SetDataFolder newDF
		killvariables/A/Z
		killstrings/A/Z
		killwaves/A/Z
	Else
		NewDataFolder/S $newDF
	Endif

	string columnInfoStr = ""
	columnInfoStr += "N='_skip_';"
	columnInfoStr += "F=-2, N=DateWv;"
	columnInfoStr += "F=-1, N=TimeWv;"
	columnInfoStr += "N=ExtTemp;"
	columnInfoStr += "N=IntTemp;"
	columnInfoStr += "N=Pressure;"
	columnInfoStr += "N=Light;"
	columnInfoStr += "N=DimFlag;"
	
	LoadWave/J/Q/K=0/L={0, 1, 0, 0, 8}/B=columnInfoStr/O/A

	wave/T DateWv = $"Datewv"
	wave TimeWv = $"TimeWv"

	wave DateTimeWave = CreateDateTimeWave(DateWv, TimeWv)
	Duplicate/O DateTimeWave DaTDiff
	Differentiate/METH=1 DaTDiff
	Variable TimeDelta = mean(DaTDiff)

	String readDataList = "ExtTemp;IntTemp;Pressure;Light;DimFlag"
	
	/// Wave scaling
	variable dataID
	Do
		String dataType = StringFromList(dataID, readDataList)
		wave Data = $dataType
		MakeWaveByTime(DateTimeWave, DateTimeWave, ValueWave=Data, mName=dataType, Delta=TimeDelta)

		If(moveWaveTF == 1)	
			MoveWaveToSaveDataFolder(saveDF, Data)
		Endif 

		If(strlen(dataType) <= 0)
			Break
		Endif
		dataID += 1
	While(1)
	// MakeWaveByTime(DateTimeWave, DateTimeWave, ValueWave=ExtTemp, mName="ExtTemp", Delta=TimeDelta)
 	// MakeWaveByTime(DateTimeWave, DateTimeWave, ValueWave=Temp, mName="Temp", Delta=1)

	 SetDataFolder saveDF

End Function

////////////////////////////////////////////////////////////////////////////////
/// @brief		Create Date and Time wave (DateTimeWave) from date string wave and time wave
/// @param		DateStrWave (Text wave): 
/// @param		TimeWave (wave): 
////////////////////////////////////////////////////////////////////////////////
Static Function/WAVE CreateDateTimeWave(DateStrWave, TimeWave)
	wave/T DateStrWave
	wave TimeWave
	
	Make/FREE /D /O /N=(numpnts(DateStrWave)) DateTimeWave
	// Duplicate/O timewave DateTimeWave
	Variable i
	for(i = 0 ; i < numpnts(TimeWave); i += 1)
		String dateStr = DateStrWave[i]
		DateTimeWave[i] = ReturnStartDateSecs(dateStr)	
	endfor
	
	DateTimeWave += timewave
	Return DateTimeWave
END

////////////////////////////////////////////////////////////////////////////////
/// @brief		Return Date and Time wave from date string wave and time wave
/// @param[in]	dateStr (string)	
/// @return		dateSecs (variable)
////////////////////////////////////////////////////////////////////////////////
Static Function ReturnStartDateSecs(dateStr)

	string dateStr

	variable ymd1, ymd2, ymd3
	sscanf dateStr, "%d/%d/%d", ymd1, ymd2, ymd3

	variable dateSecs
	if(strlen(num2str(ymd1)) >= 3)
		dateSecs = Date2Secs(ymd1, ymd2, ymd3)
	elseif(strlen(num2str(ymd1)) <= 2)
		dateSecs = Date2Secs(ymd3, ymd1, ymd2)
	endif
	
	return dateSecs

End

////////////////////////////////////////////////////////////////////////////////
/// @brief		move a wave to a data floder
/// @param		dataFolderStr (string)
/// @param		targetWave (wave)
////////////////////////////////////////////////////////////////////////////////
Static Function MoveWaveToSaveDataFolder(dataFolderStr, targetWave, [overWrite])

	string dataFolderStr
	wave targetWave
	variable overWrite 
	string dataPath = dataFolderStr + NameOfWave(targetWave)
	
	If(ParamIsDefault(overWrite))
		overWrite = 1
	Endif

	If(!waveExists($dataPath))
		Duplicate/O targetWave $dataPath

	Elseif(waveExists($dataPath))
		If(overWrite == 1)
			print "the data was overwrited"
			Duplicate/O targetWave $dataPath

		Elseif(overWrite == 0)
			Variable number = 1
			Do
				String newDataPath
				Sprintf newDataPath "%s_%d" number

				If(!waveExists($newDataPath))
					Duplicate/O targetWave $newDataPath
					Break
				Endif
				number += 1
			While(1)
		Endif
	Endif

End