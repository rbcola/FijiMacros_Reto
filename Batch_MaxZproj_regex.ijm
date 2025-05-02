/*
 * This macro Z-projects all files matching suffix and the pattern ".*640nm_775em, 640nm, 561nm, 514nm_555em.*" that are found in the input folder
 */


#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".vsi") suffix
#@ String (label = "File subset regex", value = ".*Sl[2,3].*") REpattern
//#@ String (label = "geneseq name", value = "geneseq01") outFolder


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

	if(matches(file, REpattern)) {
		print(file);
		run("Bio-Formats Importer", "open=["+input + File.separator + file +"] color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT use_virtual_stack series_1");
		name=File.nameWithoutExtension;
		run("Z Project...", "projection=[Max Intensity]");
		saveAs("Tiff", input + "/MAX_" + name + ".tif");
		close('*');
	}
}

print("Done\n");
print("Your MAX-Z projected files are in: " + input + ".\n");