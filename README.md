[![GitHub release](https://img.shields.io/github/release/weaming/tablib.svg)](https://github.com/weaming/tablib/releases)

# Tablib

Parse 2d tabular data bettwen YAML, JSON, CSV.

## Installation

### Mac

```
brew tap weaming/tap
brew install tabular
```

### Manual

```
git clone https://github.com/weaming/tablib
crystal build --release src/tabular.cr
mv tabular /usr/local/bin
```

## Usage

```
$ ./tabular --help

  tabular -- Convert between CSV, JSON, YAML. The JSON is the bridge between CSV and YAML.

  Usage:

    tabular [options] [arguments] ...

  Options:

    -f FILE, --file=FILE             The file [type:String] [default:"/dev/stdin"]
    -t TYPE, --type                  Allow CSV or YAML [type:String] [default:"YAML"]
    -i, --indent                     Option description. [type:Int32] [default:2]
    --help                           Show this help.
    --version                        Show version.
```

### Interact with VIM

Add to your `.vimrc`

```
" brew install tabular
nnoremap <a-l> :%!tabular -f /dev/stdin -t yaml<CR>
nnoremap <a-c> :%!tabular -f /dev/stdin -t csv<CR>
```

## Development

1. `git clone`
1. `shards install`
1. `crystal run src/tabular.cr -- -f test.json -t csv`

## Contributing

1. Fork it (<https://github.com/weaming/tablib/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [weaming](https://github.com/weaming) weaming - creator, maintainer

## TODO

* [ ] JSON output custom indent
