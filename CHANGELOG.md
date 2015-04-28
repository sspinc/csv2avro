# Changelog

All notable changes to this project are documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Added
 * `rake docker:build` task
 * `rake docker:push` task to push to Docker Hub
 * Semantic Docker tags
 * CHANGELOG.md

### Changed
 * Dockerfile (#6)
 * Docker tags under sspinc/csv2avro
 * Improved Rake tasks

## [0.2.1] (2015-04-08)

### Fixed
 * Docker image creation

## [0.2.0] (2015-04-08)
### Added
 * Basic Dockerfile

## 0.1.0 (2015-04-07)
Initial release

### Added
 * CLI (`csv2avro convert`) to convert CSV files to Avro (#1)
 * Travis CI (#2)
 * Bad rows (#4)
 * Versioning ($5)
 * Gem packaging

[unreleased]: https://github.com/sspinc/csv2avro/compare/0.2.1...HEAD
[0.2.1]: https://github.com/sspinc/csv2avro/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/sspinc/csv2avro/compare/0.1.0...0.2.0
