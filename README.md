# aws-lambda-layer-awscliv2

## Prerequisites

- Docker
- zip

## Build layer

```bash
./build-layer.sh layer.zip
```

## Publish layer

:information_source: check you've got awscliv2 and aws credentials installed before publishing

#### Upload the archive to S3

The target bucket must be created in advance (for ex. `lambda-layer-awscliv2`):

```bash
aws s3 cp layer.zip s3://lambda-layer-awscliv2/layer.zip \
  --region eu-west-1
```

#### Publish Lambda layer version

```bash
aws lambda publish-layer-version \
  --region eu-west-1 \
  --compatible-runtimes provided \
  --layer-name awscliv2 \
  --content S3Bucket=lambda-layer-awscliv2,S3Key=layer.zip
```

Congrats! Copy the `LayerVersionArn` value and use it when setting up your Lambda function.

To get more information on publishing layers have a look at the [AWS CLI documentation](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lambda/publish-layer-version.html).

## Layer binaries

The list below enumerates the binaries included in the `awscliv2` layer:
- aws (v2)
- jq (v1.6)

## Notes

Feel free to create an issue if there is a need in a certain binary that is neither included in the layer nor provided by AWS Lambda by default.

Due to AWS CLI can be a bit slow when executed within Lambda functions with [less than 512 MB](https://bezdelev.com/hacking/aws-cli-inside-lambda-layer-aws-s3-sync/) of memory, you may want to consider increasing memory (thereby CPU power) and timeout time for your function.  
