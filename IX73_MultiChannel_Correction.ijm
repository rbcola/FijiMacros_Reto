/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix
#@ Integer (label = "Min red", value = 3000, persist = false) MinRed
#@ Integer (label = "Max red", value = 19300, persist = false) MaxRed
#@ Integer (label = "Min green", value = 3100, persist = false) MinGreen
#@ Integer (label = "Max green", value = 29750, persist = false) MaxGreen
#@ Integer (label = "Min blue", value = 4080, persist = false) MinBlue
#@ Integer (label = "Max blue", value = 65200, persist = false) MaxBlue


// See also Process_Folder.py for a version of this code
// in the Python scripting language.

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, list[i]);
	}
}

function processFile(input, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	setBatchMode(false);
	open(input + File.separator + file);
	name=File.nameWithoutExtension;
	
	run("Stack to Images");
	selectWindow(name+"-0001");
	rename("red");
	selectWindow(name+"-0002");
	rename("green");
	selectWindow(name+"-0003");
	rename("blue");
	
	selectWindow("red");
	setMinAndMax(MinRed, MaxRed);
	selectWindow("green");
	setMinAndMax(MinGreen, MaxGreen);
	selectWindow("blue");
	setMinAndMax(MinBlue, MaxBlue);
	run("Merge Channels...", "c1=red c2=green c3=blue create");
	selectWindow("Composite");

	saveAs("tiff", output+"/"+name+"_comp.tiff");
	run("RGB Color");
	saveAs("tiff", output+"/"+name+"_comp_rgb.tiff");
	
	run("Scale...", "x=0.25 y=0.25 width=512 height=512 interpolation=None average create title=downscaled");
	selectWindow("downscaled");
	saveAs("tiff", output+"/"+name+"_comp_rgb_downscaled.tiff");
	
	close("*");
}

print("Done!");
