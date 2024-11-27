/*
 * This macro Z-projects all files matching suffix and the pattern ".*640nm_775em, 640nm, 561nm, 514nm_555em.*" that are found in subfolders matching the folders pattern
 */


#@ File (label = "Input directory", style = "directory") input
#@ String(label = "Folder regex", value = "geneseq\\d{2}/") folders
#@ String (label = "File suffix", value = ".vsi") suffix


// See also Process_Folder.py for a version of this code
// in the Python scripting language.

processFolders(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolders(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]) && matches(list[i], folders)){
			sublist = getFileList(input + File.separator + list[i]); 
			sublist = Array.sort(sublist);
			for (j = 0; j < sublist.length; j++) {
				if(endsWith(sublist[j], suffix)){
					processFile(input, list[i], sublist[j]);
			}		
		}
	
	}
}

function processFile(input, folder, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	setBatchMode(true);
	
	//create ouput directory automatically
	output = input + File.separator + folder + File.separator + "MAX_" + folder;
	File.makeDirectory(output);

	if(matches(file, ".*640nm_775em, 640nm, 561nm, 514nm_555em.*")) {
		print(file);
		run("Bio-Formats Importer", "open=["+input + File.separator + folder + File.separator + file +"]");
		name=File.nameWithoutExtension;
		namesplit= split(name, "_");
		shortnname= namesplit[2]+"-"+namesplit[3]+"-"+namesplit[8];
		run("Z Project...", "projection=[Max Intensity]");
		saveAs("Tiff", output + "/MAX_" + shortname + ".tif");
		close('*');
	}
}

print("Done");

