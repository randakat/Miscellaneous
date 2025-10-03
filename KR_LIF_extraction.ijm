// KR_LIF_extraction.ijm
// Opens all series from a Leica .lif file and saves each as .tif

macro "LIF → TIF Exporter" {

    lifFile = File.openDialog("Select Leica .lif file");
    if (lifFile == "" || lifFile + "" == "undefined") {
        showMessage("No file selected — exiting.");
        exit();
    }

    // Prepare output folder
    slash = lastIndexOf(lifFile, "/");
    if (slash == -1) slash = lastIndexOf(lifFile, "\\");
    if (slash == -1) {
        dir = "";
        name = lifFile;
    } else {
        dir = substring(lifFile, 0, slash + 1);
        name = substring(lifFile, slash + 1);
    }
    nameNoExt = replace(name, ".lif", "");
    nameNoExt = replace(nameNoExt, ".LIF", "");
    outDir = dir + nameNoExt + "_tifs/";
    if (!File.exists(outDir)) File.makeDirectory(outDir);

    print("Opening all image series in " + lifFile);
    run("Bio-Formats Importer", 
        "open=[" + lifFile + "] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT open_all_series");

    // Get list of open images
    list = getList("image.titles");
    count = lengthOf(list);
    print("Found " + count + " series open, saving to " + outDir);

    for (i = 0; i < count; i++) {
        selectImage(list[i]);
        title = list[i];

        // --- Clean filename: remove everything before and including ".lif" ---
        idx = indexOf(title, ".lif");
        if (idx == -1) idx = indexOf(title, ".LIF");
        if (idx > -1) {
            title = substring(title, idx + 4); // remove ".lif"
            title = replace(title, "-_", "");  // clean up any leftover separators
            title = replace(title, "_-", "");
        }

        // Remove leading special characters manually
        while (substring(title, 0, 1) == "-" || substring(title, 0, 1) == "_" || substring(title, 0, 1) == " ") {
            title = substring(title, 1);
        }

        // Sanitize filename
        title = replace(title, "[:/\\\\]", "_");

        saveAs("Tiff", outDir + title + ".tif");
        print("Saved " + outDir + title + ".tif");
        close();
    }

    showMessage("Done", count + " images saved to:\n" + outDir);
}

