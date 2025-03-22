docker-compose up -d
open http://localhost:24000

# Start server
docker-compose -f 'docker-compose.yaml' up --build

# How to publish package to this server?

### Update pubspec.yaml
```
name: sample_package
description: "A new Flutter package project."
version: 0.0.1
publish_to: https://10.10.110.41:443/ #Your Enterprise pub server  
```

``` Add SSL cert to dart
export SSL_CERT_FILE=$(pwd)/fullchain.pem
flutter pub get
```
### Publish package cmd

echo "89dsfl8s091212" | fvm dart pub token add https://10.10.110.41:443
echo $UNPUB_ADMIN_TOKEN | fvm dart pub token add https://10.10.110.41:443
fvm dart pub publish


# Use it in other package
```
dependencies:
  sample_package:
    hosted: https://10.10.110.41:443
    version: 1.0.1 
```