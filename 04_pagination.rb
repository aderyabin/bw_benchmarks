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
      self.table_name="users_sequel"
    end

    User.find_each do |user|
      user
    end
  end

  x.report("Sequel".ljust(15)) do
    DB = Sequel.postgres("brainwashing_users")
    DB.extension :pagination

    DB[:users_sequel].each_page(1000).each do |dataset|
        dataset.each { |user| user }
    end
  end

  x.report("Sequel Cursor".ljust(15)) do
    DB2 = Sequel.postgres("brainwashing_users")
    DB2[:users_sequel].use_cursor(rows_per_fetch: 1000).each { |user| user }
  end

  x.report("ROM".ljust(15)) do
    rom = ROM.container(:sql, "postgres:///brainwashing_users") do |conf|
      class Users < ROM::Relation[:sql]
        schema(:users_rom, infer: true, as: :users)
      end

      conf.register_relation(Users)
    end

    rom.relations[:users].dataset.all.each{|el| el; }
  end
end
