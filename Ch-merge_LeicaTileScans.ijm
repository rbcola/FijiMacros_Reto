/*
 * Macro template to process multiple images in a folder
*/

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix

list = getFileList(input);
list = Array.sort(list);

// remove other files from the file list that are not matching images
regexp1 = "(.*Region.*)";
ImageList = newArray(0);

for (jj = 0; jj < list.length; jj++) {
	if(matches(list[jj], regexp1)){
		ImageList = Array.concat(ImageList,list[jj]);
	}
}

//Array.print(ImageList);

// extract the Region number from the filename
// and save it in a new list
RegionsList = newArray(ImageList.length);

//print("\\Clear");

for (kk = 0; kk < ImageList.length; kk++){
	a = split(ImageList[kk], "(n)" );
	b = split(a[2],"_");
	RegionNumber = b[0];
	RegionsList[kk] = RegionNumber;
}

UniqueRegions = unique(RegionsList);

// read in images belonging to the same region
setBatchMode(true);

for (jj = 0; jj < UniqueRegions.length; jj++) {
	print(jj);
	print(UniqueRegions[jj]);
	if(parseFloat(UniqueRegions[jj]) >= 10){
		sep_UR1 = UniqueRegions[jj].substring(0,1);
		sep_UR2 = UniqueRegions[jj].substring(1,2);
		regexp = "(.*Region[" + sep_UR1 + "][" + sep_UR2 + "]_Merging.*)";
	}else{
		regexp = "(.*Region[" + UniqueRegions[jj] + "]_Merging.*)";
		print("now");
	}

	for (ww = 0; ww < ImageList.length; ww++){
		if(matches(ImageList[ww], regexp)){
			open(ImageList[ww]);
		}
	}
	
	run("Images to Stack", "use");
	run("Rotate 90 Degrees Right");
	Title = File.nameWithoutExtension();
	Title = Title.substring(0,Title.length-4);
	saveAs("Tiff", input + "/"+ Title + "Ch-merged.tif");
	close("*");
}

print("Done!");




function unique(InputArray) { // Note: This is python code that is being evaluated within FIJI macro
    separator = "\\n"
    
    InputArrayAsString = InputArray[0];
    for(i = 1; i < InputArray.length; i++){
        InputArrayAsString += separator + InputArray[i];
    }
    
    script = "result = r'" + 
             separator +
             "'.join(set('" +
             InputArrayAsString +
             "'.split('" + 
             separator +
             "')))";
    
    result = eval("python", script);
    OutputArray = split(result, separator);
    return OutputArray;
}

