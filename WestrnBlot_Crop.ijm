/*
 * Macro template to process multiple images in a folder
 */

//get input variables
#@ File (label = "Input directory", style = "directory") input

// define DateTime
getDateAndTime(year, month, week, day, hour, min, sec, msec);
DateTime = "" + year + "-" + month+1 + "-" + day + "_" + hour + "-" + min + "-" + sec

//create ouput directory automatically
output = input + File.separator + DateTime;
File.makeDirectory(output);

// See also Process_Folder.py for a version of this code
// in the Python scripting language.
list = getFileList(input);
trunk = substring(list[1],0,lengthOf(list[1])-14); //get the core filename

processFile(input);



function processFile(input) {
	setBatchMode(true);
	
	open(input + File.separator + trunk + "_Ch+Marker.jpg");
	makeRotatedRectangle(256, 520, 728, 498, 309);
	
	setBatchMode("show");
	title = "ROI selection";
	msg = "yellow dot needs to be at the last column side";
	waitForUser(title,msg);
	setBatchMode("hide");

	roiManager("Add");
	roiManager("Save", output + File.separator + trunk + ".roi");
	run("Duplicate...", " ");
	run("Flip Horizontally");
	saveAs("Tiff", output + File.separator + trunk + "_Ch+Marker_CropHflip.tif");
	
	close();
	
	open(input + File.separator + trunk + "_Ch.tif");
	roiManager("Select", 0);
	run("Duplicate...", " ");
	run("Flip Horizontally");
	run("Brightness/Contrast...");
	
	setBatchMode("show");
	title = "Adjust B/C";
	msg = "Click OK when done";
	waitForUser(title,msg);
	setBatchMode("hide");
	
	var min, max;
	getMinAndMax(min, max);
	saveAs("Tiff", output + File.separator + trunk + "_Ch_CropHflip_MinMax" + min + "-" + max + ".tif");
	run("RGB Color");
	saveAs("Tiff", output + File.separator + trunk + "_Ch_CropHflip_MinMax" + min + "-" + max + "_RGB.tif");
	close();
}

