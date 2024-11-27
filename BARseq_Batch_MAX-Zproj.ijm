/*
 * This macro Z-projects all files matching suffix and the pattern ".*640nm_775em, 640nm, 561nm, 514nm_555em.*" that are found in the input folder
 */


#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".vsi") suffix
#@ String (label = "geneseq name", value = "geneseq01") outFolder


// See also Process_Folder.py for a version of this code
// in the Python scripting language.
output1 = input + File.separator + "MAXprojected"
File.makeDirectory(output1);
output2=output1 + File.separator + outFolder
File.makeDirectory(output2);

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

	if(matches(file, ".*640nm_775em, 640nm, 561nm, 514nm_555em.*")) {
		print(file);
		run("Bio-Formats Importer", "open=["+input + File.separator + file +"]");
		name=File.nameWithoutExtension;
		namesplit= split(name, "_");
		shortname= namesplit[2]+"-"+namesplit[3]+"-"+namesplit[8];
		run("Z Project...", "projection=[Max Intensity]");
		saveAs("Tiff", output2 + "/MAX_" + shortname + ".tif");
		close('*');
	}
}

print("Done\n");
print("Your MAX-Z projected files are in: " + output2 + ".\n");
print("Move on to synchronize your local processed folder (within /data/Reto/BARseqTransfer) with the folder on the cluster.");