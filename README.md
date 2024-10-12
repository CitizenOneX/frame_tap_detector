# Frame Tap Detector

App demonstrating subscription to tap detection on Brilliant Labs Frame. Multi-taps are passed through and recognized in the phone app (single tap, double tap, up to any number). Debouncing input noise (extra taps very close in time to other taps, but unintended) also occurs in the phone app.

An app could use N multi-taps to distinguish between user intents, e.g. voice query, voice plus photo query, standard photo query no voice prompt, etc.

### Frameshots
![Frameshot1](docs/frameshot1.png)
![Frameshot2](docs/frameshot2.png)
![Frameshot3](docs/frameshot3.png)

### Screenshots
![Screenshot1](docs/screenshot1.png)

### Architecture
![Architecture](docs/Frame%20App%20Architecture%20-%20Tap%20Detector.svg)