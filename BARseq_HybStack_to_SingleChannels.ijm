/*
 * This macro takes in a folder containing stacks of hybridisation images from a BARseq experiment and then saves single channel files for channel1:4 (i.e. GFP-, YFP-, TxRed-, and Cy5-channels)
 */

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix

// See also Process_Folder.py for a version of this code
// in the Python scripting language.
setBatchMode(true);
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
	//if(matches(file, ".*[0-9][0-9]\.tif$")){   //use this conditional to use regex pattern for filename

	open(file);
	origname=File.getNameWithoutExtension(file);
	print(origname);
	rename("Stack");
	run("Stack to Images");
	
	selectWindow("Stack-0001");
	saveAs("Tiff", input + "/"+ origname + "_GFP.tif");
	selectWindow("Stack-0002");
	saveAs("Tiff", input + "/"+ origname + "_YFP.tif");
	selectWindow("Stack-0003");
	saveAs("Tiff", input + "/"+ origname + "_TxRed.tif");
	selectWindow("Stack-0004");
	saveAs("Tiff", input + "/"+ origname + "_Cy5.tif");
	selectWindow("Stack-0005");
	saveAs("Tiff", input + "/"+ origname + "_DAPI.tif");
	
	while (nImages>0) { 
          selectImage(nImages); 
          close();
          }
    //}
}
