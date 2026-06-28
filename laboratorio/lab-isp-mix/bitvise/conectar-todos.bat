@echo off
REM Abre os 5 nos do lab em janelas separadas usando o cliente CLI do
REM Bitvise (stnlc.exe). Ajuste o caminho do stnlc se necessario.
REM Requer Bitvise instalado. Se 'stnlc' nao for encontrado, use os
REM perfis salvos na interface grafica (ver perfis-bitvise.txt).

set STNLC="C:\Program Files\Bitvise SSH Client\stnlc.exe"

start "VIVO"          %STNLC% localhost -port=31022 -user=admin -pw=admin
start "CLARO"         %STNLC% localhost -port=32022 -user=admin -pw=admin
start "MIKROTIK-001"  %STNLC% localhost -port=35022 -user=admin -pw=admin
start "GOIASTECH"     %STNLC% localhost -port=33022 -user=root  -pw=lab123
start "CONTABILIDADE" %STNLC% localhost -port=34022 -user=root  -pw=lab123
