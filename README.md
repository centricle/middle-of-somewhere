# middle-of-somewhere

How far it is, by road, to the nearest of everything.

A US-wide drive-time index. For every populated census block it computes the
uncongested drive time to the nearest store of a set of retail chains and to the
nearest of a set of civic services (trauma centers, cancer centers, airports with
jet service, Amtrak stations), then rolls the result up to ZIP code, tract and
county. Each chain sites its stores on different inputs, so each one measures a
different kind of distance from the middle of things.

It will live at
[centricle.com/curios/middle-of-somewhere/](https://centricle.com/curios/middle-of-somewhere/).
Work in progress.

## Layout

```
pipeline/   Python (uv): graph build, routing, aggregation, model
bin/        one entry point per stage
data/       small committed inputs, configs and schemas
site/       Astro static site
```

## License

The code is licensed under the GNU Affero General Public License v3.0; see
[LICENSE](LICENSE).

The derived data (the ZIP lookup files, the drive-time tables and anything else
computed by routing over OpenStreetMap) is licensed under the
[Open Database License (ODbL) 1.0](https://opendatacommons.org/licenses/odbl/1-0/).

Map data © OpenStreetMap contributors.
