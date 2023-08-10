import os

import cv2
import numpy as np
import tensorflow as tf
import werkzeug
from flask import Flask, jsonify, request

import Predict_Characters
import Split_Characters
import Split_Words

app = Flask(__name__)

@app.route('/upload', methods=["POST"])
def upload():
    if(request.method == "POST"):
        imagefile = request.files['image']
        filename = werkzeug.utils.secure_filename(imagefile.filename)
        imagefile.save("./uploadedimages/" + filename)
        img = cv2.imread("./uploadedimages/" + filename)
        os.remove("./uploadedimages/" + filename)
        Words = Split_Words.Split(img)
        Characters = Split_Characters.Split(Words)
        Predictions = Predict_Characters.Predict(Characters)

        Words = []
        for Prediction in Predictions:
            Word = ''.join(Prediction)
            Words.append(Word)
        Words = ' '.join(Words)
        


        return jsonify({
            "message": Words
        })


if __name__ == "__main__":
    app.run(debug=True, port=4000)