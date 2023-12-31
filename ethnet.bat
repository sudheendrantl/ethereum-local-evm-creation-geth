@echo off

set rootdir=%cd%
set basedirname=ethereum
set datadirname=data
set bootnodename=bnode
set node1name=node1
set node2name=node2
set node3name=node3
set basedir=%rootdir%\%basedirname%
set bnodedir=%basedir%\%bootnodename%
set node1dir=%basedir%\%node1name%
set node2dir=%basedir%\%node2name%
set node3dir=%basedir%\%node3name%
set node1passwordlocation=%rootdir%\password.txt
set node2passwordlocation=%rootdir%\password.txt
set node3passwordlocation=%rootdir%\password.txt
set node1port=30306
set node1rpcport=8551
set node1httpport=3336
set /a node2port=node1port+1
set /a node2rpcport=node1rpcport+1
set /a node2httpport=node1httpport+1
set /a node3port=node1port+2
set /a node3rpcport=node1rpcport+2
set /a node3httpport=node1httpport+2

echo:
echo creating base and node directories...
cd %rootdir%
if exist %basedirname% rd /S /Q %basedirname%
md %basedirname%
md %basedirname%\%bootnodename%
md %basedirname%\%node1name%
md %basedirname%\%node2name%
md %basedirname%\%node3name%

echo:
echo creating account in %node1dir%...
geth --password %node1passwordlocation% --datadir %node1dir%\%datadirname% account new > node1.txt

echo:
echo creating account in %node2dir%...
geth --password %node2passwordlocation% --datadir %node2dir%\%datadirname% account new > node2.txt

echo:
echo creating account in %node3dir%...
geth --password %node3passwordlocation% --datadir %node3dir%\%datadirname% account new > node3.txt

echo:
echo creating genesis.json and other temp files for this programs use
python ..\utils\createfiles.py

echo:
echo here is the content of %rootdir%\genesis.json
type %rootdir%\genesis.json
echo:

echo:
echo here is the content of %rootdir%\chainid.txt
type %rootdir%\chainid.txt
echo:

echo:
echo here is the content of %rootdir%\node1.txt
type %rootdir%\node1.txt
echo:

echo:
echo here is the content of %rootdir%\node11.txt
type %rootdir%\node11.txt
echo:

echo:
echo here is the content of %rootdir%\node2.txt
type %rootdir%\node2.txt
echo:

echo:
echo here is the content of %rootdir%\node22.txt
type %rootdir%\node22.txt
echo:

echo:
echo here is the content of %rootdir%\node3.txt
type %rootdir%\node3.txt
echo:

echo:
echo here is the content of %rootdir%\node33.txt
type %rootdir%\node33.txt
echo:

echo:
echo performing geth init in %node1dir%
geth init --datadir %node1dir%\%datadirname% %rootdir%\genesis.json

echo:
echo performing geth init in %node2dir%
geth init --datadir %node2dir%\%datadirname% %rootdir%\genesis.json

echo:
echo performing geth init in %node3dir%
geth init --datadir %node3dir%\%datadirname% %rootdir%\genesis.json

echo:
echo creating bootkey into %bnodedir%\boot.key
bootnode -genkey %bnodedir%\boot.key

echo:
echo fetching the public key of bootnode to create the enode URL
bootnode -nodekey %bnodedir%\boot.key -addr :30305 --writeaddress --verbosity 7 > enode.txt

set enodehead=enode://
set enodetail=@127.0.0.1:0?discport=30305
set /p enodelink=<enode.txt
set enodelink=%enodehead%%enodelink%%enodetail%

echo:
echo enode URL: %enodelink%

set /p chainid=<chainid.txt
echo:
echo chainid : %chainid%

set /p node1pubkey=<node11.txt
echo:
echo node1 public key : %node1pubkey%

set /p node2pubkey=<node22.txt
echo:
echo node2 public key : %node2pubkey%

set /p node3pubkey=<node33.txt
echo:
echo node3 public key : %node3pubkey%

echo:
echo starting bootnode %bootnodename% in %bnodedir%
echo "%bootnodename%" cmd /k "bootnode -nodekey %bnodedir%\boot.key -addr :30305 --verbosity 3"
start "%bootnodename%" cmd /k "bootnode -nodekey %bnodedir%\boot.key -addr :30305 --verbosity 3"
timeout /t 5

echo:
echo starting %node1name% in %node1dir%
set cmd1="geth --datadir %node1dir%\%datadirname% --port %node1port% --bootnodes %enodelink% --networkid %chainid% --ipcdisable --http --allow-insecure-unlock --http.port %node1httpport% --http.corsdomain "*" --http.vhosts "*" --http.api web3,eth,debug,personal,net --unlock %node1pubkey% --password %node1passwordlocation% --authrpc.port %node1rpcport% --miner.etherbase %node1pubkey% --mine --syncmode "full" --verbosity 3 console"

echo %cmd1%
start "%node1name%" cmd /k %cmd1%
timeout /t 1

echo:
echo starting %node2name% in %node2dir%
set cmd2="geth --datadir %node2dir%\%datadirname% --port %node2port% --bootnodes %enodelink% --networkid %chainid% --ipcdisable --http --allow-insecure-unlock --http.port %node2httpport% --http.corsdomain "*" --http.vhosts "*" --http.api web3,eth,debug,personal,net --unlock %node2pubkey% --password %node2passwordlocation% --authrpc.port %node2rpcport% --miner.etherbase %node2pubkey% --mine --syncmode "full" --verbosity 3 console"
echo %cmd2%
start "%node2name%" cmd /k %cmd2%
timeout /t 1

echo:
echo starting %node3name% in %node3dir%
set cmd3="geth --datadir %node3dir%\%datadirname% --port %node3port% --bootnodes %enodelink% --networkid %chainid% --ipcdisable --http --allow-insecure-unlock --http.port %node3httpport% --http.corsdomain "*" --http.vhosts "*" --http.api web3,eth,debug,personal,net --unlock %node3pubkey% --password %node3passwordlocation% --authrpc.port %node3rpcport% --syncmode "full" --verbosity 3 console"
echo %cmd3%
start "%node3name%" cmd /k %cmd3%
timeout /t 1

echo:
echo performing post-cleanup
if exist chainid.txt del chainid.txt
if exist enode.txt del enode.txt
if exist node1.txt del node1.txt
if exist node2.txt del node2.txt
if exist node3.txt del node3.txt
if exist node11.txt del node11.txt
if exist node22.txt del node22.txt
if exist node33.txt del node33.txt

echo All done!
pause
