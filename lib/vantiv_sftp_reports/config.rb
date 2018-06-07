# frozen-string-literal: true

module VantivSFTPReports
  class Config
    def self.with_obj(config)
      config.is_a?(self) ? config : new(config)
    end

    def initialize(**opts)
      @opts = opts.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
      @sftp_opts = opts.reject { |k, _| %i[host organization_id path username].include?(k) }
      defaults!
    end

    def opts
      @opts.dup
    end

    def sftp_opts
      @sftp_opts.dup
    end

    def with(**opts)
      self.class.new(@opts.merge(opts))
    end

    %i[host organization_id password path username].each { |o| define_method(o) { @opts[o] } }

    private

    def defaults!
      @opts[:host] ||= 'reports.iq.vantivcnp.com'
      @opts[:path] ||= 'reports'
    end
  end
end
