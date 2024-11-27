/*
 * Macro template to process multiple images in a folder
 */

//get input variables
#@ File (label = "Input directory", style = "directory") input
//#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix
#@ Integer (label = "Nr. of stages", value = 9, persist = true) nStages
//#@ Integer (label = "B&C min", style="slider", min = 0, max = 255, value = 150, step=1, persist = true) BCmin
//#@ Integer (label = "B&C max", style="slider", min = 0, max = 255, value = 255, step=1, persist = true) BCmax
#@ Integer (label = "Final pixel height", value = 400, persist = true) PixHeight
#@ Float (label="DownScaleFactor for Montage", style="slider", min=0, max=1, stepSize=0.25, value = 1, persist = false) DownScaleFactor


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
	Ext.getPixelsPhysicalSizeX(sizeX);
	run("Set Scale...", "distance=1 known=" + sizeX + " unit=micron");
	
	if(matches(name, ".*_AS_.*")){
		setBatchMode("show");
		title = "ROI selection";
		msg = "Choose ROI for this section";
		waitForUser(title,msg);
		setBatchMode("hide");
		run("Duplicate...", "title=" + name + "_crop duplicate");
		run("RGB Color");
		run("Size...", "width=" + (getWidth()*PixHeight/getHeight()) + " height=" + PixHeight + " depth=1 constrain average interpolation=Bicubic");
	} else if (startsWith(name,substring(list[i-1],0,lengthOf(list[i-1])-10))){
		NameAS=substring(list[i-1],0,lengthOf(list[i-1])-4) + "_crop";
		selectWindow(NameAS);
		ASwidth=getWidth();
		selectWindow(NameAS);
		ASheight=getHeight();
		selectWindow(name + ".tif");
		makeRectangle(0, 0, ASwidth, ASheight);
		setBatchMode("show");
		title = "ROI selection";
		msg = "Move existing ROI from AS to desired location";
		waitForUser(title,msg);
		setBatchMode("hide");
		run("Duplicate...", "title=" + name + "_crop duplicate");
		run("RGB Color");
		run("Size...", "width=" + (getWidth()*PixHeight/getHeight()) + " height=" + PixHeight + " depth=1 constrain average interpolation=Bicubic");
	}
	
	selectWindow(file);
	run("RGB Color");
	saveAs("Tiff", output + "/" + name + "_RGB.tif");
	close();
	close(file);
	
	selectWindow(name + "_crop (RGB)");
	run("Scale Bar...", "width=50 height=50 thickness=8 font=30 color=Black background=None location=[Lower Right] horizontal bold hide overlay");
	run("Flatten");
	saveAs("Tiff", output + "/" + name + "_cropRGB_flat.tif");
	selectWindow(name + "_crop (RGB)");
	saveAs("Tiff", output + "/" + name + "_cropRGB.tif");
	close();

}

close("*_crop");

imgs = getList("image.titles");
totalWidth = 0;
for (k = 0; k < imgs.length; k++) {
	selectWindow(imgs[k]);
	thisWidth= getWidth();
   	totalWidth = totalWidth + thisWidth;
	}
totalWidth = totalWidth/2;
newImage("Montage", "RGB black", totalWidth, PixHeight*2, 1);

cumulativeASWidths=0;
cumulativeSWidths=0;
for (j = 0; j < imgs.length; j++) {
   if(j==0){
   	run("Insert...", "source=" + imgs[j] + " destination=Montage x=0 y=0");
   	selectWindow(imgs[j]);
   	cumulativeASWidths= cumulativeASWidths + getWidth();
   	} else if (j==1){ //i.e. the first sense section
   	run("Insert...", "source=" + imgs[j] + " destination=Montage x=0 y=" + PixHeight);
   	selectWindow(imgs[j]);
   	cumulativeSWidths= cumulativeSWidths + getWidth();
   	} else if (j%2 == 0){ //for even numbers of j except 0 (i.e. All AS sections)
   	selectWindow(imgs[j-2]);
   	prevASHeight= getHeight();
   	selectWindow(imgs[j]);
   	thisHeight=getHeight();
   	run("Insert...", "source=" + imgs[j] + " destination=Montage x=" + cumulativeASWidths + " y=" + PixHeight-thisHeight);
   	selectWindow(imgs[j]);
   	cumulativeASWidths= cumulativeASWidths + getWidth();
    } else if (j%2 == 1){ //for all odd numbers (i.e. all sense slides)
   	selectWindow(imgs[j-2]);
   	prevSWidth= getWidth();
   	run("Insert...", "source=" + imgs[j] + " destination=Montage x=" + cumulativeSWidths + " y=" + PixHeight);
   	selectWindow(imgs[j]);
   	cumulativeSWidths= cumulativeSWidths + getWidth();
   	}
}

selectWindow("Montage");
//setMinAndMax(BCmin, BCmax);
saveAs("Tiff", output + "/cropRGB_flat_Montage.tif");

print("Done!");
