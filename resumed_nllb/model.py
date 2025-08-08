from dataclasses import dataclass
import time

from typing import List
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

from .config import MODEL_NAME, SRC_LANG, TGT_LANG


tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForSeq2SeqLM.from_pretrained(MODEL_NAME)


try:
    forced_id: int = tokenizer.lang_code_to_id[TGT_LANG]
except AttributeError:
    forced_id = tokenizer.convert_tokens_to_ids(TGT_LANG)

if forced_id is None or not isinstance(forced_id, int):
    raise ValueError(f"Invalid or unsupported target language code: {TGT_LANG}")


tokenizer.src_lang = SRC_LANG


@dataclass
class TranslationResult:
    translations: List[str]
    max_length: int
    num_beams: int
    num_input_tokens: int
    num_output_tokens: int
    elapsed_time: float


def translate_texts(
    texts: List[str],
    max_length: int = 512,
    num_beams: int = 4
) -> TranslationResult:
    start = time.time()

    inputs = tokenizer(
        texts,
        return_tensors='pt',
        padding=True,
        truncation=True,
        max_length=max_length,
    )

    num_input_tokens = inputs['input_ids'].numel()

    translated = model.generate(
        **inputs,
        forced_bos_token_id=forced_id,
        max_length=max_length,
        num_beams=num_beams,
        early_stopping=True,
    )

    translations = [tokenizer.decode(t, skip_special_tokens=True) for t in translated]

    num_output_tokens = sum(len(t.tolist()) for t in translated)
    elapsed_time = time.time() - start

    return TranslationResult(
        translations=translations,
        max_length=max_length,
        num_beams=num_beams,
        num_input_tokens=num_input_tokens,
        num_output_tokens=num_output_tokens,
        elapsed_time=elapsed_time
    )
