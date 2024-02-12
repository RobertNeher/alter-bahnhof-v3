[string]$container = "510f1862db9fa1f662ee975e368eb4252e284ea7745b62f87cfdeeed9764d834"
[string]$image = "7ee26c8012dae78cacf5c81a2fc459263f9c952cc69644bf6fdd218eaba85485"
[string]$directory = [System.IO.Path]::GetDirectoryName(".");
[string]$extension = ".tar"
[string]$newFileName = "imageBackup" + [DateTime]::Now.ToString("yyyyMMdd-HHmmss") + $extension;
[string]$backupFile = [System.IO.Path]::Combine($directory, $newFileName);
echo "Committing.container '$container'..."
docker container commit $container
echo "Backup of image '$image' to '$backupFile' in progress..."
docker image save -o $backupFile $image
# echo "Backup Dart folders..."
# docker run --read-only $image tar -czvf usr_lib_dart.tar.gz dart_backup