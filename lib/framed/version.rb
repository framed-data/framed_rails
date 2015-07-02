# encoding: utf-8

module Framed
  module VERSION
    def self.build_version_string(*parts)
      parts.compact.join('.')
    end

    MAJOR = 0
    MINOR = 1
    TINY  = 0

    STRING = build_version_string(MAJOR, MINOR, TINY)
  end
end