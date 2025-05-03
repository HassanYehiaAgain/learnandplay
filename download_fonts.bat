@echo off
echo Downloading font files...

REM Create font directories
mkdir assets\fonts

REM Download fonts
curl -L "https://fonts.gstatic.com/s/pressstart2p/v15/e3t4euO8T-267oIAQAu6jDQyK3nVivM.ttf" -o assets\fonts\PressStart2P-Regular.ttf
curl -L "https://fonts.gstatic.com/s/pixelifysans/v2/CHy2V-3HFUT7adnAcRcgLTnN7egYCQ.ttf" -o assets\fonts\PixelifySans-Regular.ttf
curl -L "https://fonts.gstatic.com/s/pixelifysans/v2/CHy2V-3HFUT7adnAcRcgLTnN7QgaCQ.ttf" -o assets\fonts\PixelifySans-Bold.ttf 
curl -L "https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfMZg.ttf" -o assets\fonts\Inter-Regular.ttf
curl -L "https://fonts.gstatic.com/s/inter/v13/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuFuYMZg.ttf" -o assets\fonts\Inter-Bold.ttf

echo Font download completed! 