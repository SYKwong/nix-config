{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "gif-maker";

  runtimeInputs = with pkgs; [
    ffmpeg-headless
    coreutils
    bash
  ];

  text = ''
    INPUT="''${1:-}"

    if [ -z "$INPUT" ]; then
        echo "Error: Please provide an input file."
        echo "Usage: gifmaker <input_video>"
        exit 1
    fi

    BASENAME=$(basename "''${INPUT%.*}")
    OUT="''${BASENAME}_wallpaper.gif"
    PALETTE="/tmp/''${BASENAME}_palette.png"

    FPS=15
    WIDTH=1920

    ffmpeg -y -i "$INPUT" \
      -vf "fps=$FPS,scale=$WIDTH:-2:flags=lanczos,colorspace=all=bt709:iall=bt709,palettegen" \
      "$PALETTE"

    ffmpeg -y -i "$INPUT" -i "$PALETTE" \
      -lavfi "fps=$FPS,scale=$WIDTH:-2:flags=lanczos[x];[x][1:v]paletteuse=dither=sierra2_4a" \
      "$OUT"

    rm "$PALETTE"

    echo "Done: $OUT"
    echo "----------------------------------------"

    printf "Do you want to delete the original video file (%s)? (Y/n): " "$INPUT"
    read -r RESPONSE || true

    case "$RESPONSE" in
        [nN][oO]|[nN]) 
            echo "Original file kept."
            ;;
        *)
            rm "$INPUT"
            echo "Original file deleted."
            ;;
    esac
  '';
}
