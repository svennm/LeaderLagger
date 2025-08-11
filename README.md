# Correlation‑Driven Trading Framework

This repository contains a proof‑of‑concept trading framework for
MetaTrader 5 (MT5) that combines correlation analysis with trend
following, momentum breakout and intraday “peg” strategies.  The
framework is designed to run in a **Linux Docker container** while
connecting to a MetaTrader 5 terminal on a **Windows VPS** via the
[`mt5linux`](https://github.com/lucas-campagna/mt5linux) bridge.  You
can extend and customise the strategies to suit your own trading
requirements.

## Why MT5 needs to be running

The official MetaTrader 5 Python package interacts with a running
terminal via inter‑process communication; it does not connect
directly to your broker.  As a result the MT5 terminal must be
installed, open and logged in to your broker account for the Python
API to work.  The MT5 terminal acts as the work‑horse that collects
market data and processes trades.  The Python integration is simply a
client layer that sends commands to the terminal【888434613296741†L90-L100】.

## Overview of strategies

- **Correlation analysis:** The system computes sample correlations
  between the returns of multiple instruments.  When computing
  correlation in a time series context we look at returns over a
  fixed time window; the sample correlation coefficient is the
  sample covariance of two variables divided by the product of
  their standard deviations【698190497865019†L32-L39】.
- **Opening range breakout:** The breakout module implements a simple
  opening range breakout strategy.  The opening range is the price
  range (high and low) formed during the first 15–60 minutes of the
  trading day【34714035632443†L69-L96】.  A move above the range high
  triggers a bullish signal and a move below the range low triggers a
  bearish signal【34714035632443†L69-L96】.  To reduce noise, only
  breakouts that occur simultaneously on two highly‑correlated assets
  generate signals.
- **Trend‑correlation:** This strategy identifies assets whose
  returns are trending and whose average correlation with other
  instruments exceeds a threshold.  The intuition is that shared
  momentum across markets may persist longer than isolated moves.
- **Peg:** A simple intraday strategy that buys an asset at the start
  of the day (after spreads settle) and sells before the end of the
  day.  This avoids overnight risk and spread widening.

## Prerequisites

1. **Windows VPS with MetaTrader 5 installed.**  Install the MT5
   terminal from the [MetaTrader website](https://www.metatrader5.com)
   and log in with your broker credentials.  If necessary, enable
   Python integration under *Tools → Options → Community*.
2. **Python on Windows.**  Install a recent version of Python (3.8+
   recommended) and add it to your PATH.  Install the official
   `MetaTrader5` package:  
   ```bash
   pip install MetaTrader5
   pip install --upgrade MetaTrader5
   ```
3. **mt5linux bridge.**  Install the `mt5linux` package on both
   Windows and Linux.  On Windows this package acts as an RPyC server
   that exposes the `MetaTrader5` API over a socket; on Linux it
   provides a client.  The project’s README explains the
   installation steps【81450874041465†L33-L63】.
4. **Start the bridge server on Windows.**  On your Windows VPS run:
   ```bash
   python -m mt5linux C:\\Path\\To\\Python\\python.exe
   ```
   Replace the path with the location of your Windows Python
   interpreter.  The server listens on port 18812 by default.

## Running the container on Windows

1. **Install Docker Desktop for Windows** and enable “Use WSL 2 based
   engine” so that Linux containers can run alongside your Windows
   applications.
2. **Clone this repository** or copy the `trading_flow` folder to a
   working directory on your Windows machine.
3. **Build the Docker image:**
   ```bash
   cd trading_flow
   docker build -t mt5-corr-bot .
   ```
4. **Run the container:**
   ```bash
   docker run --rm \
     --name mt5-corr-bot \
     -e MT5_HOST=host.docker.internal \
     -e MT5_PORT=18812 \
     -v %cd%/signals:/app/signals \
     mt5-corr-bot
   ```
   The special hostname `host.docker.internal` allows the container to
   reach the Windows host where the MT5 terminal and bridge are
   running.  The `signals` directory will contain a JSON file of
   generated signals.

## File structure

```
trading_flow/
├── Dockerfile            # Container definition
├── docker-compose.yml    # Example compose file (optional)
├── requirements.txt      # Python dependencies
├── README.md             # This guide
└── src/                  # Application source code
    ├── config.py         # Configuration constants
    ├── data_handler.py   # MT5 data access layer
    ├── messaging_system.py  # Signal queue
    ├── correlation_analysis.py  # Correlation helpers
    ├── strategy_breakout.py     # Breakout logic
    ├── strategy_correlation.py  # Trend/correlation logic
    ├── strategy_peg.py          # Peg logic
    └── main.py            # Entrypoint
```

## Extending the system

This framework is intentionally modular.  You can add new strategies
by creating modules under `src/` that return lists of `Signal`
objects and by importing those modules in `main.py`.  For robustness
in production consider replacing the in‑memory `SignalQueue` with a
persistent message broker and integrating proper order management.