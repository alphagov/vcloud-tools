vCloud Tools
============
A collection of tools for provisioning in vCloud Director.

vCloud Tools is a meta-gem that depends on the tools listed below.

You can install the individual gems you require, or you can include or install vcloud-tools which will give you all of the below.

## vCloud Launcher

A tool that takes a YAML configuration file describing a vDC, and provisions
the vApps and VMs contained within.

( [gem in RubyGems](http://rubygems.org/gems/vcloud-launcher) | [code on GitHub](https://github.com/alphagov/vcloud-launcher) )


## vCloud Net Launcher

A tool that takes a YAML configuration file describing vCloud networks and configures each of them.

( [gem in RubyGems](http://rubygems.org/gems/vcloud-net_launcher) | [code on GitHub](https://github.com/alphagov/vcloud-net_launcher) )

## vCloud Walker
A gem that reports on the current state of an environment.

( [gem in RubyGems](http://rubygems.org/gems/vcloud-walker) | [code on GitHub](https://github.com/alphagov/vcloud-walker) )

## vCloud Edge Gateway
A gem to configure a VMware vCloud Edge Gateway.

( [gem in RubyGems](http://rubygems.org/gems/vcloud-edge_gateway) | [code on GitHub](https://github.com/alphagov/vcloud-edge_gateway) )

## vCloud Core

The gem that handles the interaction with the vCloud API, via [Fog](http://fog.io/).

vCloud Core also comes with command line tool, vCloud Query, which exposes the vCloud Query API.

( [gem in RubyGems](http://rubygems.org/gems/vcloud-core) | [code on GitHub](https://github.com/alphagov/vcloud-core) )

Required set-up
===============

## Credentials

vCloud Tools is based around [fog]. To use it you'll need to give it
credentials that allow it to talk to a VMware environment.

### Step 1. Create a `.fog` file containing your credentials

To use this method, you need a `.fog` file in your home directory.

For example:

    test:
      vcloud_director_username: 'username@org_name'
      vcloud_director_password: 'password'
      vcloud_director_host: 'host.api.example.com'

Multiple sets of credentials can be specified in the fog file, using
the following format:

    test:
      vcloud_director_username: 'username@org_name'
      vcloud_director_password: 'password'
      vcloud_director_host: 'host.api.example.com'

    test2:
      vcloud_director_username: 'username@org_name'
      vcloud_director_password: 'password'
      vcloud_director_host: 'host.api.vendor.net'

You can then pass the `FOG_CREDENTIAL` environment variable at the
start of your command. The value of the `FOG_CREDENTIAL` environment
variable is the name of the credential set in your fog file which you
wish to use.  For instance:

    FOG_CREDENTIAL=test2 bundle exec vcloud-launch node.yaml

The fog documentation has more details in the "Credentials" section of
the [getting started guide](http://fog.io/about/getting_started.html).

### Step 2 (optional). Log on externally and supply your session token

Rather than specifying your password in your `.fog` file, you can
instead log on externally with the API and supply your session token
to the tool via the `FOG_VCLOUD_TOKEN` environment variable. This
option reduces risk by not requiring the user's plaintext password to
be stored on disk. Note, however, that you still need a
`vcloud_director_password` entry in your `.fog` file; it will be ignored
(so set it to `"FAKE"` or something like that) but fog will blow up if
it's not present at all.

The default token lifetime is '30 minutes idle' - any activity
extends the life by another 30 mins.

A basic example of this would be the following:

    curl
       -D-
       -d ''
       -H 'Accept: application/*+xml;version=5.1' -u '<user>@<org>'
       https://host.com/api/sessions

This will prompt for your password.

From the headers returned, select the header below

     x-vcloud-authorization: AAAABBBBBCCCCCCDDDDDDEEEEEEFFFFF=

Use token as ENV var FOG_VCLOUD_TOKEN

    FOG_VCLOUD_TOKEN=AAAABBBBBCCCCCCDDDDDDEEEEEEFFFFF= bundle exec ...

## Contributing

Contributions are very welcome. Please see the individual tools for contributing guidelines.
