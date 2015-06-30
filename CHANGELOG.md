# Changelog

All notable changes to this project are documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## 1.0.1 (2015-06-12; [compare](https://github.com/sspinc/csv2avro/compare/1.0.0...1.0.1))

### Fixed
 * CSV parsing issues

## 1.0.0 (2015-06-05; [compare](https://github.com/sspinc/csv2avro/compare/0.4.0...1.0.0))

### Added
 * Usage description to readme
 * Detailed exception reporting
 * `aws-cli` to Docker image

### Fixed
 * Docker image entrypoint

## 0.4.0 (2015-05-07; [compare](https://github.com/sspinc/csv2avro/compare/0.3.0...0.4.0))

### Added
 * Streaming support (#7)
 * `rake docker:spec` task

### Removed
 * S3 support (#7)

### Changed
 * Do not include .git in Docker build context

### Fixed
 * Build project into Docker image (#9)

## 0.3.0 (2015-04-28; [compare](https://github.com/sspinc/csv2avro/compare/0.1.0...0.3.0))

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
