# snapshot_association

[![CircleCI](https://circleci.com/gh/jknabl/snapshot_association/tree/master.svg?style=shield&circle-token=3dd0f45013526a0c1b31d8b137cf0e330fa605a8)](https://circleci.com/gh/jknabl/snapshot_association/tree/master)

Store a 'snapshot' of the state of columns on a class to denormalized columns on a different class, using Rails callbacks.

## Installation

If you plan to make local modifications to the code, you can do:

* Clone the repository:

`git clone git@github.com:jknabl/snapshot_association.git`

* Include in Gemfile:

`gem 'snapshot_association', path: /path/to/repo`

Otherwise, just include in your Gemfile directly from Github:

`gem 'snapshot_association', git: git@github.com:jknabl/snapshot_association.git`

## Usage

Include the `snapshot` directive followed by a table name in a model definition:

```
class GreatModel < ApplicationRecord

  has_many :associated_tables
  snapshot :associated_table
  ...
end
```

This will import any data in columns on AssociatedTable into matching columns prefixed by associated_table_ on GreatModel.

For example if you had:

* `AssociatedTable(name: string, email: string)`
* `GreatModel(associated_table_name: string, associated_table_email: string)`

...then the `name` and `email` columns would be snapshotted from AssociatedTable onto GreatModel.

### Column mappings

Say you have snapshot columns on a target table, but you've since refactored column names on a source table. For example you might have:

* `AssociatedTable(name: string, new_email: string)`
* `GreatModel(associated_table_name: string, associated_table_email: string)`

The mapping between `AssociatedTable.new_email` and `GreatModel.associated_table_email` would be lost here.

To get around this, you may provide the `snapshot` directive with a `column_mapping` option. This option should be a hash keyed by column names on the snapshot table with corresponding column names on the target table as values. For example:

```
class GreatModel

  MAPPING = {
    new_email: 'associated_table_email'
  }.freeze

  snapshot :associated_table, column_mapping: MAPPING
end
```

This will instruct the snapshot to translate any old column names found on the target table (e.g. `GreatModel.associated_table_email`) with the renamed column on the source table (e.g. `AssociatedTable.new_email`).
