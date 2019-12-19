# Toggl2DalePonto

This script will create a request for change on Dale Ponto based on Toggl registers.

ATENTION: The request will be created even if you have a punch or an another request on the same time.

## Install

After cloning the repository.

```shell
  bundle install
  cp .env{.sample,}
```
Then edit your env variables.

## Usage

You will pass as arguments the start date and the finish date.

```shell
  ruby conver.rb 2019-12-16 2019-12-18
```

## License

The code is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
