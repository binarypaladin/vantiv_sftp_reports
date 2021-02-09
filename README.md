# Vantiv SFTP Reports

Are you using WorldPay/Vantiv/LitleOnline and need to actually resolve what happened with a particular transaction or just need to be able to consume data about what's going on in a programmatic way? Funny story about that...

The eCommerce "solution" (Vantiv's CNP API aka LitleOnline) provides no APIs for handling this because who on earth would actually want to get to their data via an API and have historical access, right? It gets better though because their hosted payments solution---a solution designed for people trying to avoid API integrations---actually has an API for this sort of thing. Does this make any sense? No. No, it does not.

With that said, let's party like it's 1999! (At least SFTP was made in this century I guess.) You can make like a digital Neanderthal and download report files over SFTP, parse CSVs, and get whatever you need.

(If you ever wondered why [Stripe](https://stripe.com) is so successful, this sort of absurdity has something to do with it. They actually get that developers are a thing.)

This library is meant to be pretty low level. It just handles some basic configuration, downloading, and parsing. It is not meant to care about the particulars of how those reports are consumed, related, or even which reports you have enabled.

## Installation

The usual:

    $ gem install vantiv_sftp_reports

## Configuration

As there is no sandbox for testing this, you're going to need to do a bit of configuring to get anything out of this. This gem supports managing multiple configurations, but the vast majority of use cases revolve around a single default configuration.

I can be set one of two ways:

## Use a Hash

```ruby
VantivSFTPReports.configure(
  host:,            # SFTP host, defaults to 'reports.iq.vantivcnp.com'
  organization_id:, # Organization ID for reports, leave blank if you only have one organization
  password:,        # Your SFTP username
  path:,            # Directory where reports are stored, defaults to 'reports'
  port:,            # SFTP port, defaults to '22'
  proxy_url:,       # A proxy host to use for the SSH session, useful if you need to fetch reports from a server not directly whitelisted in your Vantiv account setup
  username:         # Your SFTP username
)
```

This sets the default configuration (`VantivSFTPReports.default_config`).

## Infer Values from `ENV`

Prefix any configuration option with `vantiv_sftp_` and it will be automatically set:

* `ENV['vantiv_sftp_host']`
* `ENV['vantiv_sftp_organization_id']`
* `ENV['vantiv_sftp_password']`
* `ENV['vantiv_sftp_path']`
* `ENV['vantiv_sftp_port']`
* `ENV['vantiv_sftp_proxy_url']`
* `ENV['vantiv_sftp_username']`

## Usage

The `VantivSFTPReports::Fetch` class is used for actually getting reports. In a nutshell it takes information about the reports you're looking for, downloads the files, and parses the CSVs provided into [`CSV::Table`](https://ruby-doc.org/stdlib-2.2.7/libdoc/csv/rdoc/CSV/Table.html) objects. Each instance of `Fetch` can be loaded with a custom configuration, but if none is given will use the default global configuration.

So, if you're supporting multiple logins you can use:

```ruby
fetch1 = VantivSFTPReports::Fetch.new(username: 'user1')
fetch2 = VantivSFTPReports::Fetch.new(username: 'user2')
```

A fetch object will pull down reports by name, date, and organization ID. So, if you wanted to get a report named `Transactional_Detail_SessionByActivityDate` for the last 3 days for organization `1234` you could do the following:

```ruby
reports = VantivSFTPReports::Fetch.new.call(
  'Transactional_Detail_SessionByActivityDate',
  by_date: (Date.today - 2)..Date.today,
  by_organization_id: '1234'
)
```

If you're using a single configuration and don't need to anything particularly sophisticated, you can use the following abbreviated method:

```ruby
reports = VantivSFTPReports.fetch(*args)
```

## A Specific Example

Let's say I wanted to get the batch ID associated with a transaction ID from yesterday:

```ruby
report = VantivSFTPReports.first(
  'Transactional_Detail_SessionByActivityDate',
  by_date: (Date.today - 1)
) # returns only one report regardless of results

report.each_with_object({}) { |r, h| h[r[:vantiv_payment_id]] = r[:batch_id] }
```

## Testing with Sandbox or Prelive

So far as I know, there is no way to test the reporting features with the sandbox. There are no sample reports. Furthermore, while this **might** be possible using Prelive, the customer service team I've dealt with is still "looking into that™".

## What about the actual APIs that do exist?

I have a [low dependency gem for that](https://github.com/binarypaladin/vanitv_lite) that doesn't force you to use ActiveSupport and is XML library agnostic.

Or, you can always use [the official one](https://github.com/Vantiv/litle-sdk-for-ruby).

## Contributing

### Issue Guidelines

GitHub issues are for bugs, not support. As of right now, there is no official support for this gem. You can try reaching out to the author, [Joshua Hansen](mailto:joshua@epicbanality.com?subject=VantivSFTPReports) if you're really stuck, but there's a pretty high chance that won't go anywhere at the moment or you'll get a response like this:

> Hi. I'm super busy. It's nothing personal. Check the README first if you haven't already. If you don 't find your answer there, it's time to start reading the source. Have fun! Let me know if I screwed something up.

### Pull Request Guidelines

* Include tests with your PRs.
* Run `rubocop` to ensure your style fits with the rest of the project.

## License

See [`LICENSE.txt`](LICENSE.txt).

## What if I stop maintaining this?

The codebase isn't huge. If you opt to rely on this code and I die/get bored/find enlightenment you should be able to maintain it. Sadly, that's the only guarantee at the moment!
