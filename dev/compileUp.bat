lime build html5
lime build windows

cd export/release/html5/bin
wsl 7z a web.zip *
wsl mv web.zip ../../../

cd ../../windows/bin
wsl 7z a windows.zip *
wsl mv windows.zip ../../../

cd ../../../../
