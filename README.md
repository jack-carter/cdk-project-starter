# Welcome to your CDK TypeScript project!
This is a blank project for TypeScript development with CDK.

It was generated with the included script, init-cdk-project.sh, which initializes
the project for CDK development, as well as creating test folders following common
conventions.

## How We Got Here
These are the commands to arrive at the same point as this project.
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
## Running init-cdk-project.sh
You can automate the steps above by downloading and running the initialization script
using the following:
```
curl -o- https://raw.githubusercontent.com/jack-carter/cdk-project-starter/master/init-cdk-project.sh > init-cdk-project.sh
chmod +x init-cdk-project.sh
init-cdk-project <project>
```
Or you can fully automate running the script by using the following:
```
curl -o- https://raw.githubusercontent.com/jack-carter/cdk-project-starter/master/init-cdk-project.sh | bash /dev/stdin [options] <project>
```
Here are the options available:
```
--debug
--dry-run
--log error|warn|info|trace
--language typescript|... (CDK language options)
--npm (default)
--yarn
```

## Folder Conventions
Folder               | Description
-------------------- | -----------
`$project/`          | top-level project folder
`bin/`               | CDK source files
`lib/`               | supporting CDK source files
`src/`               | SDK source files
`src/__tests__/`     | Unit / Integration tests
`src/__fixtures__/`  | Unit / Integration test fixtures
`test/`              | End-to-End / Infrastructure tests
`test/e2e/`          | End-to-End tests
`test/iac/`          | Infrastructure tests
`test/__fixtures__/` | End-to-End / Infrastructure test fixtures

## Cloud Development Kit (CDK)
The `cdk.json` file tells the CDK Toolkit how to execute your app.

## Useful commands
 * `npm run build`   compile typescript to js
 * `npm run watch`   watch for changes and compile
 * `npm run test`    perform the jest unit tests
 * `cdk deploy`      deploy this stack to your default AWS account/region
 * `cdk diff`        compare deployed stack with current state
 * `cdk synth`       emits the synthesized CloudFormation template
