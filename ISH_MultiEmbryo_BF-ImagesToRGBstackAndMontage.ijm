/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix
#@ String (label = "Embryo numbers (by ROI order)", value = "e.g. 841 842 844 845") embryos

embryos = split(embryos," ");
N_embryos= embryos.length;

// See also Process_Folder.py for a version of this code
// in the Python scripting language.
processFolder(input)

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		/* uncomment this commands to run the script recursively
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
			*/
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
setBatchMode(true); // prevents image windows from opening while the script is running
run("Bio-Formats", "open=[" + input + "/" + file +"] + color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
name=File.nameWithoutExtension;
rename("Original");
selectWindow("Original");
run("RGB Color");
rename(name);
selectWindow("Original");
close();
}

//get common file names
list = getFileList(input);
list = Array.sort(list);
endIndex=indexOf(list[1],"_AS_");
commonName=substring(list[1],0,endIndex);

run("Images to Stack", "use");
rename("Stack");
run("Deinterleave", "how="+N_embryos+" keep");

selectWindow("Stack");
saveAs("tiff", output+"/"+commonName+"_allROIs_RGB_Stack"+".tiff");
run("Make Montage...", "scale=1 font=30 label");
saveAs("tiff", output+"/"+commonName+"_allROIs_RGB_Montage"+".tiff");


// loop through the single embryos within the OCT block
for (i = 1; i < N_embryos+1; i++) {
	selectWindow("Stack #"+ i);
	slices = nSlices();
	saveAs("tiff", output+"/"+commonName+"_RBC"+embryos[i-1]+"_RGB_Stack"+".tiff");
	run("Make Montage...", "columns="+slices/2 +" rows=2 scale=1");
	saveAs("tiff", output+"/"+commonName+"_RBC"+embryos[i-1]+"_RGB_montage"+".tiff");
}


close("*");
print("Done!");


