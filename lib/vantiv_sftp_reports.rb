# frozen-string-literal: true

require 'csv'
require 'net/sftp'
require 'vantiv_sftp_reports/config'
require 'vantiv_sftp_reports/fetch'
require 'vantiv_sftp_reports/version'

module VantivSFTPReports
  class << self
    attr_reader :default_config, :default_fetch

    def call(*args)
      default_fetch.(*args)
    end
    alias fetch call

    def configure(config = env_config)
      @default_config = Config.with_obj(config)
      @default_fetch = Fetch.new(@default_config)
    end

    def env_config
      ENV.each_with_object({}) do |(k, v), h|
        next unless k.index('vantiv_sftp_') == 0
        h[k[12..-1].to_sym] = v
      end
    end

    def first(*args)
      default_fetch.first(*args)
    end
  end
  configure
end
