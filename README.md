# The Lummings

Little friends from a brighter tomorrow. Smart-toy platform with on-device AI personalities (Lumo, Lumi, Piko, Nomi, Moki) that help children learn, think, protect the Earth, and make good choices.

## Overview

The Lummings is an educational smart-toy platform. Each Lumming is a small character with a distinct personality who lives on a Raspberry Pi Zero 2 W inside a child-friendly shell. All AI runs locally — no cloud, no telemetry, no subscription. The platform ships a personality engine (Python), a device runtime (Rust), a static website, and a notebook laboratory for persona research. The product is sold as a single device + optional personality packs.

## Development

This repository uses a standard make interface:

- make init
- make lint
- make test
- make benchmark
- make docs
- make format
- make release
