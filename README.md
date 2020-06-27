# High-performance AWS lambda with async Python 

_A template for building a high-performance Python function in AWS lambda using asyncio, aiohttp and aiobotocore. Perfect for a data processing pipeline._ 

## Features

- High-performance async Python 
- Runs in AWS lambda serverless environment λ 
- Integration tests with HTTP and AWS mocks
- CloudFormation template for AWS infrastructure deployment 
- Step-by-step guide to setup, install, test and deploy 

## Overview

This template demonstrates how to build and test a lambda function which runs HTTP requests and AWS actions concurrently to achieve fast and cheap execution. The [src/](./src) directory contains two example scripts which scrape bitcoin news from online sources and publish aggregated documents to S3. The output of the scripts is simple but they demonstrate a pattern for concurrent Python using [asyncio](https://docs.python.org/3/library/asyncio.html), [aiohttp](https://docs.aiohttp.org/en/stable/) and [aiobotocore](https://github.com/aio-libs/aiobotocore). You can see an example of the documents produced by this lambda in the test [fixtures](./tests/fixtures/documents).

This repository also includes a CloudFormation template which can be used to deploy the lambda and S3 infrastructure on AWS with appropriate IAM policies.

## Setup

Clone this repository and install [Python 3.7+](https://www.python.org/downloads/). Then, create an isolated Python environment at the root of the project using virtualenv:

```
python3 -m venv venv
```

Activate the virtual environment:

```
source venv/bin/activate
```

You'll also need to configure your IDE to use the virtual environment (this should be auto configured in VS Code by the [.vscode/settings.json](.vscode/settings.json) file).

## Install

Install the Python modules required for development:

```
pip -r install requirements-dev.txt
pip -r install requirements-prod.txt
```

The Python modules will be installed inside a local `site-packages` directory maintained by the virtual environment. This will help to keep the project isolated from other Python projects on your machine.

## Run the tests

This project uses `pytest` to run a suite of integration tests which are designed to run as much application code as possible while mocking the external HTTP and AWS calls. The tests use [aioresponses](https://github.com/pnuckowski/aioresponses) to mock async HTTP requests and the builtin module `unittest` to patch the aiobotocore module. Run the tests:

```
pytest
```

You can run the debugger in VS Code by setting a breakpoint and running the `Python: Module` launch configuration.

## Infrastructure

To provision the lambda and S3 infrastructure on AWS you'll need to visit the CloudFormation service in the AWS console and upload the stack template declared in [template.json](template.json). This will create a lambda component and S3 bucket with appropriate IAM policies.

## Deployment

To deploy the source code to the lambda component you'll need to zip the contents of the `src/` directory and include any 3rd party Python modules required in production. Run:

```
make package
```

This will make a fresh install of the production requirements into a `dist/` directory and will copy in the contents of the `src/` directory. The `dist/` directory is zipped to produce `dist.zip` which can be deployed to the lambda component via upload in the AWS console.

> For a smaller deployment package you could configure a [lambda layer with aiobotocore installed](https://github.com/keithrozario/Klayers/blob/master/deployments/python3.8/arns/eu-west-1.csv). The aiobotocore and aiohttp dependencies can then be removed from `requirements-prod.txt`.

## Error handling 

The main lambda handler in [src/index.py](src/index.py) demonstrates how to run any number of asynchronous scripts concurrently while handling exceptions gracefully. If an exception occurs within an individual script then a global exception will be raised only after all other scripts have completed. A detailed traceback is logged for debugging purposes.

## Q&A

#### Why use asynchronous Python? 

Asynchronous Python can speed up the execution time of a program by performing I/O concurrently. While a single threaded synchronous program will perform network requests one by one, an asynchronous program is able to handle multiple network requests at a time which can have a significant performance benefit when a large number of requests are made e.g. a data scraper/aggregator service. 

A similar effect can be achieved with synchronous code using a multi threaded approach but the concurrent pattern with asyncio is often preferred because it makes it easier to reason about the state of our runtime thanks to the explicit async/await syntax. 

Be aware that if your program does not require significant I/O then the traditional synchronous pattern will probably be quicker than the asynchronous pattern. 

#### Why use AWS lambda?

AWS lambda is a software environment that lets you run code without having to provision or manage your own server. To develop a lambda you only need to implement a function (the handler) to be called when the lambda is invoked.

Lambdas are connected to the AWS ecosystem and can be configured to run on a schedule or be triggered by a REST API call or by another AWS event such as SNS message or S3 upload. Lambda comes with a simple interface for monitoring performance and editing the function code on the fly.

With AWS Lambda you only pay for the execution time you consume so if your code is fast and efficient then it can often be cheaper to run than a traditional server instance.