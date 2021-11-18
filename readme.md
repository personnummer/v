# personnummer [![Build Status](https://github.com/personnummer/v/workflows/test/badge.svg)](https://github.com/personnummer/v/actions)

Validate Swedish personal identity numbers. Follows version 3 of the [specification](https://github.com/personnummer/meta#package-specification-v3).

Install the module with dub:

```
v install personnummer
```

## Example

```v
import personnummer

fn main() {
    personnummer.valid('198507099805')
    // => true
}
```

## License

MIT