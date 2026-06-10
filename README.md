# regenhuman.github.io

Project website for **ReGenHuman: Re-Generating Human Appearances for Realistic Full-Body Video Anonymization**.

Served via GitHub Pages from the repository root (`index.html`).

## Structure

- `index.html` — the full single-page site (Bulma + vanilla JS, no build step).
- `static/images/` — paper figures (teaser, method, qualitative collage).
- `static/videos/clip1..4/` — per-(method, clip) MP4s for the interactive comparison slider.
- `static/videos/pipeline/` — the "How It Works" pipeline clips (input, depth, pose, conditioning, outputs).
- `build_slider_videos.sh` — helper that re-encodes the source frames/MP4s into the web-friendly,
  frame-aligned 640×360 clips used by the slider (paths are specific to the authoring machine).

## Local preview

```bash
python -m http.server 8000
# open http://localhost:8000/
```

Serving over HTTP (not `file://`) is required for the videos to autoplay.
