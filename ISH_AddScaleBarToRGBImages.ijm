/*
 * Macro template to process multiple images in a folder
 */

//get input variables
#@ File(label = "Input directory", style = "directory") input
//#@ File (label = "Output directory", style = "directory") output
#@ String(label = "File suffix", value = "RGB.tiff") suffix
#@ Boolean(label="use user px size input?") userinput
#@ Boolean(label="RGB conversion required?") RGBconv
#@ Double(value=0.5119) PhysicalX


//run the bio-formats extension macro to later extract pixel size
run("Bio-Formats Macro Extensions");

// define DateTime
getDateAndTime(year, month, week, day, hour, min, sec, msec);
DateTime = "" + year + "-" + month+1 + "-" + day + "_" + hour + "-" + min + "-" + sec

//create ouput directory automatically
output = input + File.separator + DateTime;
File.makeDirectory(output);

/*
//create and save Parameter file
f = File.open(output + File.separator + DateTime + "_parameters.txt");
print(f, DateTime + "\n")
print(f, "Contrast Limits Red Channel = " + MinRed + "-" + MaxRed + "\n");
print(f, "Contrast Limits Blue Channel = " + MinBlue + "-" + MaxBlue + "\n");
print(f, "DownScaleFactor for Montage = " + DownScaleFactor + "\n\n");
*/

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
	
	setBatchMode(true);
	open(input + File.separator + file);
	name=File.nameWithoutExtension;
	// extract pixel size information
	Ext.setId(input + File.separator + file);
	if (userinput == 0) {
		Ext.getPixelsPhysicalSizeX(sizeX);
	} else {
		sizeX = PhysicalX;
	}
	print(name);
	print(sizeX);
	run("Set Scale...", "distance=1 known=" + sizeX + " unit=micron");
	if(RGBconv == 1){
		run("RGB Color");
		saveAs("Tiff", output + "/" + name + "_RGB.tiff");
		name = name + "_RGB";
		}
	
	run("Scale Bar...", "width=200 height=100 thickness=25 font=50 color=Black location=[Lower Left] bold overlay");
	saveAs("Tiff", output + "/" + name + "_SB.tif");
	run("Flatten");
	saveAs("Tiff", output + "/" + name + "_SBflat.tif");
	close("*");

}

print("Done!");
