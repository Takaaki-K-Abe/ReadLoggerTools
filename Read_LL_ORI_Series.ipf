#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

////////////////////////////////////////////////////////////////////////////////
/// @file		Read_ORI_Series.ipf
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


//	================================================================================================
//										About proceadures for header
//	================================================================================================

STRUCTURE ParamReadORISTRUCT
	variable startDateTime
	variable samplingInterval
EndStructure

/// @brief          
/// @param[in]      
/// @param[out]     
/// @return         
Function Read_ORI_LoggerHeader([fileName])

	string fileName

	string saveDF = GetDataFolder(1)
		NewDataFolder/O/S root:Ethographer
	
	if( DataFolderExists("LoadLoggerData") )
		SetDataFolder LoadLoggerData
	Else
		NewDataFolder/S LoadLoggerData
	Endif

	killvariables/A/Z
	killstrings/A/Z
	killwaves/A/Z

	if(ParamIsDefault(FileName))
		LoadWave/J/A=WvInfo/K=2/L={0, 0, 10, 0, 0}
	Else
		FileName = ParseFilePath(5, FileName, "*", 0, 0)
		LoadWave/J/A=WvInfo/K=2/L={0, 0, 10, 0, 0} FileName
	Endif	

	string/G loggerFilePath = S_path
	string/G loggerFileName = S_filename

	If(StrLen(S_filename) == 0)
		SetDataFolder savDF
		return 0
	Endif

	//! start date and time
	string startDate = FindValueFromLoggerHeader("*START DATE*")
	string startTime = FindValueFromLoggerHeader("*START TIME*")

	variable startDateTime = ReturnDateTimeFromString(startDate, startTime)

	//! sampling Interval
	string samplingIntervalString = FindValueFromLoggerHeader("*sec/point*")
	variable samplingInterval
	sscanf samplingIntervalString,  "%d", samplingInterval
		if( stringMatch( samplingIntervalString, "*msec/point*" ) )
			samplingInterval /= 1000
		endif
	
	STRUCT ParamReadORISTRUCT LoadParameters
		LoadParameters.startDateTime 		= startDateTime
		LoadParameters.samplingInterval 	= samplingInterval

	if( !WaveExists($"ParameterForLoad") )
		make/O $"ParameterForLoad"
	endif

	wave ParameterStructure = $"ParameterForLoad"

	StructPut LoadParameters ParameterStructure

	SetDataFolder saveDF

End

/// @brief		Find the value of parameter from logger header
/// @param[in]	parameterType (string): parameter type
/// @param[in]	WvInfo0 (wave): text wave created from logger header (first column), where parameter types are stored
/// @return		parameterValue (string): parameter value
Static Function/S FindValueFromLoggerHeader(parameterType)
	
	String parameterType

	Wave/T WvInfo0
	Variable rowID
	
	For(rowID = 0; rowID <= 9; rowID += 1)
		If(stringMatch(WvInfo0[rowID], parameterType))
			string paramValue = WvInfo0[rowID]
			print paramValue
			Break
		Elseif(rowID >= 9)
			return ""
		Endif
	EndFor
	
	Return paramValue
End

/// @brief		Return datetime seconds from date and time strings
/// @param		dateString (string): string of date (e.g. "2022/01/01")
/// @param		timeString (string): string of time (e.g. "00:11:22")
/// @return		datetimeSeconds (variable): number of seconds for a given date from the system default start date and time
Static Function ReturnDateTimeFromString(dateString, timeString)

	string dateString, timeString
	
	variable dVal1, dVal2, dVal3
	sscanf dateString, "START DATE %d/%d/%d", dVal1, dVal2, dVal3

	If(dVal1 == 0 | dVal2 == 0 | dVal3 == 0)
		dVal1 = 2000
		dVal2 = 1
		dVal3 = 1
	Endif

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
	sscanf timeString, "START TIME %d:%d:%d", hh, mm, ss

	variable timeSeconds = 60*60*hh + 60*mm + ss

	variable datetimeSeconds = dateSeconds + timeSeconds
	
	Return datetimeSeconds
End


/// @brief          
/// @param[in]      
/// @return         
Function Load_ORI_LoggerAccelData([dataFolderPath])

	string dataFolderPath
	
	if(!ParamIsDefault(dataFolderPath))
		if( DataFolderExists(dataFolderPath) )
			setDataFolder dataFolderPath
		Else
			NewDataFolder/S dataFolderPath
		Endif	
	Endif

	Read_ORI_LoggerHeader()

	STRUCT ParamReadORISTRUCT Parameters
	StructGet Parameters $"root:Ethographer:LoadLoggerData:ParameterForLoad"
	
	variable startDaT = Parameters.startDateTime
	variable interval = Parameters.samplingInterval
	SVAR fileDir = root:Ethographer:LoadLoggerData:loggerFilePath
	SVAR fileName = root:Ethographer:LoadLoggerData:loggerFileName
	string filePath = fileDir + fileName
	print filePath

	variable dataStartRow =  6
	variable dataLabelRow =  dataStartRow - 1

	string columnInfoStr = ""
	columnInfoStr += "C=1,T=4,F=0,W=20,N=Xaccel;"
	columnInfoStr += "C=1,T=4,F=0,W=20,N=Yaccel;"
	columnInfoStr += "C=1,T=4,F=0,W=20,N=Zaccel;"

	LoadWave/G/A/Q/D/B=columnInfoStr/L={dataLabelRow, dataStartRow, 0, 0, 0} filePath

	wave Xaccel, Yaccel, Zaccel
	SetScale/P x startDaT, interval, "dat", Xaccel, Yaccel, Zaccel

End

/// @brief          
/// @param[in]      
/// @return         
Function Load_ORI_PD3GTC_OtherData([dataFolderPath])

	string dataFolderPath
	
	if(!ParamIsDefault(dataFolderPath))
		if( DataFolderExists(dataFolderPath) )
			setDataFolder dataFolderPath
		Else
			NewDataFolder/S dataFolderPath
		Endif	
	Endif

	Read_ORI_LoggerHeader()

	STRUCT ParamReadORISTRUCT Parameters
	StructGet Parameters $"root:Ethographer:LoadLoggerData:ParameterForLoad"
	
	variable startDaT = Parameters.startDateTime
	variable interval = Parameters.samplingInterval
	print "interval: " + num2str(interval)
	SVAR fileDir = root:Ethographer:LoadLoggerData:loggerFilePath
	SVAR fileName = root:Ethographer:LoadLoggerData:loggerFileName
	string filePath = fileDir + fileName
	print filePath

	variable dataStartRow =  7
	variable dataLabelRow =  dataStartRow - 1
	variable ncol = 4

	string columnInfoStr = ""
	columnInfoStr += "C=1,T=4,F=0,W=20,N=Depth;"
	columnInfoStr += "C=1,T=4,F=0,W=20,N=Temp;"
	columnInfoStr += "C=1,T=4,F=0,W=20,N=Speed;"
	columnInfoStr += "C=1,T=4,F=0,W=20,N=Salinity;"

	LoadWave/G/A/Q/D/B=columnInfoStr/L={dataLabelRow, dataStartRow, 0, 0, ncol} filePath

	wave Depth, Temp, Speed, Salinity
	SetScale/P x startDaT, interval, "dat", Depth, Temp, Speed, Salinity

End