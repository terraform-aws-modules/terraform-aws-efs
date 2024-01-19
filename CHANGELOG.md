# Changelog

All notable changes to this project will be documented in this file.

## [1.4.0](https://github.com/terraform-aws-modules/terraform-aws-efs/compare/v1.3.1...v1.4.0) (2024-01-12)


### Features

* Added AccessedViaMountTarget condition for deny_nonsecure_transport ([#21](https://github.com/terraform-aws-modules/terraform-aws-efs/issues/21)) ([543f54c](https://github.com/terraform-aws-modules/terraform-aws-efs/commit/543f54cdf203108106d006ea693463ea463df293))

### [1.3.1](https://github.com/terraform-aws-modules/terraform-aws-efs/compare/v1.3.0...v1.3.1) (2023-11-03)


### Bug Fixes

* Use `lookup()` on computed resource attribute lookups in `for_each` loop ([#18](https://github.com/terraform-aws-modules/terraform-aws-efs/issues/18)) ([a206e43](https://github.com/terraform-aws-modules/terraform-aws-efs/commit/a206e4397871609dbf80866eb9cddd4b597075c8))

## [1.3.0](https://github.com/terraform-aws-modules/terraform-aws-efs/compare/v1.2.0...v1.3.0) (2023-09-13)


### Features

* Add lifecycle create_before_destroy to avoid timeout with security group ([#16](https://github.com/terraform-aws-modules/terraform-aws-efs/issues/16)) ([cab07ba](https://github.com/terraform-aws-modules/terraform-aws-efs/commit/cab07ba2448691c94eb192fbe5a588bcc59dfbdd))

## [1.2.0](https://github.com/terraform-aws-modules/terraform-aws-efs/compare/v1.1.1...v1.2.0) (2023-06-28)


### Features

* Added support for elastic throughput mode ([#13](https://github.com/terraform-aws-modules/terraform-aws-efs/issues/13)) ([e247e72](https://github.com/terraform-aws-modules/terraform-aws-efs/commit/e247e72ebaa816cbd46cc508ed2aaab94e03ff74))

### [1.1.1](https://github.com/terraform-aws-modules/terraform-aws-efs/compare/v1.1.0...v1.1.1) (2023-01-17)


### Bug Fixes

* Allow passing up to the maximum of 2 lifecycle policy statements ([#3](https://github.com/terraform-aws-modules/terraform-aws-efs/issues/3)) ([19f8e7c](https://github.com/terraform-aws-modules/terraform-aws-efs/commit/19f8e7cd5c8c650fbc5a06c00f7e116d95fcdb20))

## [1.1.0](https://github.com/terraform-aws-modules/terraform-aws-efs/compare/v1.0.2...v1.1.0) (2023-01-16)


### Features

* Allow users to opt out of `NonSecureTransport` policy requirement ([#7](https://github.com/terraform-aws-modules/terraform-aws-efs/issues/7)) ([3f851b1](https://github.com/terraform-aws-modules/terraform-aws-efs/commit/3f851b1ac1efe4a473b697bd287f178e09f838e0))


### Bug Fixes

* Use a version for  to avoid GitHub API rate limiting on CI workflows ([#6](https://github.com/terraform-aws-modules/terraform-aws-efs/issues/6)) ([269fa7c](https://github.com/terraform-aws-modules/terraform-aws-efs/commit/269fa7c55976e32b7b0c949deef4d729aa0b0cf2))

### [1.0.2](https://github.com/terraform-aws-modules/terraform-aws-efs/compare/v1.0.1...v1.0.2) (2022-12-09)


### Bug Fixes

* Create backup policy conditionally ([#5](https://github.com/terraform-aws-modules/terraform-aws-efs/issues/5)) ([6154c0c](https://github.com/terraform-aws-modules/terraform-aws-efs/commit/6154c0c6088d7b220f5193dc0f7809f0b7ddc921))

### [1.0.1](https://github.com/terraform-aws-modules/terraform-aws-efs/compare/v1.0.0...v1.0.1) (2022-11-07)


### Bug Fixes

* Update CI configuration files to use latest version ([#1](https://github.com/terraform-aws-modules/terraform-aws-efs/issues/1)) ([b40028d](https://github.com/terraform-aws-modules/terraform-aws-efs/commit/b40028d9d0139318764c7ef1cdac124e80c0f902))
