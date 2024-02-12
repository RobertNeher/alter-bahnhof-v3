[string]$container = "510f1862db9fa1f662ee975e368eb4252e284ea7745b62f87cfdeeed9764d834"
[string]$image = "7ee26c8012dae78cacf5c81a2fc459263f9c952cc69644bf6fdd218eaba85485"
[string]$dartaotrt = '/usr/lib/dart/bin/dartaotruntime';
[string]$server_aot = '/home/robert/server/bin/server.aot';
docker run $image ls -al $dartaotrt
docker run $image /usr/lib/dart/bin/dartaotruntime $server_aot