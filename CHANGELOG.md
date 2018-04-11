# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Broker#run_once now returns true if a message was handled.
- PitchBendChange.create now accepts a float value instead of the raw bytes.

## [0.2.0] - 2018-04-11
### Added
- Subscription object to handle objects subscribing to incoming messages.
- Message broker implementation.