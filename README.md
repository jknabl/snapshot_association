# snapshot_association

Store a 'snapshot' of the state of columns on a class to denormalized columns on a different class, using Rails callbacks.

## Installation

* Clone the repository:

`git clone repo_url`

* Include in Gemfile:

`gem 'snapshot_association', path: /path/to/repo`

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

To get around this, you may provide the `snapshot` directive with a `column_mapping` option. This option's value should be a hash keyed by old column names on the source table mapped to new column names on the source table. For example:

```
MAPPING = {
  email: 'new_email'
}

...

class GreatModel
  snapshot :associated_table, column_mapping: MAPPING
end
```

This will instruct the snapshot to translate any old column names found on the target table (e.g. `GreatModel.associated_table_email`) with the renamed column on the source table (e.g. `AssociatedTable.new_email`).
