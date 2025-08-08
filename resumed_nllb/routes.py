from dataclasses import asdict
from flask import Blueprint, request, jsonify

from .model import translate_texts
from .config import MAX_LENGTH, NUM_BEAMS


translate_bp = Blueprint('translate', __name__)


@translate_bp.route('/translate', methods=['POST'])
def translate():
    if not request.is_json:
        return jsonify({'error': 'Request must be JSON'}), 400

    data = request.get_json()
    text = data.get('text')

    if isinstance(text, str):
        texts = [text.strip()]
    elif isinstance(text, list):
        texts = [t.strip() for t in text if isinstance(t, str) and t.strip()]
    else:
        return jsonify({'error': 'Invalid input format'}), 400

    if not texts:
        return jsonify({'error': 'No text provided'}), 400

    result = translate_texts(texts, MAX_LENGTH, NUM_BEAMS)
    return jsonify(asdict(result))
