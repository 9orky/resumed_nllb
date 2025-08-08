from flask import Flask
from .routes import translate_bp


def create_app() -> Flask:
    app = Flask('resumed_nllb')
    app.register_blueprint(translate_bp)
    return app
