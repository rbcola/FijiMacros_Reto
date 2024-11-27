/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix


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
	setBatchMode(true);
	open(input + File.separator + file);
	
	//set the B&C for each of the 3 channels to 12bit MinMax format
	for (c = 1; c <= 3; c++) {
	Stack.setChannel(c)
	setMinAndMax(0, 4095);	
	}

	name=File.nameWithoutExtension;
	run("RGB Color");
	saveAs("tiff", input+"/"+name+"_RGB.tiff");
	close("*");
}

print("Done!");