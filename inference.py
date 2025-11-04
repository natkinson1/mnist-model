import joblib
import os
import numpy as np
from scipy.ndimage import binary_dilation, gaussian_filter

def model_fn(model_dir):
    model_path = os.path.join(model_dir, "model.joblib")
    return joblib.load(model_path)

def predict_fn(input_data, model):
    input_data = resize_drawing(input_data)
    return model.predict(input_data)

def input_fn(request_body, request_content_type):
    if request_content_type == "text/csv":
        return np.array([list(map(float, request_body.split(",")))])
    else:
        raise ValueError(f"Unsupported content type: {request_content_type}")

def output_fn(prediction, content_type):
    return ",".join(str(p) for p in prediction)

def thicken_lines_scipy(img, thickness=1):
    # Convert to binary
    binary = img > 0
    # Apply dilation
    output = binary_dilation(binary, iterations=thickness)
    output = gaussian_filter(output * 255, sigma=0.5)
    return output

def resize_drawing(drawing):

    height = drawing["height"]
    width = drawing["width"]

    line_list = drawing["lines"]

    output = np.zeros((28,28))

    for line in line_list:
        points_list = line["points"]
        for point in points_list:
            x_idx = int((point["x"] / width) * 28)
            y_idx = int((point["y"] / height) * 28)
            output[y_idx, x_idx] += 1

    output = thicken_lines_scipy(output)
    output = output.reshape(1,-1)
    return output