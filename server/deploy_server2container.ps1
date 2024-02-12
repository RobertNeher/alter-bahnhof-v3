[string]$container = "510f1862db9fa1f662ee975e368eb4252e284ea7745b62f87cfdeeed9764d834"
[string]$image = "7ee26c8012dae78cacf5c81a2fc459263f9c952cc69644bf6fdd218eaba85485"
dart compile aot-snapshot .\bin\server.dart
docker cp ../server/bin/server.aot $container:/home/robert/server