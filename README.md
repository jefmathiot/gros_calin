# Gros-Câlin

Share your database queries via HTTP/JSON.

[![Build Status](https://travis-ci.org/servebox/gros_calin.png)](https://travis-ci.org/servebox/gros_calin)
[![Dependency Status](https://gemnasium.com/servebox/gros_calin.png)](https://gemnasium.com/servebox/gros_calin)
[![Coverage Status](https://coveralls.io/repos/servebox/gros_calin/badge.png)](https://coveralls.io/r/servebox/gros_calin)
[![Code Climate](https://codeclimate.com/github/servebox/gros_calin.png)](https://codeclimate.com/github/servebox/gros_calin)

## Installation

Install the gem:

    $ gem install gros_calin

Depending on the drivers you'd like to use to connect your databases, you'll
also have to install one or more of the following gems (see the
_Available drivers_ section below):

* mysql2 (MySQL)
* moped (MongoDB)

## Usage

Create a configuration file (see the _Configuration_ section below), then start
the server:

    $ gros_calin

If you want to place the process in the background:

    $ gros_calin -d

By default, the server searches for a `config.yml` file in the current
directory. To point to a specific location, use the `-c` flag:

    $ gros_calin -c /path/to/config.yml

The server binds to the port `3313`, use the `-p` flag to change the port
number:

    $ gros_calin -p 8080

To stop the server, hit `Ctrl^C` or, if you placed it in the background:

    $ gros_calin stop

## Configuration

Configuration takes place in a [YAML](http://en.wikipedia.org/wiki/YAML) file.
First declare your datasources using one of the available drivers, then list the
queries you'd like to give a hug.

### HTTP endpoints

* List available datasources: `http://localhost:3313/`
* List available hugs for a datasource: `http://localhost:3313/<datasource>`
* Query a specific hug: `http://localhost:3313/<datasource>/<hug>`

### Available drivers

#### MySQL

```yaml
myapp_datasource:
  driver: "mysql"
  options:
    host: "db.example.com"
    username: "operator"
    password: "secret"
    database: "myapp"
    hugs:
      sign_ups: "SELECT count(id) AS sign_ups, country_code FROM users WHERE created_at DATE_SUB( NOW(), INTERVAL 24 HOUR) GROUP by country_code;"
# another_datasource:
```

See the [mysql2](https://github.com/brianmario/mysql2) client for a list
of [available connection
options](https://github.com/brianmario/mysql2#connection-options).

#### MongoDB

```yaml
projects_datasource:
  driver: "mongodb"
  options:
    hosts:
      - replset1.example.com:27017
      - replset2.example.com:27017
      - replset3.example.com:27017
    username: "operator"
    password: "secret"
  hugs:
    issues: "db.projects.find( { score: { $lt: 3.8 } } ).sort(score: -1).toArray()"
    status: "{ failures: db.projects.find( { status: 'failed' } ).count(), success: db.projects.find( { status: 'success' } ).count() }"
    average_score: "db.builds.aggregate( { $group: { _id: '$project_id', builds: { $avg: '$score' } } }).result"
# another_datasource:
```

## Frequently asked questions

### Is it fast?

Well, it depends.

### Does it scale?

It can serves up to a billion RPM (you'll have to rewrite it in Erlang, though).

### "Gros-Câlin"?

Gros-Câlin (_Big Cuddle_) is named after the eponymous novel written by Romain
Gary under the pen name Émile Ajar. In the book, M. Cousin, a statistician,
lives with a python which hugs him tight and helps him cope with loneliness.

![Romain Gary](https://raw.github.com/servebox/gros_calin/master/romain-gary.jpg)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
