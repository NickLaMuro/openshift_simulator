OpenshiftSimulator
------------------
A (poorman's) lib and toolchain for emulating the HTTP responses from
[OpenShift](https://github.com/openshift), using pre-recorded
[VCR](https://github.com/vcr/vcr) cassettes for the simulated responses.

Allows for both capturing of requests from an existing OpenShift cluster, and
serving those captured requests up from and recorded cassette.


Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'openshift_simulator'
```

And then execute:

```console
$ bundle
```

Or install it yourself as:

```console
$ gem install openshift_simulator
```

If you plan on making use of the `capture` command, then you will also have to
install the [`vcr` gem](https://github.com/vcr/vcr), since it is not a hard
dependency of this gem.

If you plan on making use of the `server` command, then you will also have to
install [`rack`](https://github.com/rack/rack), since it is not a hard dependency
of this gem.


Usage
-----

### `openshift_simulator capture [-h|-u|-p|-P|-t] [URL] [ENDPOINTS..]`

Uses VCR to capture the from a openshift cluster either using the given URL, or
the options provided, and a set of endpoints to capture.

#### Options

* `-d DIR,   --dir=DIR`:           The dir to save recordings (default: pwd)
* `-H HOST,  --host=HOST`:         The URL/IP of the openshift API
* `-P PORT,  --port=PORT`:         Server port (default: 443)
* `-u USER,  --user=USER`:         The user to make the API requests with
* `-p PASS,  --pass=PASS`:         The password to make the API requests with
* `-t TOKEN, --token=token`:       The API token to make the request with
* `-o SEC,   --open-timeout=SEC`:  API Open timeout (default 60)
* `-r SEC,   --read-timeout=SEC`:  API Read timeout (default 60)


### `openshift_simulator serve(r) [-d|-P] CASSETTE_FILE`

Take a given VCR cassette file, and server it on `localhost` on a given port
(default: 8888)

#### Options

* `-d DIR,   --dir=dir`:     API response dir (default: `./tmp/openshift_simulator`)
* `-P PORT,  --port=PORT`:   Server port (default: 8888)
* `-t TOKEN, --token=TOKEN`: Global token for all endpoints
* `          --no-token`:    No token required for endpoints


TODO
----
* Add tests
* Allow running the server with basic auth (currently only token works)
* Add a capture methods (current method is `EndpointList`)
  - Consider `RubyScript` as another
* Remove needs for dependencies (use something like
  [automatiek](https://github.com/segiddins/automatiek) for that)


Acknowledgments
---------------

* [@cben](https://github.com/cben) for the idea to serve VCR cassettes via a
  webserver (I probably went a little overboard from what you had in mind)
* [@agrare](https://github.com/agrare) for the original code around capturing
  the requests coming from a ManageIQ OpenShift provider refresh


Contributing
------------

Bug reports and pull requests are welcome on GitHub at
https://github.com/NickLaMuro/openshift_simulator.
