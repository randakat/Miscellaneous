// Choose source folder
dir = getDirectory("Choose Source Directory");
list = getFileList(dir);
totalFiles = 0;

// Setup CSV output
csvPath = dir + "Combined_Tissue_and_Particle_Measurements.csv";
header = "Filename,Particle_Thresh_Min,Particle_Thresh_Max,Particle_Count,Area_Thresh_Min,Area_Thresh_Max,Tissue_Area";
File.saveString(header + "\n", csvPath);

// Count total images to process (all .tif excluding _MASK.tif)
for (i = 0; i < list.length; i++) {
    if (endsWith(list[i], ".tif") && !endsWith(list[i], "_MASK.tif"))
        totalFiles++;
}

counter = 0;

for (i = 0; i < list.length; i++) {
    if (!endsWith(list[i], ".tif") || endsWith(list[i], "_MASK.tif"))
        continue;  // skip non-tif and masks here for processing

    maskName = replace(list[i], ".tif", "_MASK.tif");
    maskExists = File.exists(dir + maskName);

    counter++;
    showProgress(counter, totalFiles);

    open(dir + list[i]);
    originalTitle = getTitle();

    run("8-bit");
    run("Subtract Background...");

    // -------- PARTICLE COUNTING --------
    // Always do particle counting with manual threshold
    run("Threshold...");
    waitForUser("Adjust threshold for H3P PUNCTA. Click OK when ready.");
    getThreshold(pMin, pMax);
    run("Convert to Mask");
    run("Watershed");
    run("Set Measurements...", "redirect=None decimal=3");
    run("Analyze Particles...", "size=1-Infinity circularity=0.00-1.00 clear summarize");
    particleCount = nResults;
    run("Clear Results");
    close();

    // -------- AREA MEASUREMENT --------
    if (!maskExists) {
        // If mask not exists, create it manually
        open(dir + list[i]);
        run("Duplicate...", "title=" + maskName);
        run("8-bit");
        run("Threshold...");
        waitForUser("Adjust threshold for TOTAL WORM AREA. Click OK when ready.");
        getThreshold(aMin, aMax);
        run("Convert to Mask");
        saveAs("Tiff", dir + maskName);
        run("Set Measurements...", "area limit redirect=None decimal=3");
        run("Measure");

        n = nResults;
        if (n == 0) {
            print("No area measured in " + originalTitle + ". Skipping.");
            close();
            selectWindow(originalTitle);
            close();
            continue;
        }
        area = getResult("Area", 0);
        run("Clear Results");
        close();
        selectWindow(originalTitle);
        close();
    } else {
        // Mask exists, open it and measure area directly without thresholding
        open(dir + maskName);
        run("Set Measurements...", "area limit redirect=None decimal=3");
        run("Measure");

        n = nResults;
        if (n == 0) {
            print(“No area measured in mask " + maskName + ". Skipping.");
            close();
            continue;
        }
        area = getResult("Area", 0);
        run("Clear Results");
        close();

        // For area threshold values when mask exists, set to NA or blank
        aMin = "";
        aMax = "";
    }

    // -------- RECORD RESULTS --------
    resultLine = originalTitle + "," + pMin + "," + pMax + "," + particleCount + "," + aMin + "," + aMax + "," + area;
    File.append(resultLine + "\r\n", csvPath);
}

// -------- DONE --------
showMessage("Done!", "Processing complete.\nResults saved to:\n" + csvPath);
