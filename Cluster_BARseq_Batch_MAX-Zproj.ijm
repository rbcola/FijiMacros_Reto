/*
 * This macro Z-projects all files matching suffix and the pattern ".*640nm_775em, 640nm, 561nm, 514nm_555em.*" that are found in the input folder
 */

#@ String input
#@ String outFolder

suffix = ".vsi";

// See also Process_Folder.py for a version of this code
// in the Python scripting language.
output1 = input + File.separator + "MAXprojected"
File.makeDirectory(output1);
output2=output1 + File.separator + outFolder
File.makeDirectory(output2);

// load BF macro extensions to open images in headless mode
run("Bio-Formats Macro Extensions");

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
		Ext.openImagePlus(input + File.separator + file);
		namesplit= split(file, "_");
		lastSplit= split(namesplit[namesplit.length-1], ".");
		shortname= namesplit[2]+"-"+namesplit[3]+"-"+lastSplit[0];
		run("Z Project...", "projection=[Max Intensity]");
		saveAs("Tiff", output2 + "/MAX_" + shortname + ".tif");
		close('*');
	}
}

print("\nDone!\n");
print("Your MAX-Z projected files are in: " + output2 + ".\n");
print("Copy the folder holding the MAX images onto the SPIM network folder for backup. Before BARseq processing rsynch the files to the /data/Reto/BARseqTransfer folder on the Linux machine.");