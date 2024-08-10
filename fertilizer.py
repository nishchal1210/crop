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
Anazyle the provided crop name and its phosphorus, nitrogen and potassium levels
and the plot size, give details on what amount(kgs) of MOP, SSP and urea is required 
and also how may bags of them. (1 bag urea = 45 kg ,1 bag of MOP = 50 kg,1 bag SSP =
45 kg). Always maintain the order Urea, SSP, MOP. 
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
            print(f"Model response: {response.text}")
            parsed_response = parse_gemini_response(response.text)
            return jsonify(parsed_response), 200
        else:
            return jsonify({"error": "Empty response from model"}), 500

    except Exception as e:
        # Log the exception
        app.logger.error(f"Error predicting crops: {e}", exc_info=True)
        return jsonify({"error": str(e)}), 500


def parse_gemini_response(response_text):
    # Initialize default values
    print(f"Parsing Response: {response_text}")

    try:
        # Updated regular expressions to handle decimal bag counts and remove 'bags' from the match
        urea_match = re.search(r'Urea:\s*([\d,]+(?:\.\d+)?)\s*kg', response_text)
        ssp_match = re.search(r'SSP:\s*([\d,]+(?:\.\d+)?)\s*kg', response_text)
        mop_match = re.search(r'MOP:\s*([\d,]+(?:\.\d+)?)\s*kg', response_text)

        bags_match = re.findall(r'(\d+\.?\d*)', response_text)  # Extract all numbers representing bags

        urea = urea_match.group(1) if urea_match else '0.0'
        ssp = ssp_match.group(1) if ssp_match else '0.0'
        mop = mop_match.group(1) if mop_match else '0.0'

        urea_bags = bags_match[0] if len(bags_match) > 0 else '0.0'
        ssp_bags = bags_match[1] if len(bags_match) > 1 else '0.0'
        mop_bags = bags_match[2] if len(bags_match) > 2 else '0.0'

        return {
            'Urea': {'kg': urea, 'bags': urea_bags},
            'SSP': {'kg': ssp, 'bags': ssp_bags},
            'MOP': {'kg': mop, 'bags': mop_bags}
        }
    except Exception as e:
        print(f"Error parsing response: {e}")
        return {'Urea': {'kg': '0.0', 'bags': '0.0'}, 'SSP': {'kg': '0.0', 'bags': '0.0'}, 'MOP': {'kg': '0.0', 'bags': '0.0'}}

    


if __name__ == '__main__':
    app.run(debug=True)