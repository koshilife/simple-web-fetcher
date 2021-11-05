# simple-web-fetcher

[![Test](https://github.com/koshilife/simple-web-fetcher/workflows/Test/badge.svg)](https://github.com/koshilife/simple-web-fetcher/actions?query=workflow%3ATest)
[![license](https://img.shields.io/github/license/koshilife/simple-web-fetcher)](https://github.com/koshilife/simple-web-fetcher/blob/master/LICENSE.txt)

SimpleWebFetcher is a small library to fetch any web pages you like using Selenium WebDriver.

## Setup

### Docker Environment

If you use Docker, you can run this tool quickly.

```.sh
$ git clone git@github.com:koshilife/simple-web-fetcher.git
$ cd simple-web-fetcher

$ docker build . -t simple-web-fetcher
$ docker run --rm simple-web-fetcher --help
Usage: simple_web_fetcher.rb [options] http://example.com/one.html [http://example.com/two.html]
        --metadata                   Prints the metadata of website when fetching
        --debug                      Prints debug level logs
    -v, --version                    Prints the SimpleWebFetcher version
    -h, --help                       Prints this help
```

### Else Environment

Without using Docker, you can use this tool in your environment.
Before using this tool, you need to setup [chromedriver](https://chromedriver.chromium.org/downloads).
You can check whether chromedriver is available or not like below.

```
$ chromedriver --version
ChromeDriver 94.0.4606.41 (333e85df3c9b656b518b5f1add5ff246365b6c24-refs/branch-heads/4606@{#845})
```

If chromedriver is ready, you can install and then use run this tool like below.

```sh
$ git clone git@github.com:koshilife/simple-web-fetcher.git
$ cd simple-web-fetcher

$ ./lib/simple_web_fetcher.rb --help
Usage: simple_web_fetcher.rb [options] http://example.com/one.html [http://example.com/two.html]
        --metadata                   Prints the metadata of website when fetching
        --debug                      Prints debug level logs
    -v, --version                    Prints the SimpleWebFetcher version
    -h, --help                       Prints this help
```

## Usage

You can download any web pages and after execute it will save to `/tmp/downloads` directory.

```.sh
#
# Docker environment
#
$ docker run --rm -v ${HOME}/.simple-web-fetcher:/app/tmp simple-web-fetcher https://rubygems.org https://www.google.com
$ ls ${HOME}/.simple-web-fetcher/downloads
rubygems.org_20211104_163243.html       www.google.com_20211104_163241.html

#
# Local environment
#
$ ./lib/simple_web_fetcher.rb https://rubygems.org https://www.google.com
$ ls ./tmp/downloads
rubygems.org_20211104_163243.html       www.google.com_20211104_163241.html
```

Using with `--metadata` option, you can see the website and the time when you fetched information like below.

```.sh
$ ./lib/simple_web_fetcher.rb --metadata https://rubygems.org https://www.google.com
site: rubygems.org
num_links: 53
images: 0
last_fetch: 2021-11-04 07:33:37 UTC
site: www.google.com
num_links: 19
images: 2
last_fetch: (first time)
```

Using with `--debug` option, you can see debug logs like below.

```
$ ./lib/simple_web_fetcher.rb --debug https://rubygems.org
(DEBUG) start fetching. url:https://rubygems.org
(DEBUG) saved the page data successfully. path:./tmp/downloads/rubygems.org_20211104_163530.html
(DEBUG) updated history data.
```

## Test

You can run tests as following.

```.sh
$ bundle exec rake test
```

This tool is tested by Ruby v2.7.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SimpleWebFetcher project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/koshilife/simple-web-fetcher/blob/main/CODE_OF_CONDUCT.md).
