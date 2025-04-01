import cv2
import numpy as np
import functools

print = functools.partial(print, flush=True)


def variance_of_laplacian(image):
    return cv2.Laplacian(image, cv2.CV_64F).var()

def check_video_quality(video_path):
    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        return "Error: Cannot open video."

    # Get video metadata
    fps = cap.get(cv2.CAP_PROP_FPS)
    frame_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    frame_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    frame_count_total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    duration_sec = frame_count_total / fps if fps > 0 else 0

    frame_count = 0
    total_brightness = 0
    total_blurriness = 0
    total_contours = 0
    hue_sum = 0
    hue_frame_count = 0
    sharpness_label = ""

    while frame_count < 10:  # Analyze first 10 frames
        ret, frame = cap.read()
        if not ret:
            break

        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        brightness = np.mean(gray)
        blurriness = variance_of_laplacian(gray)

        hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
        lower = np.array([30, 40, 40])  # Your target bead color range
        upper = np.array([90, 255, 255])
        mask = cv2.inRange(hsv, lower, upper)
        contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        total_contours += len(contours)

        # Check actual hue values of detected regions
        masked_hsv = cv2.bitwise_and(hsv, hsv, mask=mask)
        hue_values = masked_hsv[:, :, 0][mask > 0]
        if len(hue_values) > 0:
            hue_sum += np.mean(hue_values)
            hue_frame_count += 1

        #print(f"Frame {frame_count}: Brightness={brightness:.2f}, Blurriness={blurriness:.2f}, Contours={len(contours)}")

        total_brightness += brightness
        total_blurriness += blurriness
        frame_count += 1

    cap.release()

    if frame_count == 0:
        return "Error: No frames read."

    avg_brightness = total_brightness / frame_count
    avg_blurriness = total_blurriness / frame_count
    avg_contours = total_contours / frame_count
    avg_hue = hue_sum / hue_frame_count if hue_frame_count > 0 else 0

    # Sharpness rating
    if avg_blurriness < 30:
        sharpness_label = f"Too blurry (Sharpness: {avg_blurriness:.2f})"
    elif avg_blurriness < 50:
        sharpness_label = f"Medium sharpness (Sharpness: {avg_blurriness:.2f})"
    else:
        sharpness_label = f"Sharp (Sharpness: {avg_blurriness:.2f})"

    # Final decision
    if avg_brightness < 50:
        result = "Video too dark – Detection skipped."
    elif avg_brightness > 220:
        result = "Video too bright – Detection skipped."
    elif avg_blurriness < 30:
        result = "Video too blurry – Detection skipped."
    elif avg_contours < 50:
        result = "Beads not clearly visible – Detection skipped."
    elif avg_hue < 45 or avg_hue > 90:
        result = f"Color tones not acceptable (Avg Hue: {avg_hue:.2f}) – Possibly tinted – Detection skipped."
    elif avg_contours < 150:
        result = "Medium quality – Detection might be okay."
    else:
        result = "Good video – Proceeding with detection."

    # Video quality advice
    advice = []
    advice.append(f"Resolution: {frame_width}x{frame_height}")
    advice.append(f"FPS: {fps:.2f}")
    advice.append(f"Duration: {duration_sec:.2f} sec")
    if fps < 20:
        advice.append("Consider recording at higher FPS for smoother motion.")
    elif fps >= 200:
        advice.append("Ultra-smooth source detected – high frame rate ideal for analysis.")
    if frame_width < 640:
        advice.append("Low resolution – higher resolution may improve clarity.")
    if duration_sec < 5:
        advice.append("Short video – consider recording at least 5 seconds.")

    advice_text = "\n" + "\n".join(advice) if advice else ""
    return result + "\n" + sharpness_label + advice_text

# Run check
#video_path = "/Users/mohitsingh/Desktop/new videos/1.MOV"
#print(check_video_quality(video_path))
