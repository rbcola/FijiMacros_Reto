path = File.openDialog("Select a File");

dir = File.getParent(path);
name = File.getName(path);
NoSuffName = File.nameWithoutExtension;

run("Bio-Formats Importer", "open=path view=Hyperstack stack_order=XYCZT");
run("Split Channels");

selectImage("C4-"+name);
run("Z Project...", "projection=[Max Intensity]");
selectImage("C4-"+name);
close();

selectImage("C3-"+name);
run("Z Project...", "projection=[Max Intensity]");
selectImage("C3-"+name);
close();

selectImage("C2-"+name);
run("Z Project...", "projection=[Max Intensity]");
selectImage("C2-"+name);
close();

selectImage("C1-"+name);
run("Z Project...", "projection=[Max Intensity]");
selectImage("C1-"+name);
close();

run("Merge Channels...", "c4=[MAX_C1-"+ name + "] c5=[MAX_C4-" + name + "] c6=[MAX_C2-" + name + "] c7=[MAX_C3-" + name + "] create");
run("Make Composite");
rename(NoSuffName + "_MaxZ_Comp");

/*
run("RGB Color");
close();
//run("Brightness/Contrast...");
//run("Channels Tool...");
Stack.setActiveChannels("0111");
Stack.setActiveChannels("0101");
Stack.setActiveChannels("0100");
Stack.setActiveChannels("0000");
Stack.setActiveChannels("0010");
Stack.setActiveChannels("0000");
Stack.setActiveChannels("0001");
Stack.setActiveChannels("0011");
Stack.setActiveChannels("0001");
Stack.setActiveChannels("0011");
Stack.setActiveChannels("0001");
Stack.setActiveChannels("0011");
Stack.setActiveChannels("0111");
Stack.setActiveChannels("0011");
Stack.setActiveChannels("0111");
Stack.setActiveChannels("1111");
Stack.setActiveChannels("0111");
Stack.setActiveChannels("1111");
Stack.setActiveChannels("0111");
Stack.setActiveChannels("1111");
run("RGB Color");
selectImage("Composite");
selectImage("MAX_EGL-PCL-distIGL_ZStack_ProtocolsIO_Setup.czi - C=0");
close();
selectImage("MAX_EGL-PCL-distIGL_ZStack_ProtocolsIO_Setup.czi - C=1");
close();
selectImage("MAX_EGL-PCL-distIGL_ZStack_ProtocolsIO_Setup.czi - C=3");
close();
selectImage("MAX_EGL-PCL-distIGL_ZStack_ProtocolsIO_Setup.czi - C=2");
close();
run("Stack to Images");
run("RGB Color");
selectImage("Composite-0003");
run("RGB Color");
selectImage("Composite-0002");
run("RGB Color");
selectImage("Composite-0001");
//run("Brightness/Contrast...");
run("Duplicate...", " ");
run("Close");
selectImage("Composite-0001");
run("RGB Color");
selectImage("Composite-0001-1");
run("RGB Color");
run("Images to Stack", "use keep");
run("Make Montage...");
run("Stack Sorter");
run("Close");
run("Make Montage...", "columns=6 rows=1 scale=1");
close();
run("Make Composite");
run("Close");
selectImage("Composite-0002");
selectImage("Stack");
run("RGB Color", "slices keep");
selectImage("Stack");
close();
run("Make Montage...", "columns=6 rows=1 scale=1 border=5");
//run("Brightness/Contrast...");
saveAs("Tiff", "Z:/data/r.cola/ZeissLSM980_Airy2/24-02-06_BARseq/BARseq_CB-pilot_CB40_1stCycle_data/EGL-PCL-distIGL_ZStack_ProtocolsIO_Setup_montage.tif");
close();
close();
close();
close();
close();
close();
close();
selectImage("Composite (RGB)");
close();
*/