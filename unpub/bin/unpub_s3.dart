import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:unpub/unpub.dart' as unpub;

main(List<String> args) async {
  var env = Platform.environment;

  var host = env['UNPUB_HOST'] as String;
  var port = int.parse(env['UNPUB_PORT'] as String);
  var dbUri = env['UNPUB_MONGO_DB'] as String;
  // var proxy_origin = env['proxy-origin'] as String;
  var proxy_origin = "";
  var uploaderToken = env['UPLOADER_TOKEN'] as String;
  var viewToken = env['VIEW_TOKEN'] as String;
  var uploaderEmail = env['UPLOADER_EMAIL'] as String;
  var s3BucketName = env['AWS_S3_BUCKET_NAME'] as String;
  var s3Endpoint = env['AWS_S3_ENDPOINT'] as String;
  var s3Region = env['AWS_DEFAULT_REGION'] as String;
  var s3AccessKey = env['AWS_ACCESS_KEY_ID'] as String;
  var s3SecretKey = env['AWS_SECRET_ACCESS_KEY'] as String;

  final db = Db(dbUri);
  await db.open();
  var s3Store = unpub.S3Store(s3BucketName,

        // We attempt to find region from AWS_DEFAULT_REGION. If one is not
        // available or provided an Argument error will be thrown.
        region: s3Region,

        // Provide a different S3 compatible endpoint. 'aws-alternative.example.com'
        endpoint: s3Endpoint,

        // By default packages are sorted into folders in s3 like this.
        // Pass in an alternative if needed.
        getObjectPath: (String name, String version) => '$name/$name-$version.tar.gz',

        // You can provide credentials manually but...
        // Don't be bad at security populate env vars instead...
        // AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxxxxxxxxxx
        // AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        credentials: unpub.AwsCredentials(
            awsAccessKeyId: s3AccessKey,
            awsSecretAccessKey: s3SecretKey,
        ),
  );
  
  var app = unpub.App(
    uploaderEmail: uploaderEmail,
    uploaderToken: uploaderToken,
    viewToken: viewToken,
    metaStore: unpub.MongoStore(db),
    packageStore: s3Store,
    proxy_origin: proxy_origin.trim().isEmpty ? null : Uri.parse(proxy_origin)
  );

  var server = await app.serve(host, port);
  print('Serving at http://${server.address.host}:${server.port}');
}
