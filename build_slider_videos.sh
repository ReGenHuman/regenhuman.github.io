#!/usr/bin/env bash
# Generate web-friendly per-(method, clip) MP4s for the comparison slider.
# Every clip is re-encoded to a common WxH so the slider overlay halves align.
set -euo pipefail

REPO=/vision/u/adsun/VACE_projects/VACE-Bench
FFMPEG=/usr/bin/ffmpeg   # system build with libx264 (conda build lacks it)
OUT=$REPO/website/static/videos
FPS=8
W=640
H=360

# 4 hand-curated sequences (from sample_frames/), in display order -> clip dir.
VIDS=(
  "xOaGPo09H-k-0:00:37.637-0:00:46.713"
  "zenIuqQSj_0-0:29:18.533-0:29:26.733"
  "xMpYqIFthjg-0:04:03.280-0:04:12.560"
  "w08m1RVZ2fg-0:01:09.102-0:01:12.772"
)

# method-key : source-subdir (frame folders under HOIGen-1K/<vid>/)
declare -A FRAME_SRC=(
  [gt]=frames
  [egoblur]=ego_blur_frames
  [fams]=fams
  [dp2face]=deep_privacy2_face
  [dp2body]=deep_privacy2_body
  [fadm]=fadm
)

VF="scale=${W}:${H}:flags=bicubic,format=yuv420p"

enc_frames () {  # <in_dir> <out.mp4>
  local dir="$1" out="$2"
  $FFMPEG -y -loglevel error -framerate $FPS -start_number 1 \
    -i "$dir/%06d.jpg" -vf "$VF" \
    -c:v libx264 -crf 23 -preset fast -movflags +faststart -an "$out"
}

enc_mp4 () {     # <in.mp4> <out.mp4>
  # Re-time EVERY source frame to $FPS (setpts) so the clip stays frame-aligned
  # with the baseline frame-folder encodes; -r alone would drop frames.
  local src="$1" out="$2"
  $FFMPEG -y -loglevel error -i "$src" \
    -vf "${VF},setpts=N/(${FPS}*TB)" -fps_mode cfr -r $FPS \
    -c:v libx264 -crf 23 -preset fast -movflags +faststart -an "$out"
}

i=0
for vid in "${VIDS[@]}"; do
  i=$((i+1))
  clipdir="$OUT/clip${i}"
  mkdir -p "$clipdir"
  echo "=== clip${i}  $vid ==="

  for key in "${!FRAME_SRC[@]}"; do
    src="$REPO/anonymize_data/HOIGen-1K/$vid/${FRAME_SRC[$key]}"
    echo "  $key <- ${FRAME_SRC[$key]}"
    enc_frames "$src" "$clipdir/${key}.mp4"
  done

  echo "  ours_structall  <- privacy_cond"
  enc_mp4 "$REPO/inference_results/hoigen_1k_privacy_cond/${vid}_generated.mp4" \
          "$clipdir/ours_structall.mp4"
  echo "  ours_structhuman <- human_mask_cond"
  enc_mp4 "$REPO/inference_results/hoigen_1k_human_mask_cond/${vid}_generated.mp4" \
          "$clipdir/ours_structhuman.mp4"
done

echo "DONE. Wrote $(find "$OUT" -name '*.mp4' | wc -l) mp4s to $OUT"
