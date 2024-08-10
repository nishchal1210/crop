from flask import Flask, request, jsonify,json
from flask_cors import CORS
import google.generativeai as genai

app = Flask(__name__)
CORS(app)

# Configure Generative AI model
genai.configure(api_key="AIzaSyCZ-4OqoceOzhoVImeOKVfgikwe3OryTUA")
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
system_prompt_crop_prediction = """
As an agricultural specialist, you are tasked with analyzing the provided soil data.

Your responsibilities:

1. Crop Recommendations: Suggest the most suitable crops to grow based on the soil data.(also provide image of each crop)
2. Agricultural Advice: Provide additional agricultural advice based on the analysis.

Please proceed with the analysis, adhering to the structure outlined above.
"""

@app.route('/predict_crops', methods=['POST'])
def predict_crops():
    try:
        data = request.json
        soil_type = data.get('soil_type')
        soil_ph = data.get('soil_ph')
        soil_moisture = data.get('soil_moisture')
        

        # Prepare prompt
        prompt_text = f"""
        Soil Type: {soil_type}
        pH Level: {soil_ph}
        Soil Moisture: {soil_moisture}
        """

        prompt_parts = [
            {"text": prompt_text},
            {"text": system_prompt_crop_prediction}
        ]

        # Generate response from the model
        response = model.generate_content(prompt_parts)
       

        # Log the response from the model
        app.logger.debug(f"Model response: {response.text}")

        if response.text:
         print(f"Model response: {response.text}")
         predicted_crops = response.text.split(",")
         return jsonify({"predicted_crops": predicted_crops}), 200
        else:
         return jsonify({"error": "Empty response from model"}), 500

    except Exception as e:
        # Log the exception
        app.logger.error(f"Error predicting crops: {e}")
        return jsonify({"error": str(e)}), 500

# if __name__ == '__main__':
#     app.run(debug=True)
