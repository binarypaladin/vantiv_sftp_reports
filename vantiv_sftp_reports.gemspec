require File.expand_path('lib/vantiv_sftp_reports/version', __dir__)

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.2.0'

  s.name          = 'vantiv_sftp_reports'
  s.version       = VantivSFTPReports.version
  s.authors       = %w[Joshua Hansen]
  s.email         = %w[joshua@epicbanality.com]

  s.summary       = 'Report Processing for WorldPay/Vantiv/LitleOnline'
  s.description   = s.summary
  s.homepage      = 'https://github.com/binarypaladin/vantiv_sftp_reports'
  s.license       = 'MIT'

  s.files         = %w[LICENSE.txt README.md] + Dir['lib/**/*.rb']
  s.require_paths = %w[lib]

  s.add_dependency             'net-sftp', '~> 2.1.2'
  s.add_development_dependency 'bundler',  '~> 1.16'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'rake',     '~> 10.0'
  s.add_development_dependency 'rubocop',  '~> 0.56'
end
