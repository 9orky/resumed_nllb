import os


MODEL_NAME = os.environ.get('MODEL_NAME', 'facebook/nllb-200-distilled-600M')
SRC_LANG = os.environ.get('SRC_LANG', 'pol_Latn')
TGT_LANG = os.environ.get('TGT_LANG', 'eng_Latn')
MAX_LENGTH = 512
NUM_BEAMS = 4
CUDA_ENABLED = bool(os.environ.get('CUDA_ENABLED', False))
