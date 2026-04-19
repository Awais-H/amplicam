module Accounting
  class LedgerAdapter
    class UnsupportedAdapterError < StandardError; end

    def self.registry
      @registry ||= {}
    end

    def self.register(key, adapter)
      registry[key.to_s] = adapter
    end

    def self.fetch!(key)
      registry.fetch(key.to_s) do
        raise UnsupportedAdapterError, "No adapter registered for #{key}"
      end
    end

    def validate(_entry)
      raise NotImplementedError
    end

    def serialize(_entry)
      raise NotImplementedError
    end

    def publish(_entry)
      raise NotImplementedError
    end

    def status(_external_ref)
      raise NotImplementedError
    end
  end
end

