import joblib
import os
import numpy as np
from scipy.ndimage import binary_dilation, gaussian_filter
from skimage.transform import resize
import tensorflow as tf

def model_fn(model_dir):
    model_path = os.path.join(model_dir, "model.keras")
    return tf.keras.models.load_model(model_path)

def predict_fn(input_data, model):
    output_data = resize_drawing(input_data)
    output_data = np.expand_dims(output_data.reshape(-1,28,28),-1)
    output_data = (output_data > 0).astype(int)
    pred = model.predict(output_data)
    return pred

def input_fn(request_body, request_content_type):
    if request_content_type == "text/csv":
        return np.array([list(map(float, request_body.split(",")))])
    else:
        raise ValueError(f"Unsupported content type: {request_content_type}")

def output_fn(prediction):
    return np.argmax(prediction)

def resize_drawing(drawing):

    height = drawing["height"]
    width = drawing["width"]

    line_list = drawing["lines"]

    output = np.zeros((height,width))

    for line in line_list:
        points_list = line["points"]
        for point in points_list:
            x_idx = int((point["x"] / width) * height)
            y_idx = int((point["y"] / height) * width)
            output[y_idx, x_idx] += 1

    output = resize(output, (28,28))
    return output