import cv2
import numpy as np
import sys
import time
import argparse

from video_quality_checker import check_video_quality

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("input_video")
    parser.add_argument("output_video")

    # Flags for enabling/disabling each color
    parser.add_argument("--enable-blue", default="true",
                        help="Enable processing for blue (true/false)")
    parser.add_argument("--enable-pink", default="true",
                        help="Enable processing for pink (true/false)")
    parser.add_argument("--enable-white", default="true",
                        help="Enable processing for white (true/false)")

    # If you want, you can also parse custom color ranges via arguments:
    # (see previous examples using '--blue-lower', '--blue-upper', etc.)
    
    return parser.parse_args()

def str_to_bool(value):
    return value.lower() in ["true", "1", "yes", "on"]

def process_video(args):
    input_path = args.input_video
    output_path = args.output_video

    #  * INSERT QUALITY CHECK HERE
    print("Running quality check...")
    quality_result = check_video_quality(input_path)
    print(quality_result)
    sys.stdout.flush()

    # ! STOP if the video is not good enough
    if "Detection skipped" in quality_result:
        print("Video rejected due to poor quality. Skipping processing.")
        return
    
    cap = cv2.VideoCapture(input_path)
    if not cap.isOpened():
        print("Error: could not open video.")
        sys.stdout.flush()
        return

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    fps = cap.get(cv2.CAP_PROP_FPS)
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    fourcc = cv2.VideoWriter_fourcc(*"mp4v")
    out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))

    # Print an "Estimated processing time" line so Swift can pick it up
    if fps > 0:
        print(f"Estimated processing time: {total_frames / fps:.2f} seconds")
    else:
        print("Estimated processing time: Unknown (fps=0)")
    sys.stdout.flush()

    # Decide which colors we should process, based on flags
    enable_blue = str_to_bool(args.enable_blue)
    enable_pink = str_to_bool(args.enable_pink)
    enable_white = str_to_bool(args.enable_white)

    color_ranges = {}
    fill_colors = {}

    if enable_blue:
        color_ranges["blue"] = {
            "lower": (48, 93, 72),
            "upper": (158, 255, 255)
        }
        fill_colors["blue"] = (255, 0, 0)

    if enable_pink:
        color_ranges["pink"] = {
            "lower": (129, 97, 0),
            "upper": (179, 255, 255)
        }
        fill_colors["pink"] = (255, 0, 255)

    if enable_white:
        color_ranges["white"] = {
            "lower": (0, 0, 230),
            "upper": (179, 150, 255)
        }
        fill_colors["white"] = (0, 255, 0)

    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5,5))
    start_time = time.time()

    for frame_no in range(total_frames):
        ret, frame = cap.read()
        if not ret:
            break

        hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
        output_frame = frame.copy()

        # For each enabled color, do the normal inRange/drawContours procedure
        for color_name, bounds in color_ranges.items():
            lower = bounds["lower"]
            upper = bounds["upper"]

            mask_color = cv2.inRange(hsv, lower, upper)
            opened = cv2.morphologyEx(mask_color, cv2.MORPH_OPEN, kernel)
            closed = cv2.morphologyEx(opened, cv2.MORPH_CLOSE, kernel)

            # If "white," optionally do more morphological ops
            if color_name == "white":
                dilation_kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7,7))
                closed = cv2.morphologyEx(closed, cv2.MORPH_DILATE, dilation_kernel)

            # Find contours
            contours, _ = cv2.findContours(closed, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

            for cnt in contours:
                area = cv2.contourArea(cnt)
                if area < 20 or area > 2000:
                    continue

                perimeter = cv2.arcLength(cnt, True)
                if perimeter == 0:
                    continue

                circularity = 4.0 * np.pi * area / (perimeter * perimeter)
                if circularity < 0.5:
                    continue

                approx = cv2.approxPolyDP(cnt, 0.01 * perimeter, True)
                cv2.drawContours(output_frame, [approx], -1, fill_colors[color_name], -1)

        out.write(output_frame)

        # Progress updates: "Progress: XX% | Time Remaining: YYs"
        elapsed_time = time.time() - start_time
        progress = (frame_no + 1) / total_frames * 100 if total_frames > 0 else 0
        frames_remaining = total_frames - (frame_no + 1)
        avg_time_per_frame = elapsed_time / (frame_no + 1) if (frame_no + 1) > 0 else 0
        time_remaining = frames_remaining * avg_time_per_frame

        print(f"Progress: {progress:.2f}% | Time Remaining: {time_remaining:.2f}s")
        sys.stdout.flush()

    cap.release()
    out.release()
    print(f"Processing Complete: {output_path}")
    sys.stdout.flush()

if __name__ == "__main__":
    args = parse_args()
    process_video(args)
