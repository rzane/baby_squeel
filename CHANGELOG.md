## [Unreleased]

- Added Ruby 3.3 and 3.4 to test matrix
- Droped support for Ruby 3.0 and 3.1

## [3.0.0] - 2023-11-20

- Added support for ActiveRecord 7.1 (#125)
- Added support for Ruby 3.2 (#128)
- Updated ransack to 4.1. (#126)
- Droped support for Ruby 2.6 and 2.7. (#126)
- Droped support for ActiveRecord 6.0. (#126)

## [2.0.0] - 2022-08-28

- AR 6.1: fix - FrozenError: can't modify frozen object: []
- Drop support for ActiveRecord older than 6.0.

## [1.4.4] - 2022-02-07

### Fixed

- Nested merge-joins query causes NoMethodError with ActiveRecord 6.1.4.4 (#119)

## [1.4.3] - 2022-02-04

### Fixed

- ActiveRecord::Relation#left_joins performs INNER JOIN on Active Record 6.1 (#118)

## [1.4.2] - 2022-01-24

### Fixed

- Added support for activerecord 7.0 (#116)
- Added support for activerecord 6.1 (#116)
- Added support for activerecord 6.0 (#116)

## [1.4.1] - 2021-06-17

### Fixed

- Fixed a bug related to checking the Active Record version.

## [1.4.0] - 2021-06-17

### Fixed

- Fix table alias when joining a polymorphic table twice (#108)
- Removed internal class `BabySqueel::Pluck`. You can still use `plucking`. For example, `Post.joining { author }.plucking { author.name }`
- Removed old code from Active Record < 5.2
- Removed dependency `join_dependency`

## [1.4.0.beta1] - 2021-04-21

### Fixed

- Add Support for activerecord '>= 5.2.3'
- Drop Support for Active Record versions that have reached EOL (activerecord < 5.2)
- Use polyamorous from ransack '~> 2.3'

## [1.3.1] - 2018-05-15

### Fixed

- Upgraded `join_dependency` requirement, which fixes [issue #1](https://github.com/rzane/join_dependency/issues/1).

## [1.3.0] - 2018-05-04

### Added

- The ability to use `plucking` with an array of nodes. For example, `User.plucking { [id, name] }`.

## [1.2.1] - 2018-04-25

### Fixed

- Added support for Active Record 5.2

## [1.2.0] - 2017-10-20

### Added

- `reordering`, which is just a BabySqueel version of Active Record's `reorder`.
- `on` expressions can now be given a block that will yield the current node (#77).

## [1.1.5] - 2017-05-26

### Fixed

- Returning an empty hash from a `where.has {}` block would generate invalid SQL (#69).

## [1.1.4] - 2017-04-13

### Fixed

- Nodes::Attribute#in and #not_in generate valid SQL when given ActiveRecord::NullRelations.

## [1.1.3] - 2017-03-31

### Fixed

- Nodes::Attribute#in was not returning BabySqueel node. As a result, you couldn't chain on it. This fixes #61.

## [1.1.2] - 2017-03-21

### Fixed

- Check if a reflection has a parent reflection before comparing them. This fixes #56.

### Refactored

- The logic encapsulated in `#method_missing` and `#respond_to_missing?` was difficult to follow, because it was falling back to `super`, sometimes going up the inheritance tree multiple levels. The addition of `BabySqueel::Resolver` now handles this a little more gracefully.

## [1.1.1] - 2017-02-14

### Fixed

- There is a bug in Active Record where the `AliasTracker` initializes `Arel::Table`s use the wrong `type_caster`. To address this, BabySqueel must re-initialize the `Arel::Table` with the correct `type_caster` (#54).

## [1.1.0] - 2017-02-10

> This version drops support for Active Record 4.1. If you're stil on 4.1, you should seriously consider upgrading to at least 4.2.

### Added

- DSLs for ActiveRecord::Relation::Calculations. You can now use `plucking`, `counting`, `summing`, `averaging`, `minimizing`, and `maximizing`.

## [1.0.3] - 2017-02-09

### Added

- Support for `pluck`.
- Support for `not_in`.

## [1.0.2] - 2017-02-07

### Added

- `BabySqueel::Association` now has `#==` and `#!=`. This is only supported for Rails 5+. Example: `Post.where { author: Author.last }`.

### Fixed

- Incorrect alias detection caused by not tracking the full path to a join (#37).

## [1.0.1] - 2016-11-07

### Added

- Add DSL#\_ for wrapping expressions in Arel::Node::Grouping. Thanks to [@odedniv].

### Fixed

- Use strings for attribute names like Rails does. Symbols were preventing things like `unscope` from working. Thanks to [@chewi].
- `where.has {}` will now accept `nil`.
- Arel::Nodes::Function did not previously include Arel::Math, so now you can do math operations on the result of SQL functions.
- Arel::Nodes::Binary did not previously include Arel::AliasPredication. Binary nodes can now be aliased using `as`.

## [1.0.0] - 2016-09-09

### Added

- Polyamorous. Unfortunately, this _does_ monkey-patch Active Record internals, but there just isn't any other reliable way to generate outer joins. Baby Squeel, itself, will still keep monkey patching to an absolute minimum.
- Within DSL blocks, you can use `exists` and `not_exists` with Active Record relations. For example: `Post.where.has { exists Post.where(title: 'Fun') }`.`
- Support for polymorphic associations.

### Deprecations

- Removed support for Active Record 4.0.x

### Changed

- BabySqueel::JoinDependency is no longer a class responsible for creating Arel joins. It is now a namespace for utilities used when working with the ActiveRecord::Association::JoinDependency class.
- BabySqueel::Nodes::Generic is now BabySqueel::Nodes::Node.
- Arel nodes are only extended with the behaviors they need. Previously, all Arel nodes were being extended with `Arel::AliasPredication`, `Arel::OrderPredications`, and `Arel::Math`.

### Fixed

- Fixed deprecation warnings on Active Record 5 when initializing an Arel::Table without a type caster.
- No more duplicate joins. Previously, Baby Squeel did a very poor job of ensuring that you didn't join an association twice.
- Alias detection should now _actually_ work. The previous implementation was naive.

## [0.3.1] - 2016-08-02

### Added

- Ported backticks and #my from Squeel

### Changed

- DSL#sql now returns a node wrapped in a BabySqueel proxy.

## [0.3.0] - 2016-06-26

### Added

- Added Squeel compatibility mode that allows `select`, `order`, `joins`, `group`, `where`, and `having` to accept DSL blocks.
- Added the ability to query tables that aren't backed by Active Record models.
- Added `BabySqueel::[]`, which provides a `BabySqueel::Relation` for models, or a `BabySqueel::Table` for symbols/strings.

### Changed

- Renamed `BabySqueel::Association::AliasingError` to `BabySqueel::AssociationAliasingError`.

## [0.2.2] - 2016-03-30

### Added

- Support for `group` (`grouping`) and `having` (`when_having`).
- Support for sifters.
- Added `quoted` and `sql` helpers for quoting strings and SQL literals.
- More descriptive error messages when a column or association is not found.

### Fixed

- `Arel::Nodes::Grouping` does not include `Arel::Math`, so operations like `(id + 5) + 3` would fail unexpectedly.
- Fix missing bind values When joining through associations with default scope.
- Removed `ActiveRecord::VERSION` specific handling of the `WhereChain`.

## [0.2.1] - 2016-03-27

### Added

- Support for subqueries.

### Fixed

- Some Arel nodes did not have access to `as` expressions.

## [0.2.0] - 2016-03-25

### Added

- References to aliased joins in a `select`, `where`, or `order` expression now use the aliased table name.

### Changed

- Rely on `ActiveRecord::Relation#join_sources` for the implicit construction of join nodes, rather than using the `ActiveRecord::Associations::JoinDependency` directly.

### Fixed

- Associations referencing the same table weren't being aliased.

## [0.1.0] - 2016-03-16

### Added

- Initial support for selects, orders, wheres, and joins.

[unreleased]: https://github.com/rzane/baby_squeel/compare/v3.0.0...HEAD
[3.0.0]: https://github.com/rzane/baby_squeel/compare/v2.0.0...v3.0.0
[2.0.0]: https://github.com/rzane/baby_squeel/compare/v1.4.4...v2.0.0
[1.4.4]: https://github.com/rzane/baby_squeel/compare/v1.4.3...v1.4.4
[1.4.3]: https://github.com/rzane/baby_squeel/compare/v1.4.2...v1.4.3
[1.4.2]: https://github.com/rzane/baby_squeel/compare/v1.4.1...v1.4.2
[1.4.1]: https://github.com/rzane/baby_squeel/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/rzane/baby_squeel/compare/v1.4.0.beta1...v1.4.0
[1.4.0.beta1]: https://github.com/rzane/baby_squeel/compare/v1.3.1...v1.4.0.beta1
[1.3.1]: https://github.com/rzane/baby_squeel/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/rzane/baby_squeel/compare/v1.2.1...v1.3.0
[1.2.1]: https://github.com/rzane/baby_squeel/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/rzane/baby_squeel/compare/v1.1.5...v1.2.0
[1.1.5]: https://github.com/rzane/baby_squeel/compare/v1.1.4...v1.1.5
[1.1.4]: https://github.com/rzane/baby_squeel/compare/v1.1.3...v1.1.4
[1.1.3]: https://github.com/rzane/baby_squeel/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/rzane/baby_squeel/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/rzane/baby_squeel/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/rzane/baby_squeel/compare/v1.0.3...v1.1.0
[1.0.3]: https://github.com/rzane/baby_squeel/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/rzane/baby_squeel/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/rzane/baby_squeel/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/rzane/baby_squeel/compare/v0.3.1...v1.0.0
[0.3.1]: https://github.com/rzane/baby_squeel/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/rzane/baby_squeel/compare/v0.2.2...v0.3.0
[0.2.2]: https://github.com/rzane/baby_squeel/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/rzane/baby_squeel/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/rzane/baby_squeel/compare/v0.1.0...v0.2.0
[@chewi]: https://github.com/chewi
[@odedniv]: https://github.com/odedniv
