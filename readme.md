# personnummer [![Build Status](https://github.com/personnummer/v/workflows/test/badge.svg)](https://github.com/personnummer/v/actions)

Validate Swedish personal identity numbers.

Install the module with vpm:

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

## In memoriam

Fredrik "Frozzare" Forsmo (1991-2026) was the initiator, co-founder and a core contributor of the personnummer project. This library carries his work. He is missed.

## License

MIT