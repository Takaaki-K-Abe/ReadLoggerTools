#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.


////////////////////////////////////////////////////////////////////////////////
/// @file		Read_ECG_Series.ipf
/// @breif		The tools for reading ECG logger data from raw text data
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
	"ECG-Sereis",/Q, Panel_ReadECGdata()
End

//	================================================================================================
//		Graphical user interface and settings of default parameters
//	================================================================================================

/// @brief		Set default parameters for reading ECG data
/// @param[out]		startDate (global string)
/// @param[out]		startTime (global string)
/// @param[out]		samplingFreqECG (global variable)
Static Function SetDefaultParametersForReadingData()

	string saveDF = GetDataFolder(1)

	if(!DataFolderExists("root:Ethographer"))
		NewDataFolder root:Ethographer
	endif	
	if(!DataFolderExists("root:Ethographer:ReadLoggerData"))
		NewDataFolder root:Ethographer:ReadLoggerData
	endif
	if(!DataFolderExists("root:Ethographer:ReadLoggerData:Parameters"))
		NewDataFolder root:Ethographer:ReadLoggerData:Parameters
	endif
	
	SetDataFolder root:Ethographer:ReadLoggerData:Parameters

	SVAR/Z startDate
	if(!SVAR_Exists(startDate))
		string/G startDate = "2021/01/01"
	endif

	SVAR/Z startTime
	if(!SVAR_Exists(startTime))
		string/G startTime = "00:00:00"
	endif

	NVAR/Z samplingFreqECG
	if(!NVAR_Exists(samplingFreqECG))
		variable/G samplingFreqECG = 250
	endif

	NVAR/Z samplingFreqAccel
	if(!NVAR_Exists(samplingFreqAccel))
		variable/G samplingFreqAccel = 10
	endif

	SetDataFolder saveDF

End


/// @brief		Create a panel for reading logger data
Function Panel_ReadECGdata() : Panel

	SetDefaultParametersForReadingData()
		
	variable Width = 250
	variable Height = 185
	variable Vertical = 56
	variable Horizontal = 703

	variable vertical_pos = 0
	variable vertical_spacing = 21
	string PathOfVariables = "root:Ethographer:ReadLoggerData:Parameters:"
	
	DoWindow ReadLoggerMenu
	if(V_flag == 1)
		DoWindow/K ReadLoggerMenu
	endif
	
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1/W=(Horizontal,Vertical,Horizontal + Width,Vertical + Height )/K=1
	DoWindow/C ReadLoggerMenu
	
	// title 
	vertical_pos += 9
	TitleBox title_ParamSet, pos={30, vertical_pos},size={116,14},title="\\f01Read Logger data"
	TitleBox title_ParamSet, fSize=14,frame=0

	// Profiles
	vertical_pos += 25
	GroupBox group_parameters, frame = 0, title = "\Z11Parameters"
	GroupBox group_parameters, pos = {13, vertical_pos}, size = {220, 5*vertical_Spacing}

	vertical_pos += vertical_spacing
	SetVariable startDate, title = "Start Date", pos = {25, vertical_pos}, size = {137, 30}
	SetVariable startDate, limits = {-90,90,0.1}, value = $( pathOfVariables+"startDate" )
	
	vertical_pos += vertical_spacing
	SetVariable startTime, title = "Start Time", pos = {25, vertical_pos}, size = {137, 30}
	SetVariable startTime, limits = {-180,180,0.1}, value = $( pathOfVariables+"startTime" )
	
	vertical_pos += vertical_spacing
	SetVariable samplingFreqECG, title = "ECG Sampling Frequency (Hz)", pos = {25, vertical_pos}, size = {200, 30}
	SetVariable samplingFreqECG, limits = {-12,12,1}, value = $( pathOfVariables+"samplingFreqECG" )

	vertical_pos += vertical_spacing
	SetVariable samplingFreqAccel, title = "Accel Sampling Frequency (Hz)", pos = {25, vertical_pos}, size = {200, 30}
	SetVariable samplingFreqAccel, limits = {-12,12,1}, value = $( pathOfVariables+"samplingFreqAccel" )
	
	vertical_pos += vertical_spacing + 13
	Button button_StartCalc, title="Start to read ECG logger", proc = Button_Launch_ReadECG
	Button button_StartCalc, pos = {25, vertical_pos}, size={180, 20}
	
End

/// @brief		Proc of button_StartCalc in Panel_CalculateSolarAltitude_Moving()
Function Button_Launch_ReadECG(ctrlName)
	
	string ctrlName
	Read_ECG_Logger()
	
	DoWindow ReadLoggerMenu
	if(V_flag == 1)
		DoWindow/K ReadLoggerMenu
	endif

End

//	================================================================================================
//		Core functions for reading ECG data
//	================================================================================================


/// @brief		Select multi text
/// @return		S_filename (string): the paths of text data
Static Function/S ReturnSelectedFilePaths()

	Variable refNum
	String message = "Select one or more files"
	String outputPaths
	String fileFilters = "Data Files (*.txt,*.dat,*.csv):.txt,.dat,.csv;"

	fileFilters += "All Files:.*;"

	Open /D /R /MULT=1 /F=fileFilters /M=message refNum

	return S_fileName

End


/// @brief		Select raw text data files and read ECG400-DT data
/// @param[in]	S_filemane (string): 
/// @param[out]	ECG (wave): 
/// @param[out]	Depth (wave): 
/// @param[out]	Temperature (wave): 
/// @param[out]	GX (wave): 
/// @param[out]	GY (wave): 
/// @param[out]	GZ (wave): 
Function Read_ECG_Logger()

	string saveDF = GetDataFolder(1)
	
	if( DataFolderExists("root:Ethographer") )
		SetDataFolder "root:Ethographer"
	Else
		NewDataFolder/O/S root:Ethographer
	Endif
	
	if( DataFolderExists("ReadLoggerData") )
		SetDataFolder ReadLoggerData
	Else
		NewDataFolder/S ReadLoggerData
	Endif

	//! Read raw logger data paths
	string Paths = ReturnSelectedFilePaths()
	
	if (strlen(Paths) == 0)
		Print "Cancelled"
	else
		Variable numFiles = ItemsInList(Paths, "\r")
		variable index
			for(index = 0; index < numFiles; index += 1)

				string path = StringFromList(index, Paths, "\r")
				string dataType = ExtractDataType(path)
				
				If(StringMatch(datatype "G*"))
					print dataType
					string columnInfoStr = "N=" + dataType + ";"
					LoadWave/Q /G /N /W /B=columnInfoStr path
				else
					LoadWave/Q /G /N /W /L={0, 1, 0, 0, 1} path
				Endif

			endfor
	endif


	//! concatenate waves and set scaling
	string ECGDT_DataLabelList = "ECG*;ONDO*;SUISIN*;GX*;GY*;GZ*;"	
	string ECGDT_DataTypeList = "ECG;Temperature;Depth;GX;GY;GZ;"
	
	variable startDateTimeSecs = ReturnStartDateTimeSecs()
	variable samplingIntervalECG = ReturnECGIntervalFromFrequency()
	variable samplingIntervalAccel = ReturnAccelIntervalFromFrequency()
	variable samplingInterval

	string theDataLabel, theDataType

	for(index = 0; index < ItemsInList(ECGDT_DataLabelList); index += 1 )

		//! get wave name from list
		theDataLabel = StringFromList(index, ECGDT_DataLabelList)
		string waveListStr = wavelist(theDataLabel,";","")

		if( strlen(waveListStr) > 1 )
			
			theDataType = StringFromList(index, ECGDT_DataTypeList)
			
			//!  Waves are concatenated per each parameter
			Concatenate_ECG_LoggerData(theDataType)
			Wave ReturnData = $theDataType

			// PrintWaveDuration($theDataType, samplingIntervalECG)				

			StrSwitch(theDataType)
				case "Temperature":
					samplingInterval = 1
					Break
				case "Depth":
					samplingInterval = 1
					Break
				case "ECG":
					samplingInterval = samplingIntervalECG
					Break
				case "GX":
					samplingInterval = samplingIntervalAccel
					Break
				case "GY":
					samplingInterval = samplingIntervalAccel
					Break
				case "GZ":
					samplingInterval = samplingIntervalAccel
					Break
			EndSwitch
				
			SetScale/P x startDateTimeSecs, samplingInterval, "dat", ReturnData
			
			MoveWaveToSaveDataFolder(saveDF, ReturnData)
		endif

	endfor
	
	Killwaves/A/Z
	SetDataFolder saveDF

end

/// @brief		Extract accel data type from filepath
/// @param[in]	filePath(string):	
/// @return		AccelType(string): 
Static Function/T ExtractDataType(filePath)

	string filePath

	string fileName = filePath[strsearch(filePath, ":", inf, 3)+1, inf]
	string dataType = filename[0, strsearch(fileName, ".csv", inf, 3)-1]

	return dataType
End

/// @brief		Extract accel data type from filepath
/// @param[in]	dataType(string): data type of wave to be connected
/// @param[out]	$dataType(wave): concatenated wave
Function Concatenate_ECG_LoggerData(dataType)

	string dataType
	string waveNameStr, searchStr

	StrSwitch(dataType)
		case "Temperature":
			searchStr = "ONDO*"
			Break
		case "Depth":
			searchStr = "SUISIN*"
			Break
		case "ECG":
			searchStr = "ECG*"
			Break
		case "GX":
			searchStr = "GX*"
			Break
		case "GY":
			searchStr = "GY*"
			Break
		case "GZ":
			searchStr = "GZ*"
			Break
	EndSwitch

	//! Create wavelist for reading
	string waveListStr = wavelist(searchStr,";","")
	
	if(strlen(waveListStr) < 1)
		Return 0
	endif

	Concatenate/NP=0 waveliststr, $dataType
	
end


/// @brief		SetDateTime2Wave
/// @param		
/// @return	
Static Function PrintWaveDuration(theData, interval)
	
	wave theData
	variable interval
	
	variable duration = numpnts(theData)*interval
	
	printf "Length of %s data; %s\r", NameofWave(theData), Secs2Time(duration, 5)

end


/// @brief		SetDateTime2Wave
/// @param		
/// @return	
Static Function ReturnStartDateTimeSecs()

	string pathofVariables = "root:Ethographer:ReadLoggerData:Parameters:"
	SVAR startDate = $( pathOfVariables + "startDate")
	SVAR startTime = $( pathOfVariables + "startTime")

	variable year, month, day
	sscanf startDate, "%d/%d/%d", year, month, day
	
	variable hh, mm, ss
	sscanf startTime, "%d:%d:%d", hh, mm, ss

	variable startDateTimeSecs = Date2Secs(year, month, day) + 3600*hh + 60*mm + ss
	
	return startDateTimeSecs

End

/// @brief		return sampling interval from samplingFreqECG(NVAR)	
/// @return		samplingIntervalECG (variable)
Static Function ReturnAccelIntervalFromFrequency()

	string pathofVariables = "root:Ethographer:ReadLoggerData:Parameters:"
	NVAR samplingFreqAccel = $( pathOfVariables + "samplingFreqAccel")

	variable samplingIntervalAccel = 1 / samplingFreqAccel
	return samplingIntervalAccel

End


/// @brief		return sampling interval from samplingFreqECG(NVAR)	
/// @return		samplingIntervalECG (variable)
Static Function ReturnECGIntervalFromFrequency()

	string pathofVariables = "root:Ethographer:ReadLoggerData:Parameters:"
	NVAR samplingFreqECG = $( pathOfVariables + "samplingFreqECG")

	variable samplingIntervalECG = 1 / samplingFreqECG
	return samplingIntervalECG

End



Static Function/S ReturnWaveList(dataLabel)

	string dataLabel
	string waveListStr = wavelist(dataLabel, ";", "")
	return waveListStr

end



Static Function MoveWaveToSaveDataFolder(saveDF, targetWave)

	string saveDF
	wave targetWave
	string dataPath = saveDF + NameOfWave(targetWave)
	
	if(waveExists($dataPath))
		print "the data was overwrited"
	endif

	duplicate/O targetWave $dataPath

end



