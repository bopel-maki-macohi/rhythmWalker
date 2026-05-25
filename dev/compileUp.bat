lime build html5
lime build windows
lime build windows -32 -D_32bit
wsl lime build linux
wsl lime build linux -32 -D_32bit

cd export/64bit/release/html5/bin
wsl 7z a web-64bit.zip *
wsl mv web-64bit.zip ../../../../

cd ../../windows/bin
wsl 7z a windows-64bit.zip *
wsl mv windows-64bit.zip ../../../../

cd ../../linux/bin
wsl 7z a linux-64bit.zip *
wsl mv linux-64bit.zip ../../../../

cd ../../../32bit/windows/bin
wsl 7z a windows-32bit.zip *
wsl mv windows-32bit.zip ../../../../

cd ../../linux/bin
wsl 7z a linux-32bit.zip *
wsl mv linux-32bit.zip ../../../../

cd ../../../../../
