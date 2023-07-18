# Changelog
## [Unreleased]
## [ 2.1.1 ] - 2023-07-18
### Added
* New option (`-s`) for declaring interleaved (collated) paired-end file input. In this mode when a read is identified as human the pair mate will also be masked *whether or not it too is identified as human*. Without this flag an interleaved (collated) paired-end input file will only have identified reads masked.
* New option (`-u`) for user-defined removed-spots file (in combination with `-r`).

## [ 2.1.0 ] - 2023-05-10
### Changed
* Added an md5 check with download of database
* `init_db.sh` will also check for and install updated database (with md5 check).
* Test output includes the database version if available and not a custom installation.

## [ 2.0.0 ] - 2022-08-31
### Changed
* #### Make masking read sequence to 'N' default (!)
### Removed
* #### `-n` option removed (now default).
### Added
* #### New option (`-x`) to remove read sequence instead of masking.
* New option to set number of threads (`-p`).

## [ 1.1.0 ] - 2021-11-10
### Changed
* Added useful options and fixed path (thank you k-florek).

## [ 1.0.0 ] - 2021-05-05
#### Added, first GitHub release.
