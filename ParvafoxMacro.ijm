/*
 * Macro template to process multiple images in a folder
 */
 
run("Collect Garbage");

//get input variables
#@ File (label = "Input directory", style = "directory") input
//#@ File (label = "Output directory", style = "directory") output
#@ String (label = "cFos suffix", value = "ch03.tif") cFos_Suffix
#@ String (label = "DREADD suffix", value = "ch02.tif") DREADD_Suffix
#@ Float (label="DownScaleFactor for Montage", style="slider", min=0, max=1, stepSize=0.25, value = 1, persist = false) DownScaleFactor
#@ Integer (label = "Min DREADD", value = 100, persist = false) MinDREADD
#@ Integer (label = "Max DREADD", value = 4500, persist = false) MaxDREADD
#@ Integer (label = "Min cFos", value = 500, persist = false) MincFos
#@ Integer (label = "Max cFos", value = 6500, persist = false) MaxcFos


//run the bio-formats extension macro to later extract pixel size
run("Bio-Formats Macro Extensions");

// define DateTime
getDateAndTime(year, month, week, day, hour, min, sec, msec);
DateTime = "" + year + "-" + month+1 + "-" + day + "_" + hour + "-" + min + "-" + sec;

//create ouput directory automatically
output = input + File.separator + DateTime + "_Processed_magenta" + MinDREADD + "-" + MaxDREADD + "_green" + MincFos + "-" + MaxcFos + "_ScaleFact" + DownScaleFactor;
File.makeDirectory(output);

//create and save Parameter file
f = File.open(output + File.separator + DateTime + "_parameters.txt");
print(f, DateTime + "\n");
print(f, "Contrast Limits Magenta Channel = " + MinDREADD + "-" + MaxDREADD + "\n");
print(f, "Contrast Limits Green Channel = " + MincFos + "-" + MaxcFos + "\n");
print(f, "DownScaleFactor for Montage = " + DownScaleFactor + "\n\n");
File.close(f);

// Do the processing here by adding your own code.
// Leave the print statements until things work, then remove them.
setBatchMode(false);
list = getFileList(input);
list = Array.sort(list);
for (i = 0; i < list.length; i++) {
		if(endsWith(list[i], cFos_Suffix))
			cFos = input + File.separator + list[i];
		if(endsWith(list[i], DREADD_Suffix))
			DREADD = input + File.separator + list[i];
	}
			
open(cFos);
rename("cFos");
setMinAndMax(MincFos, MaxcFos);

// extract pixel size information
Ext.setId(cFos);
Ext.getPixelsPhysicalSizeX(sizeX)
run("Set Scale...", "distance=1 known=" + sizeX + " unit=micron");

open(DREADD);
rename("DREADD");
setMinAndMax(MinDREADD, MaxDREADD);

run("Merge Channels...", "c2=cFos c6=DREADD create");
run("Rotate 90 Degrees Right");

makeRectangle(0, 0, 5552, 1920); // try interactive prompt to make hypothalamus ROI
//setBatchMode("show");
titleHypo = "Hypothalamus ROI positioning";
msgHypo = "Move the window to cover both Parvafox nuclei";
waitForUser(titleHypo,msgHypo);
//setBatchMode("hide");
Roi.setPosition(1); //this is always necessary before the next line to add roi's to the manager
roiManager("Add");
roiManager("Select", 0);
roiManager("Rename", "Hypothalamus");
run("Duplicate...", "duplicate");
rename("Hypothalamus");


makeRectangle(0, 0, 1136, 1136); // define left parvafox
//setBatchMode("show");
titlePvf = "Parvafox ROI positioning";
msgPvf = "Move the window to cover both Parvafox nuclei";
waitForUser(titlePvf,msgPvf);
//setBatchMode("hide");
Roi.setPosition(1);
roiManager("Add");
roiManager("Select", 1);
roiManager("Rename", "Parvafox-L");
makeRectangle(4410, 0, 1136, 1136); //define right parvafox
//setBatchMode("show");
waitForUser(titlePvf,msgPvf);
//setBatchMode("hide");
Roi.setPosition(1);
roiManager("Add");
roiManager("Select", 2);
roiManager("Rename", "Parvafox-R");

selectWindow("Hypothalamus");
roiManager("Select", 1);
run("Duplicate...", "title=left duplicate");
selectWindow("Hypothalamus");
roiManager("Select", 2);
run("Duplicate...", "title=right duplicate");

selectWindow("Hypothalamus");
roiManager("Select", newArray(1,2));
roiManager("Set Color", "white");
roiManager("Set Line Width", 10);
run("Scale Bar...", "width=500 height=500 thickness=30 font=125 color=White background=None location=[Lower Right] horizontal bold overlay");
run("RGB Color");
roiManager("Show All");
run("Flatten");
saveAs("Tiff", output + "/File_merged_hypothalamus_RGB_flat.tif");
close();
close("Hypothalamus (RGB)");
selectWindow("Hypothalamus");
saveAs("Tiff", output + "/File_merged_hypothalamus.tif");
close();

//save ROIs, then delete the Parvafox ROIs
roiManager("Save", output + "/RoiSet.zip");
roiManager("Select", newArray(1,2));
roiManager("Delete");

selectWindow("Composite");
roiManager("Select", 0);
roiManager("Set Color", "white");
roiManager("Set Line Width", 50);
run("Scale Bar...", "width=1000 height=1000 thickness=100 font=400 color=White background=None location=[Lower Right] horizontal bold overlay");
run("RGB Color");
roiManager("Show All");
run("Flatten");
saveAs("Tiff", output + "/File_merged_RGB_flat.tif");
close();
close("Composite (RGB)");
selectWindow("Composite");
saveAs("Tiff", output + "/File_merged.tif");
close();

//Make montages
run("Set Scale...", "distance=1 known=" + sizeX + " unit=micron");
selectWindow("left");
run("RGB Color");
selectWindow("left");
run("Split Channels");
run("Images to Stack", "name=Parvafox-L_Stack title=left");
saveAs("Tiff", output + "/Parvafox-L_RGBstack.tif");
run("Make Montage...", "columns=3 rows=1 scale=" + DownScaleFactor+ " border="+ DownScaleFactor*12);
run("Scale Bar...", "width=200 height=200 thickness=" + DownScaleFactor*15 + " font=" + DownScaleFactor*50 + " color=White background=None location=[Lower Right] horizontal bold overlay");
run("Flatten");
saveAs("Tiff", output + "/Parvafox-L_RGB_Montage.tif");
close();

run("Set Scale...", "distance=1 known=" + sizeX + " unit=micron");
selectWindow("right");
run("RGB Color");
selectWindow("right");
run("Split Channels");
run("Images to Stack", "name=Parvafox-R_Stack title=right");		
saveAs("Tiff", output + "/Parvafox-R_RGBstack.tif");	
run("Make Montage...", "columns=3 rows=1 scale=" + DownScaleFactor+ " border="+ DownScaleFactor*12);
run("Scale Bar...", "width=200 height=200 thickness=" + DownScaleFactor*15 + " font=" + DownScaleFactor*50 + " color=White background=None location=[Lower Right] horizontal bold overlay");					
run("Flatten");
saveAs("Tiff", output + "/Parvafox-R_RGB_Montage.tif");		


//close all remaining image windows without saving. 
while (nImages>0) { 
	selectImage(nImages); 
	close(); 
	} 

//close the ROImanager
close("ROI manager");

print("Done!");																								