# CurlDownloadHelper
This program tries to provide a simple ui to use Curl to batch-download your stuff

## Why?
I don't know! It seemed pretty interesting to me to test my skills. There are lots of interesting code snippets to use threads and pipes with [ahkdll v2](https://github.com/HotKeyIt/ahkdll-v2-release). Of course you can use it without asking me ;-).

## Features
You can paste a list of links in the edit box and click download. Then it should download your stuff. You can change your download location, load and save link lists and view the log and Curl output. You don't have to save your link list every time you are using this program; it will be saved on exit.

## Warnings
* This program is not meant to be used productively! It seems to be proof-of-concept, but who knows :).
* The UI is completely in german. I will change it some day but for now it is like it is.
* I don't know if i am allowed to reuse the Curl binary i am using and the logo i'm (currently) using. Therefore they are not available in this repo. But you could make your own icon and download the official Curl binary and add it to the compiler script.
* The "add links from clipboard" function doesn't even nearly work! I don't know why, but will try to find the problem soon.

## Compilation
* compile the AddResource.ahk (with the compiler bundled with ahkdll v2 [link above])
* edit the compile.bat to fit your needs
* double click compile.bat
