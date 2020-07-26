# Welcome to your CDK TypeScript project!

This is a blank project for TypeScript development with CDK.

The `cdk.json` file tells the CDK Toolkit how to execute your app.

## How We Got Here
Type the following series of commands to arrive at the same point as this project.
```
mkdir cdk-project
cd cdk-project
cdk init app --language typescript
npm run build
cdk list
mkdir -p src/__tests__
mkdir -p src/__fixtures__
mkdir -p test/e2e
mkdir -p test/iac
mkdir -p test/__fixtures__
```

## Useful commands

 * `npm run build`   compile typescript to js
 * `npm run watch`   watch for changes and compile
 * `npm run test`    perform the jest unit tests
 * `cdk deploy`      deploy this stack to your default AWS account/region
 * `cdk diff`        compare deployed stack with current state
 * `cdk synth`       emits the synthesized CloudFormation template
