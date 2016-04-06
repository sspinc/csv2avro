# Changelog

All notable changes to this project are documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## 1.3.1 (2016-04-06) [compare](https://github.com/sspinc/csv2avro/compare/1.3.0...1.3.1))
Bump Logr version to 0.2.0

### Changed
* Logr version to 0.2.0


## 1.3.0 (2016-02-16) [compare](https://github.com/sspinc/csv2avro/compare/1.2.0...1.3.0))
Support for custom line endings

### Added
* New line ending command line parameter

## 1.2.0 (2015-11-18) [compare](https://github.com/sspinc/csv2avro/compare/1.1.0...1.2.0))
Structured logging and metrics

### Changed
* Log in JSON format using Logr (https://github.com/sspinc/logr)

### Added
* New started_converting and finished_converting events
* New lines_processed metric

## 1.1.0 (2015-09-16) [compare](https://github.com/sspinc/csv2avro/compare/1.0.2...1.1.0))

### Changed
 * Write usage and error messages to stderr
 * Exit code 1 for general errors, 2 for missing arguments
 * Bad rows report with error causes instead of bad rows csv

### Fixed
 * Handle quoted headers

## 1.0.2 (2015-06-29) [compare](https://github.com/sspinc/csv2avro/compare/1.0.1...1.0.2))

### Fixed
 * Continue on parsing errors

## 1.0.1 (2015-06-12) [compare](https://github.com/sspinc/csv2avro/compare/1.0.0...1.0.1))

### Fixed
 * CSV parsing issues

## 1.0.0 (2015-06-05) [compare](https://github.com/sspinc/csv2avro/compare/0.4.0...1.0.0))

### Added
 * Usage description to readme
 * Detailed exception reporting
 * `aws-cli` to Docker image

### Fixed
 * Docker image entrypoint

## 0.4.0 (2015-05-07) [compare](https://github.com/sspinc/csv2avro/compare/0.3.0...0.4.0))

### Added
 * Streaming support (#7)
 * `rake docker:spec` task

### Removed
 * S3 support (#7)

### Changed
 * Do not include .git in Docker build context

### Fixed
 * Build project into Docker image (#9)

## 0.3.0 (2015-04-28) [compare](https://github.com/sspinc/csv2avro/compare/0.1.0...0.3.0))

### Added
 * Docker support (#6)
   * `rake docker:build` task
   * `rake docker:push` task to push to Docker Hub
   * Semantic Docker tags
 * CHANGELOG.md

## 0.1.0 (2015-04-07)
Initial release

### Added
 * CLI (`csv2avro convert`) to convert CSV files to Avro (#1)
 * Travis CI (#2)
 * Bad rows (#4)
 * Versioning ($5)
 * Gem packaging
