# frozen-string-literal: true

require 'csv'
require 'vantiv_sftp_reports/config'
require 'net/ssh/proxy/http'

module VantivSFTPReports
  class Fetch
    class << self
      %i[call download list].each do |m|
        define_method(m) { |*args| new.__send__(m, *args) }
      end
    end

    attr_reader :config

    def initialize(config = VantivSFTPReports.default_config)
      @config = Config.with_obj(config)
    end

    def call(*args)
      download(*list(*args)).each_with_object({}) do |(filename, csv), h|
        next unless csv
        h[filename] = parse_report(csv)
      end
    end

    def download(*filenames)
      {}.tap do |h|
        session do |sftp|
          filenames.each { |fname| h[fname] = sftp.download!("#{path}/#{fname}") }
        end
      end
    end

    def first(*args)
      (report = call(*args).first) && report.last
    end

    def list(pattern = nil, by_date: Date.today, by_organization_id: organization_id)
      [].tap do |list|
        session { |sftp| sftp.dir.foreach(path) { |e| list << e.name unless e.name[0] == '.' } }
        filter_by_date!(list, by_date) if by_date
        filter_by_organization_id!(list, by_organization_id) if organization_id
        filter_by_pattern!(list, pattern) if pattern
      end
    end

    def session
      sftp_opts = config.sftp_opts
      sftp_opts.merge!(proxy: proxy).delete(:proxy_url) if sftp_opts[:proxy_url]
      Net::SFTP.start(config.host, config.username, sftp_opts) { |sftp| yield(sftp) }
    end

    %i[organization_id path].each { |m| define_method(m) { config.__send__(m) } }

    private

    def proxy
      return nil unless config.proxy_url
      uri = URI(config.proxy_url)
      Net::SSH::Proxy::HTTP.new(uri.host, uri.port)
    end

    def date_str(obj)
      obj.respond_to?(:strftime) ? obj.strftime('%Y%m%d') : obj.to_s
    end

    def filter_by_date!(list, dates)
      list.select! { |r| r =~ /_(#{Array(dates).map { |d| date_str(d) }.join('|')})\.CSV\Z/ }
    end

    def filter_by_organization_id!(list, organization_id)
      list.select! { |r| r =~ /_#{organization_id}_/ }
    end

    def filter_by_pattern!(list, pattern)
      pattern = pattern.is_a?(Regexp) ? pattern : /^#{pattern}/i
      list.select! { |r| r =~ pattern }
    end

    # To avoid numberic conversion, IDs from Vantiv are prefixed with a single
    # quote. Since no conversions are done here, this is nothing but an
    # inconvenience and is stripped.
    def parse_report(str)
      CSV.parse(str.gsub(/'(\d{18})/, '\1'), headers: true, header_converters: :symbol)
    end
  end
end
