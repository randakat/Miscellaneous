// FIJI/ImageJ Macro for Micrometer Calibration Measurements
// for Zeiss SteREOLumarV12 microscope scaling calibration
// Kate Randall 2025


// prompt to select input folder
dir = getDirectory("Select the folder containing micrometer images");

// get list of image files
list = getFileList(dir);

// create custom measurement table
    Table.create("Micrometer Measurements");


// loop through all micrometer images
for (i = 0; i < list.length; i++) {
    filename = list[i];

    // process only .czi files
    if (endsWith(filename, ".czi")) {

        open(dir + filename);

	// remove incorrect scaling auto-encoded by Zeiss scope
	run("Set Scale...", "distance=0 known=0 unit=pixel");

        waitForUser("Draw a line across the micrometer scale for " + filename + ", then click OK.");

        // parse zoom value from filename (name files <zoomvalue>.czi)
        zoom_str = replace(filename, ".czi", "");
        zoom = parseFloat(zoom_str);

        // record the micrometer length traced
        real_distance = getNumber("Enter real-world micrometer distance you traced (e.g., 100, 200, 500):", 100);

        // measure drawn line
        run("Measure");
        pixels = getResult("Length", nResults - 1);

        // add data to table
        Table.set("Zoom (X)", Table.size, zoom);
        Table.set("Measured Pixels", Table.size, pixels);
        Table.set("Micrometer Distance (µm)", Table.size, real_distance);

        // calculate and record pixel size
        pixel_size = real_distance / pixels;
        Table.set("Pixel Size (µm/pixel)", Table.size - 1, pixel_size);

        // update view
        Table.update("Micrometer Measurements");

        // clean up
        run("Clear Results");
        close(); // Close current image
    }
}


// prompt user to select output directory
outputDir = getDirectory("Choose a folder to save the measurement table");

// define output file path
outputPath = outputDir + "Micrometer_Measurements.csv";

// save table as CSV
Table.save(outputPath);

// Final message
showMessage("Batch Complete", "All images processed!\nThe 'Micrometer Measurements' table was saved to:\n" + outputPath);