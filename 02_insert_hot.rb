require 'json'
require 'active_record'
require 'sequel'
require 'benchmark'
require 'pg'
require 'rom'
require 'rom-sql'
require 'rom-repository'

json = JSON.parse(File.read('data.json'))

# AR
ActiveRecord::Base.establish_connection("postgres:///brainwashing_users")

columns = json.first.keys
values_list = json.map do |hash|
  hash.values.map do |value|
    ActiveRecord::Base.connection.quote(value)
  end
end

class User < ActiveRecord::Base
  self.table_name = :users_ar
end

# SEQUEL
DB = Sequel.postgres("brainwashing_users")

# ROM
rom = ROM.container(:sql, "postgres:///brainwashing_users") do |conf|
  class Users < ROM::Relation[:sql]
    schema(:users_rom, infer: true, as: :users)
  end

  conf.register_relation(Users)
end

Benchmark.bm do |x|
  x.report('SQL'.ljust(15)) do
    ActiveRecord::Base.connection.execute <<-SQL
      INSERT INTO users_sql (#{columns.join(",")}) VALUES
      #{values_list.map {|values| "(#{values.join(",")})" }.join(", ") }
    SQL
  end

  x.report('Arel'.ljust(15)) do
    json.each do |hash|
      insert          = Arel::Nodes::InsertStatement.new
      insert.relation = Arel::Table.new(:users_arel)
      insert.columns  = hash.keys.map {|k| Arel::Table.new(:users_arel)[k] }
      insert.values   = Arel::Nodes::Values.new(hash.values)
      ActiveRecord::Base.connection.execute(insert.to_sql)
    end
  end

  x.report('ActiveRecord'.ljust(15)) do
    User.create(json)
  end

  x.report("Sequel".ljust(15)) do
    DB[:users_sequel].multi_insert(json)
  end

  x.report("ROM".ljust(15)) do
    rom.relations[:users].multi_insert(json)
  end
end
