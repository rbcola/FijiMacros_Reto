/*
 * Macro template to process multiple images in a folder
 */

//get input variables
#@ File (label = "Input directory", style = "directory") input
//#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix
#@ Float (label="DownScaleFactor for Montage", style="slider", min=0, max=1, stepSize=0.25, value = 0.25, persist = false) DownScaleFactor
#@ Integer (label = "Min red", value = 0, persist = false) MinRed
#@ Integer (label = "Max red", value = 15000, persist = false) MaxRed
#@ Integer (label = "Min blue", value = 2500, persist = false) MinBlue
#@ Integer (label = "Max blue", value = 22000, persist = false) MaxBlue

//run the bio-formats extension macro to later extract pixel size
run("Bio-Formats Macro Extensions");

// define DateTime
getDateAndTime(year, month, week, day, hour, min, sec, msec);
DateTime = "" + year + "-" + month+1 + "-" + day + "_" + hour + "-" + min + "-" + sec

//create ouput directory automatically
output = input + File.separator + DateTime + "_Processed_r" + MinRed + "-" + MaxRed + "_b" + MinBlue + "-" + MaxBlue + "_ScaleFact" + DownScaleFactor;;
File.makeDirectory(output);

//create and save Parameter file
f = File.open(output + File.separator + DateTime + "_parameters.txt");
print(f, DateTime + "\n")
print(f, "Contrast Limits Red Channel = " + MinRed + "-" + MaxRed + "\n");
print(f, "Contrast Limits Blue Channel = " + MinBlue + "-" + MaxBlue + "\n");
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
	open(input + File.separator + file);
	name=File.nameWithoutExtension;
	
	// extract pixel size information
	Ext.setId(input + File.separator + file);
	Ext.getPixelsPhysicalSizeX(sizeX);
	Ext.getPlaneTimingExposureTime(ExposureTime_r,0);
	Ext.getPlaneTimingExposureTime(ExposureTime_b,1);
	print(f, name + "\n" + "Exposure Times:\tred " + ExposureTime_r*1000 + "ms\tblue " + ExposureTime_b*1000 + "ms\n\n");
	run("Set Scale...", "distance=1 known=" + sizeX + " unit=micron");
	
	run("Stack to Images");
	selectWindow(name+"-0001");
	rename("red");
	selectWindow(name+"-0002");
	rename("blue");
	
	selectWindow("red");
	run("  8 Orange ");
	//wait(500);
	setMinAndMax(0,65535);
	selectWindow("blue");
	run("Cyan");
	setMinAndMax(0,65535);
	run("Merge Channels...", "c1=red c3=blue create keep");
	selectWindow("Composite");
	run("Scale Bar...", "width=200 height=200 thickness=20 font=80 color=White background=None location=[Lower Right] horizontal bold overlay");
	saveAs("tiff", output+"/"+name+"_FullRange_comp.tiff");
	close();
	close("Composite");
	close("Composite (RGB)");
	close("Composite (RGB)-1"); //this is the flattened RGB composite image

	selectWindow("red");
	setMinAndMax(MinRed, MaxRed);
	selectWindow("blue");
	setMinAndMax(MinBlue, MaxBlue);

	run("Merge Channels...", "c1=red c3=blue create keep");
	selectWindow("Composite");
	run("Scale Bar...", "width=200 height=200 thickness=20 font=80 color=White background=None location=[Lower Right] horizontal bold overlay");
	saveAs("tiff", output+"/"+name+"_BCadj_comp.tiff");
	run("RGB Color");
	close(name+"_BCadj_comp.tiff");
	run("Flatten");
	saveAs("tiff", output+"/"+name+"_BCadj_comp_rgb.tiff");
	close();
	close("Composite");
	close("Composite (RGB)");
	close("Composite (RGB)-1");

	//create montage 
	run("Merge Channels...", "c1=red c3=blue create keep");
	selectWindow("red");
	run("RGB Color");
	selectWindow("blue");
	run("RGB Color");
	selectWindow("Composite");
	run("RGB Color"); // the resulting image is called "Composite (RGB)" and not "Composite" anymore
	close("Composite");
	run("Images to Stack", "use");
	run("Make Montage...", "columns=3 rows=1 scale=" + DownScaleFactor + " border=5");
	run("Scale Bar...", "width=200 height=200 thickness=" + 20*DownScaleFactor + " font=" + 80*DownScaleFactor + " color=White background=None location=[Lower Right] horizontal bold overlay");
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
