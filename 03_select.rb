require 'active_record'
require 'sequel'
require 'benchmark'
require 'pg'
require 'logger'
require 'rom'
require 'rom-sql'
require 'rom-repository'

Benchmark.bm do |x|
  x.report('ActiveRecord'.ljust(15)) do
    class User < ActiveRecord::Base
      establish_connection("postgres:///brainwashing_users")
      self.table_name="users_ar"
    end

    User.all.to_a
  end

  x.report("Sequel".ljust(15)) do
    DB = Sequel.postgres("brainwashing_users")
    DB[:users_sequel].all.to_a
  end

  x.report("Sequel ORM".ljust(15)) do
    DB2 = Sequel.postgres("brainwashing_users")
    class SequelUser < Sequel::Model(DB2[:users_sequel])
    end

    SequelUser.dataset.all.to_a
  end

  x.report("ROM".ljust(15)) do
    rom = ROM.container(:sql, "postgres:///brainwashing_users") do |conf|
      class Users < ROM::Relation[:sql]
        schema(:users_rom, infer: true, as: :users)
      end

      conf.register_relation(Users)
    end

    rom.relations[:users].dataset.all.to_a
  end
end
