from flask import Flask, request, jsonify
from flask_cors import CORS
from PIL import Image
import io
import google.generativeai as genai
from api_key import api_key

app = Flask(__name__)
CORS(app)

# Configure Generative AI model
genai.configure(api_key=api_key)
generation_config = {
    "temperature": 1,
    "top_p": 0.95,
    "top_k": 64,
    "max_output_tokens": 8192,
    "response_mime_type": "text/plain",
}

model = genai.GenerativeModel(
    model_name="gemini-1.5-pro",
    generation_config=generation_config,
)

# Define system prompts
system_prompt_image_analysis = """
As a plant disease specialist, you are tasked with analyzing the uploaded image of the plant.

Your responsibilities:

1. Image Analysis: Perform a thorough examination of the uploaded plant image.
2. Diagnosis: Provide a comprehensive diagnosis of the identified plant disease or health issue.
3. Treatment Recommendations: Suggest appropriate measures or treatments based on the diagnosis.
4. Prevention Advice: Offer recommendations for preventing future occurrences of the identified disease.

Please proceed with the analysis, adhering to the structure outlined above.
"""

@app.route('/analyze', methods=['POST'])
def analyze_image():
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    try:
        # Open the image file
        image = Image.open(file)
        
        # Convert image to bytes for processing
        image_bytes = io.BytesIO()
        image.save(image_bytes, format='JPEG')
        image_data = image_bytes.getvalue()

        # Log image data size
        app.logger.debug(f"Image data size: {len(image_data)} bytes")

        prompt_parts = [
            {"mime_type": "image/jpeg", "data": image_data},
            {"text": system_prompt_image_analysis}
        ]

        # Generate response from the model
        response = model.generate_content(prompt_parts)

        # Log the response from the model
        app.logger.debug(f"Model response: {response.text}")

        return jsonify({"text": response.text}), 200

    except Exception as e:
        # Log the exception
        app.logger.error(f"Error analyzing image: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
