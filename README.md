# simple-web-fetcher

SimpleWebFetcher is a small library to fetch any web pages you like using Selenium WebDriver.

## Setup

Before using you need to start a web driver.

```.sh
# start a docker container with Chrome
docker-compose up -d

# For MaxOS M1 User
docker-compose -f ./docker-compose_macos_m1.yml up -d
```

You can run commands on Docker like below.

```.sh
$ docker build . -t simple-web-fetcher
$ docker run --rm simple-web-fetcher --help
```

You can run your local ruby environment. It's tested by Ruby 2.7.

```sh
$ ./lib/simple_web_fetcher.rb --help
```

## Usage

You can download any web page and then save under the `/tmp/result` directory.

```.sh
$ docker run --rm simple-web-fetcher https://www.google.com https://rubygems.org
$ ls ./tmp/result
www.google.com.html rubygems.org.html
```

Using with `--metadata` options, you can see the site and previous crawing information like below.

```.sh
$ docker run --rm simple-web-fetcher --metadata https://www.google.com https://rubygems.org
site: www.google.com
num_links: 35
images: 3
last_fetch: Tue Mar 16 2021 15:46 UTC

site: rubygems.org
num_links: 35
images: 3
last_fetch: Tue Mar 26 2021 10:32 UTC
```

## Test

You can run tests like below.

```.sh
$ bundle exec rake test
```
