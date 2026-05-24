lime build html5
cd export/release/html5/bin
wsl 7z a web.zip *
wsl mv web.zip ../../../

cd ../../windows/bin
lime build windows
wsl 7z a windows.zip *
wsl mv windows.zip ../../../

cd ../../../../
