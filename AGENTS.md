# AGENTS.md

ADS-B feeder management scripts for a single Debian/Ubuntu host.

## Scripts

- `start.sh` — start all running services (fr24feed, piaware, rbfeeder docker).
  - `--skip-docker`: start only systemd services, skip the rbfeeder container.
- `run_persistent.sh` — enable + start fr24feed & piaware as persistent systemd services, then run rbfeeder as a persistent docker container. Calls `./stop.sh` then `./start.sh --skip-docker` — both must be present in the working directory.
- `stop_persistent.sh` — disable fr24feed & piaware, stop systemd services, stop + delete the rbfeeder container. Calls `./stop.sh` which must be present in the working directory.
- `stop.sh` — stop all services (systemd + docker).

## Gotchas

- **All scripts require root** (systemctl + docker).
- **Scripts must be run from the repo root.** They use `./stop.sh`, `./start.sh` and `source .env` as relative paths.
- `start.sh` and `run_persistent.sh` source `.env` inline — the file must be in the working directory.
- Machine-specific values live in `.env` (network adapter, timezone, coordinates, AirNav Radar sharing key). `.env` is gitignored — copy the template below on new deployments:

      NETWORK_ADAPTER=eth0
      TZ=UTC
      LAT=0.0
      LONG=0.0
      ALT=0
      SHARING_KEY=your_sharing_key_here

- `start.sh` rbfeeder uses `--rm` (ephemeral). `run_persistent.sh` rbfeeder uses `--restart unless-stopped` (no `--rm`, persistent).

## Thanks

Docker AirNav Radar feeder image by [sdr-enthusiasts](https://github.com/sdr-enthusiasts/docker-airnavradar).
