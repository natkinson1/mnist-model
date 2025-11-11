import os
import flask
import logging
import json
from inference import model_fn, input_fn, predict_fn, output_fn
import traceback
from flask_cors import CORS

app = flask.Flask(__name__)
CORS(app, origins=["http://localhost:5173", "http://127.0.0.1:5173", "https://www.nikhilatkinson.dev/"])

logging.basicConfig(
    # filename="app.log",
    level=logging.DEBUG,
    format='%(asctime)s [%(levelname)s] %(message)s'
)
logger = logging.getLogger(__name__)

MODEL_DIR = os.getenv("SM_MODEL_DIR", ".")
logger.info(f"Model directory: {MODEL_DIR}")
logger.info(f"Files in /opt/ml/model: {os.listdir("/opt/ml/model")}")

@app.route('/ping', methods=["GET"])
def ping():
    return flask.Response(response=json.dumps({"status" : "healthy"}), status=200, mimetype='application/json')

@app.route('/invocations', methods=["POST"])
def invoke():
    try:
        logger.info(f"Model directory: {MODEL_DIR}")
        logger.info(f"Files in /opt/ml/model: {os.listdir("/opt/ml/model")}")
        model = model_fn(MODEL_DIR)
        data = flask.request.get_json()

        prediction = predict_fn(data, model)
        output = output_fn(prediction)
        logger.info(f"Made prediction: {output}")

        return flask.Response(response=json.dumps({"prediction" : output}), status=200, mimetype="application/json")
    except Exception as e:
        error_message = f"Error during prediction: {str(e)}\n{traceback.format_exc()}"
        print(error_message)
        logger.error(error_message)
        return flask.Response(
            response=json.dumps({"error": str(e), "traceback": traceback.format_exc()}),
            status=500,
            mimetype='application/json'
        )

if __name__ == '__main__':
    port = os.getenv("SM_PORT", 8080)
    logger.info(f"Starting server on port: {port}")
    app.run(host="0.0.0.0", port=port, debug=True)