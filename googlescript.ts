function downloadEmbeddedImages() {
  // Replace these with your specific IDs
  const spreadsheetId = '1h4KVKVx3hVOPP2aeHh6WV2WrKTgD9sxsLTvZ-LoOShk';
  const sheetName = 'REAL ONE'; 
  const folderId = '1QpUZmo9lLzDamY6t3A1Q9EHLCpyse6gX';

  const spreadsheet = SpreadsheetApp.openById(spreadsheetId);
  const sheet = spreadsheet.getSheetByName(sheetName);
  
  if (!sheet) {
    Logger.log('Sheet not found: ' + sheetName);
    return;
  }
  
  const folder = DriveApp.getFolderById(folderId);
  
  // Get all data from the sheet, including the header
  const dataRange = sheet.getDataRange();
  const values = dataRange.getValues();
  const headers = values[0];

  // Find the column indices for "Name" and "Address"
  const nameColumn = headers.indexOf('Name');
  const addressColumn = headers.indexOf('Address');

  if (nameColumn === -1 || addressColumn === -1) {
    Logger.log('Required columns (Name or Address) not found.');
    return;
  }

  // Get all images on the sheet
  const images = sheet.getImages();

  if (images.length === 0) {
    Logger.log('No images found on the sheet.');
    return;
  }

  // Loop through each image found on the sheet
  images.forEach(image => {
    try {
      // **This is the new check to prevent the error**
      // Only proceed if the object has the getAnchorRow function (i.e., it's a valid image drawing)
      if (typeof image.getAnchorRow !== 'function') {
        Logger.log('Skipping a non-image drawing object.');
        return;
      }
      
      // Get the row that the image is anchored to. 
      // Note: Apps Script row numbers are 1-based, array indices are 0-based.
      const imageRow = image.getAnchorRow();
      
      // Get the data for the corresponding row from the values array.
      // We use (imageRow - 1) to get the correct array index.
      const rowData = values[imageRow - 1];

      // Skip if the image is in the header row or if there's no data
      if (!rowData || imageRow === 1) {
        return;
      }

      const placeName = rowData[nameColumn];
      const address = rowData[addressColumn];
      
      // Skip if the Name or Address data is missing
      if (!placeName || !address) {
        Logger.log(`Skipping image on row ${imageRow} due to missing Name or Address.`);
        return;
      }

      // Create a custom file name and sanitize it
      const fileName = `${placeName.trim()} - ${address.trim()}.jpg`;
      const sanitizedFileName = fileName.replace(/[\\/:*?"<>|]/g, '-').replace(/\s+/g, ' '); // Clean up invalid characters

      // Get the image blob
      const fileBlob = image.getBlob();

      // Check for a duplicate file name to prevent errors
      const files = folder.getFilesByName(sanitizedFileName);
      if (files.hasNext()) {
        Logger.log(`File "${sanitizedFileName}" already exists. Skipping.`);
        return;
      }
      
      // Save the image to the specified Google Drive folder
      folder.createFile(fileBlob).setName(sanitizedFileName);
      Logger.log(`Successfully saved: ${sanitizedFileName}`);

    } catch (e) {
      Logger.log(`Failed to process image on row: ${image.getAnchorRow()}. Error: ${e.toString()}`);
    }
  });
}