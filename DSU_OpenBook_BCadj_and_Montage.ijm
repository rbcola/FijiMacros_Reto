/*
 * Macro template to process multiple images in a folder
 */

//get input variables
#@ File (label = "Input directory", style = "directory") input
//#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix
#@ Float (label="DownScaleFactor for Montage", style="slider", min=0, max=1, stepSize=0.25, value = 0.25, persist = false) DownScaleFactor


//run the bio-formats extension macro to later extract pixel size
run("Bio-Formats Macro Extensions");

// define DateTime
getDateAndTime(year, month, week, day, hour, min, sec, msec);
DateTime = "" + year + "-" + month+1 + "-" + day + "_" + hour + "-" + min + "-" + sec

//create ouput directory automatically
output = input + File.separator + DateTime + "_Processed_AutoBC_ScaleFact" + DownScaleFactor;;
File.makeDirectory(output);

//create and save Parameter file
f = File.open(output + File.separator + DateTime + "_parameters.txt");
print(f, DateTime + "\n")
print(f, "DownScaleFactor for Montage = " + DownScaleFactor + "\n\n");

// See also Process_Folder.py for a version of this code
// in the Python scripting language.

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		//if(File.isDirectory(input + File.separator + list[i]))
			//processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, list[i]);
	}
}

function processFile(input, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	setBatchMode(true);
	run("Bio-Formats Importer", "open="+input + File.separator + file + " autoscale color_mode=Default rois_import=[ROI manager] split_channels view=Hyperstack stack_order=XYCZT stitch_tiles");
	name=File.nameWithoutExtension;
	
	// extract pixel size information
	Ext.setId(input + File.separator + file);
	Ext.getPixelsPhysicalSizeX(sizeX);
	Ext.getPlaneTimingExposureTime(ExposureTime_r,0);
	Ext.getPlaneTimingExposureTime(ExposureTime_g,1);
	print(f, name + "\n" + "Exposure Times:\tred " + ExposureTime_r*1000 + "ms\tgreen " + ExposureTime_g*1000 + "ms\n\n");
	run("Set Scale...", "distance=1 known=" + sizeX + " unit=micron");
	
	selectWindow(name + suffix + " - C=0");
	run("Z Project...", "projection=[Standard Deviation]");
	run("7 Orange Hot ");
	run("Enhance Contrast", "saturated=0.35");
	rename("red");
	close(name + suffix + " - C=0");

	selectWindow(name + suffix + " - C=1");
	run("Z Project...", "projection=[Standard Deviation]");
	run("4 Cyan Hot ");
	run("Enhance Contrast", "saturated=0.35");
	rename("green");
	close(name + suffix + " - C=1");

	run("Merge Channels...", "c1=red c2=green create keep");
	run("Scale Bar...", "width=50 height=200 thickness=" + 20*DownScaleFactor + " font=" + 80*DownScaleFactor + " color=White background=None location=[Lower Left] horizontal bold overlay");
	saveAs("tiff", output + "/" + name + "_BCadj_comp.tiff");
	run("RGB Color");
	run("Flatten");
	saveAs("tiff", output + "/" + name + "_BCadj_comp_RGB.tiff");
	close(name+"_BCadj_comp.tiff");

	selectWindow("red");
	run("RGB Color");
	selectWindow("green");
	run("RGB Color");

	run("Images to Stack", "use");
	run("Make Montage...", "columns=3 rows=1 scale=" + DownScaleFactor + " border=5");
	run("Set Scale...", "distance=1 known=" + sizeX + " unit=micron");
	run("Scale Bar...", "width=50 height=200 thickness=" + 20*DownScaleFactor + " font=" + 80*DownScaleFactor + " color=White background=None location=[Lower Left] horizontal bold overlay");
	run("Flatten");
	selectWindow("Montage-1");
	saveAs("tiff", output+"/"+name+"_BCadj_rgb_montage.tiff");
	
	//close all image windows without saving. 
    while (nImages>0) { 
        selectImage(nImages); 
        close(); 
    } 

}


File.close(f);
print("Done!");
