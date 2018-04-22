# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Message#to_h converts messages into a Hash format that include their data and timestamp.
- Matcher#match accepts a message and yields it in case of a match.

### Changed
- Improved the documentation.
- Matcher#match? now also accepts a Hash.
- Broker#publish now accepts raw messages and handles the conversion into message objects.
- Broker#publish no longer accepts an array.

## [0.2.2] - 2018-04-18
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