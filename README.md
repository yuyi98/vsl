# vsl

[![Mentioned in Awesome V](https://awesome.re/mentioned-badge.svg)](https://github.com/vlang/awesome-v/blob/master/README.md#scientific-computing)
[![Build Status](https://github.com/ulises-jeremias/vsl/workflows/CI/badge.svg)](https://github.com/ulises-jeremias/vsl/commits/master)
[![Documentation Status](https://readthedocs.org/projects/vsl/badge/?version=latest)](http://vsl.readthedocs.io/en/latest/?badge=latest) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A pure-V scientific library with a great variety of functions.

> The version of this module will remain in `0.x.x` unless the language API's are finalized and implemented.

This library arises from the need to increase the domain of language V to the domain of Scientific Computing. Originally, this module is based on [ScientificC/cmathl](https://github.com/ScientificC/cmathl). However, vsl is expected to have a greater variety of functionalities in the near future.

## Docs

Visit [vsl docs](https://vsl.readthedocs.io/) to know more about the supported features.

## Installation

Via vpm:

```sh
$ v install ulises-jeremias.vsl
$ cp -r ~/.vmodules/ulises-jeremias/vsl ~/.vmodules/vsl
```

Via [vpkg](https://github.com/v-pkg/vpkg):

```sh
$ vpkg get vsl

# or

$ vpkg get https://github.com/ulises-jeremias/vsl
```

## Testing

To test the module, just type the following command:

```sh
$ make test
```

## License

[MIT](LICENSE)

## Contributors

- [Ulises Jeremias Cornejo Fandos](https://github.com/ulises-jeremias) - creator and maintainer
