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

Analyze the provided crop and its waste. Provide suggestions and ideas for farmers.

1. Creative Ideas: Innovative and unconventional uses for rice straw.
2. Wealth Generation Ideas: Practical methods for farmers to generate income from rice straw.
3. Environmental Impact Reduction:Strategies to minimize the negative environmental effects of rice straw.
4. Resource Optimization: Efficient ways to utilize rice straw as a valuable resource.


Please proceed with the analysis, adhering to the structure outlined above.
"""

@app.route('/submit_waste', methods=['POST'])
def predict_crops():
    try:
        data = request.json
        crop = data.get('crop')
        waste = data.get('waste')
       
        

        # Prepare prompt
        prompt_text = f"""
        crop: {crop}
        waste: {waste}
        
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
         predicted_crops = [response.text]
         return jsonify({"predicted_crops": predicted_crops}), 200
        else:
         return jsonify({"error": "Empty response from model"}), 500

    except Exception as e:
        # Log the exception
        app.logger.error(f"Error predicting crops: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
