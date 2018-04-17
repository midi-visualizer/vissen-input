# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- Message subscribers can now prevent a message from reaching lower priority subscribers.

## [0.2.1] - 2018-04-11
### Added
- Yard compatible documentation.
### Changed
- Broker#run_once now returns true if a message was handled.
- PitchBendChange.create now accepts a float value instead of the raw bytes.

### Fixed
- Bug in Message::Base.create that ment the status was always set to zero.

## [0.2.0] - 2018-04-11
### Added
- Subscription object to handle objects subscribing to incoming messages.
- Message broker implementation.