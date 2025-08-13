/*
 * Macro template to process multiple images in a folder
 */
 
run("Collect Garbage");

//get input variables
#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = "Maximum_Z.vsi") suffix
#@ Boolean(label="Run Bleach Correction (exponential fit) on 488 channel?") BleachCorr488
#@ Boolean(label="Calculate pixelwise ratio?") PixWiseRat
#@ String (label = "regex", value = ".*Drop[2,3].*") re

//run the bio-formats extension macro to later extract pixel size
run("Bio-Formats Macro Extensions");

// define DateTime
getDateAndTime(year, month, week, day, hour, min, sec, msec);
DateTime = "" + year + "-" + month+1 + "-" + day + "_" + hour + "-" + min + "-" + sec;

//create ouput directory automatically
outfolder = output + File.separator + DateTime;
File.makeDirectory(outfolder);


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
	setBatchMode(false);
	if(matches(file, re)) {

		run("Bio-Formats Importer", "open=" + input + File.separator + file +" color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
		name=File.nameWithoutExtension;
		print(name);
		rename("Orig");
		
	
		if(BleachCorr488==1){
			run("Split Channels");
			selectImage("C3-Orig");
			run("Bleach Correction", "correction=[Exponential Fit]");
			selectImage("C3-Orig");
			close;
			selectImage("y = a*exp(-bx) + c");
			saveAs("PNG", outfolder + File.separator + name + "_fitPlot.png");
			close;
			expFit=getInfo("log");
			f = File.open(outfolder + File.separator + name + "_ExpFit488.txt"); // display file open dialog
			print(f, expFit);
			File.close(f);
			close("Log");
			run("Merge Channels...", "c1=C1-Orig c2=C2-Orig c3=DUP_C3-Orig create");
		}
		
		Property.set("CompositeProjection", "null");
		Stack.setDisplayMode("color");
		run("Grays");
		Stack.setChannel(2);
		run("Magenta");
		Stack.setChannel(3);
		run("Green");
		Property.set("CompositeProjection", "Sum");
		Stack.setDisplayMode("composite");
		Stack.setActiveChannels("011");
		run("Brightness/Contrast...");
		run("Channels Tool...");
		//set BC of fluo channels manually and interactive
		titleBC = "BC adjustment";
		msgBC = "Adjust Brightness and Contrast for each channel, then click 'OK'.";
		waitForUser(titleBC,msgBC);
	
		Stack.setActiveChannels("111");
		Stack.setSlice(0); 
		run("HyperStackReg ", "transformation=[Rigid Body] channel_1 show");
	
		// draw line through central canal to determin rotation
		setTool("line");
		titleAngle = "Get Rotation Angle";
		msgAngle = "draw line through central canal to determin rotation, then click 'OK'.";
		waitForUser(titleAngle,msgAngle);
	
		Roi.setPosition(1, 1, 8);
		roiManager("Add");
		roiManager("Select", 0);
		roiManager("Measure");
		Angle=getResult("Angle", 0);
		run("Rotate... ", "angle="+ Angle+90 +" grid=1 interpolation=Bilinear enlarge");
	
		// draw rectangle to crop to final size
		setTool("rectangle");
		titleRect = "Define final size";
		msgRect = "draw rectangle to determin final crop size, then click 'OK'.";
		waitForUser(titleRect,msgRect);
	
		Roi.setPosition(1, 1, 22);
		roiManager("Add");
		selectImage("Orig-registered");
		roiManager("Select", 1);
		run("Duplicate...", "title=Crop duplicate");
		Stack.setDisplayMode("composite");
		Stack.setActiveChannels("011");
		run("RGB Color", "frames keep");
		rename("Crop_RGB");
		saveAs("PNG", outfolder + File.separator + name + "_Crop_RGB.png");
		run("Label...", "format=00:00 starting=0 interval=20 x=5 y=55 font=50 text=[] range=1-72");
		run("AVI... ", "compression=JPEG frame=7 save=" + outfolder + File.separator + name + "_Crop_RGB_7pfs.avi");
	
		selectImage("Crop");
		run("Split Channels");
		
		if(PixWiseRat==1){
			imageCalculator("Divide create 32-bit stack", "C3-Crop","C2-Crop");
			selectImage("Result of C3-Crop");
			rename("PL1-to-tdT_ratio");
			run("RetoRatioLUT_YMCW");
			selectImage("PL1-to-tdT_ratio");
			setMinAndMax(0, 1);
			saveAs("TIFF", outfolder + File.separator + name + "_Crop_PL1-to-tdT_ratio.tiff");
			run("RGB Color");
			saveAs("PNG", outfolder + File.separator + name + "_Crop_PL1-to-tdT_ratio_RGB.png");
			rename("Ratio_RGB");
			run("Duplicate...", "duplicate");
			rename("Ratio_RGB_labelled");
			run("Label...", "format=00:00 starting=0 interval=20 x=5 y=55 font=80 text=[] range=1-72");
			run("AVI... ", "compression=JPEG frame=7 save=" + outfolder + File.separator + name + "_Crop_PL1-to-tdT_ratio_7fps.avi");
		}
	
		selectImage("C1-Crop");
		run("RGB Color");
		selectImage("C2-Crop");
		run("RGB Color");
		selectImage("C3-Crop");
		run("RGB Color");
		run("Combine...", "stack1=C1-Crop stack2=C2-Crop");
		run("Combine...", "stack1=[Combined Stacks] stack2=C3-Crop");
		rename("Montage");
		run("Combine...", "stack1=Montage stack2=Ratio_RGB");
		saveAs("PNG", outfolder + File.separator + name + "_Crop_RGB_montage.png");
		run("Label...", "format=00:00 starting=0 interval=20 x=5 y=55 font=80 text=[] range=1-72");
		run("AVI... ", "compression=JPEG frame=7 save=" + outfolder + File.separator + name + "_Crop_RGB_montage_7fps.avi");
	
		//close the ROImanager
		close("*");
		close("ROI Manager");
		close("Results");
	}
}

newImage("LUT", "32-bit ramp", 500, 100, 1);
selectImage("LUT");
run("RetoRatioLUT_YMCW");
setMinAndMax(0, 1);
saveAs("PNG", outfolder + File.separator + "RatioLUT.png");

print("Done!");