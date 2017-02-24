# frozen_string_literal: true
require 'noid'

module ActiveFedora
  module Noid
    module Minter
      class Db < Base
        def read
          filtered_hash = instance.as_json.slice(*%w(template counters seq rand namespace))
          filtered_hash['counters'] = JSON.parse(filtered_hash['counters'], symbolize_names: true) if filtered_hash['counters']
          filtered_hash.symbolize_keys
        end

        def write!(minter)
          # namespace and template are the same, now update the other attributes
          instance(true).update_attributes!(
            seq: minter.seq,
            counters: JSON.generate(minter.counters),
            rand: Marshal.dump(minter.instance_variable_get(:@rand))
          )
        end

        protected

        # Uses pessimistic lock to ensure the record fetched is the same one updated.
        # Should be fast enough to avoid terrible deadlock.
        # Must lock because of multi-connection context! (transaction is per connection -- not enough)
        # The DB table will only ever have at most one row per namespace.
        # The 'default' namespace row is inserted by `rails generate active_fedora:noid:seed` or autofilled by instance below.
        # If you want another namespace, edit your config initialzer to something like:
        #     ActiveFedora::Noid.config.namespace = 'druid'
        #     ActiveFedora::Noid.config.template = '.reeedek'
        # and in your app run:
        #     bundle exec rails generate active_fedora:noid:seed
        def next_id
          id = nil
          MinterState.transaction do
            state = read
            minter = ::Noid::Minter.new(state)
            id = minter.mint
            write!(minter)
          end # transaction
          id
        end

        # @param [Boolean] lock whether the returned object (row) should be locked for update or not
        # @return [MinterState]
        def instance(lock = false)
          state = lock ? MinterState.lock : MinterState
          state.find_by!(
            namespace: ActiveFedora::Noid.config.namespace,
            template: ActiveFedora::Noid.config.template
          )
        rescue ActiveRecord::RecordNotFound
          MinterState.seed!(
            namespace: ActiveFedora::Noid.config.namespace,
            template: ActiveFedora::Noid.config.template
          )
        end
      end # class Db
    end
  end
end
