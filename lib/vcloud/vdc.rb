module Vcloud
  class Vdc

    attr_reader :id

    def self.get_by_name(name)

      fsi = Vcloud::FogServiceInterface.new
      unless body = fsi.vdc(name)
        raise "Could not find vDC named '#{name}'"
      end
      self.new(body[:href].split('/').last)
    end

    def initialize(id)
      @id = id
    end

  end
end
