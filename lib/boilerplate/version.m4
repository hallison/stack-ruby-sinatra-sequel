# encoding: utf-8

module Boilerplate
  VERSION   = '_VERSION'
  RELEASE   = '_RELEASE'
  TIMESTAMP = '2005-06-02 12:45:00 -0400'

  def self.version_info
    "#{name} v#{VERSION} (#{RELEASE})"
  end

  def self.version_to_h
    { :name      => name,
      :version   => VERSION,
      :semver    => VERSION.to_semver_h,
      :release   => RELEASE,
      :timestamp => TIMESTAMP }
  end
end
