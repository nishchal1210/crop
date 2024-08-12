from flask import Flask, request, jsonify,json
from flask_cors import CORS

import google.generativeai as genai
import re


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
Given the crop name , nutrient levels in kg/ha(N, P and K), and plot size , provide a detailed response with the following points:


1.Fertilizer Requirements:Specify the exact amounts (in kg) of Urea, SSP, and MOP required.
Provide the corresponding number of bags needed for each fertilizer type (considering 1 bag Urea = 45 kg, 1 bag MOP = 50 kg, 1 bag SSP = 45 kg).
Crucial Reminders:

2.Calculations, Assumptions, and Conversions:Explain the calculations used to determine the amount of Urea, SSP, and MOP required based on the nutrient levels provided.
Mention any assumptions or standard conversions applied (e.g., bag weight conversions).

3.Include key reminders about the importance of soil testing before application:Mention the significance of split application of fertilizers,
Recommend consulting an agricultural expert for tailored advice.

"""

@app.route('/calculate', methods=['POST'])
def calculate():
    try:
        data = request.json
        crop = data.get('crop')
        n = data['n']
        p = data['p']
        k = data['k']
        plot_size = data['plot_size']
        unit = data['unit']

        # Prepare prompt
        prompt_text = f"""
        crop: {crop}
        n = {n}
        p = {p}
        k = {k}
        plot_size = {plot_size}{unit}
        """

        prompt_parts = [
            {"text": prompt_text},
            {"text": system_prompt_crop_prediction}
        ]

        # Generate response from the model
        response = model.generate_content(prompt_parts)
        app.logger.debug(f"Model response: {response.text}")

        if response.text:
            # Parse the response text for required values
            return jsonify({"gemini_response": response.text}), 200
        else:
            return jsonify({"error": "Empty response from model"}), 500

    except Exception as e:
        # Log the exception
        app.logger.error(f"Error predicting crops: {e}", exc_info=True)
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)