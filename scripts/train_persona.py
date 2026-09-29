#!/usr/bin/env python3
"""
Per-persona SFT: train a small LoRA adapter on each Lumming's dialogue.

Uses the trained ULTRON-7B base (or Qwen2.5-7B-Instruct) + LoRA + 4-bit NF4.
Each persona gets its own adapter at models/<persona>-adapter/.

After training, the adapter is merged into the base and exported as a GGUF
suitable for serving on a Raspberry Pi.

Usage:
  python scripts/train_persona.py --persona lumo --base qwen2.5-7b-instruct
  python scripts/train_persona.py --persona all --base qwen2.5-7b-instruct

Requires: same env as ultron-training (torch, transformers, peft, trl, bitsandbytes)
"""

from __future__ import annotations

import os, sys, argparse, json, subprocess, shutil
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO / "src"))

PERSONAS = ["lumo", "lumi", "piko", "nomi", "moki"]
DIALOGUE_DIR = REPO / "src" / "lummings" / "dialogue"
MODELS_DIR = REPO / "models"


def train_one(persona: str, base_model: str, output_dir: Path, epochs: int = 2) -> int:
    """Train a LoRA adapter for one persona."""
    dataset = DIALOGUE_DIR / f"{persona}_sft.jsonl"
    if not dataset.exists():
        print(f"!! dataset missing: {dataset}")
        return 1
    output_dir.mkdir(parents=True, exist_ok=True)

    # Reuse the ultron-training pipeline's 04_train.py for consistency
    train_script = REPO / "scripts" / "train_one.py"
    if not train_script.exists():
        # Build a minimal trainer inline
        return train_inline(persona, base_model, dataset, output_dir, epochs)
    cmd = [
        sys.executable, "-u", str(train_script),
        "--base", base_model,
        "--dataset", str(dataset),
        "--output", str(output_dir),
        "--epochs", str(epochs),
        "--batch-size", "1", "--grad-accum", "8", "--seq-len", "2048",
    ]
    print(f">>> training {persona}: {' '.join(cmd[:6])}...")
    return subprocess.call(cmd, cwd=str(REPO))


def train_inline(persona: str, base_model: str, dataset: Path, output_dir: Path, epochs: int) -> int:
    """Minimal in-process trainer (works without ultron-training)."""
    import torch
    from datasets import load_dataset
    from transformers import (
        AutoModelForCausalLM, AutoTokenizer, TrainingArguments,
    )
    from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training
    from trl import SFTConfig, SFTTrainer

    print(f"\n=== training {persona} on {base_model} ===")
    tok = AutoTokenizer.from_pretrained(base_model, trust_remote_code=True)
    if tok.pad_token is None:
        tok.pad_token = tok.eos_token

    from transformers import BitsAndBytesConfig
    bnb = BitsAndBytesConfig(
        load_in_4bit=True, bnb_4bit_quant_type="nf4",
        bnb_4bit_compute_dtype=torch.bfloat16,
        bnb_4bit_use_double_quant=True,
    )
    model = AutoModelForCausalLM.from_pretrained(
        base_model, quantization_config=bnb, device_map="auto",
        torch_dtype=torch.bfloat16, trust_remote_code=True,
        attn_implementation="sdpa",
    )
    model = prepare_model_for_kbit_training(model)
    peft_cfg = LoraConfig(
        r=16, lora_alpha=32, lora_dropout=0.05,
        bias="none", task_type="CAUSAL_LM",
        target_modules=["q_proj","k_proj","v_proj","o_proj","gate_proj","up_proj","down_proj"],
    )
    model = get_peft_model(model, peft_cfg)
    model.print_trainable_parameters()

    raw = load_dataset("json", data_files=str(dataset), split="train")
    # Convert to messages-text for SFT
    def to_text(ex):
        msgs = ex["messages"]
        text = tok.apply_chat_template(msgs, tokenize=False, add_generation_prompt=False)
        return {"text": text}
    ds = raw.map(to_text, remove_columns=raw.column_names)

    sft_kwargs = dict(
        output_dir=str(output_dir),
        num_train_epochs=epochs,
        per_device_train_batch_size=1,
        gradient_accumulation_steps=8,
        learning_rate=2e-4,
        warmup_steps=10,
        logging_steps=5,
        save_steps=200,
        bf16=True,
        gradient_checkpointing=True,
        report_to="none",
    )
    sft_kwargs["dataset_text_field"] = "text"
    sft_kwargs["max_length"] = 2048
    sft_kwargs["packing"] = True
    sft_kwargs["completion_only_loss"] = False

    sft_cfg = SFTConfig(**{k: v for k, v in sft_kwargs.items() if v is not None})

    trainer = SFTTrainer(
        model=model, processing_class=tok, args=sft_cfg,
        train_dataset=ds, eval_dataset=None,
    )
    trainer.train()
    trainer.save_model(str(output_dir))
    tok.save_pretrained(str(output_dir))
    print(f"saved adapter: {output_dir}")
    return 0


def merge_and_export(persona: str, base_model: str, adapter_dir: Path, gguf_out: Path) -> int:
    """Merge LoRA into FP16, then export GGUF (Q4_K_M) for Pi deployment."""
    print(f"\n=== merge + export {persona} ===")
    # Use the existing ultron-training 05_merge.py + 06_export_gguf.py if present
    base = REPO / "scripts"
    if (base / "merge_adapter.py").exists():
        merged_dir = MODELS_DIR / f"{persona}-merged"
        r = subprocess.call([sys.executable, str(base / "merge_adapter.py"),
                            "--base", base_model, "--adapter", str(adapter_dir),
                            "--output", str(merged_dir)])
        if r != 0: return r
        r = subprocess.call([sys.executable, str(base / "export_gguf.py"),
                            "--merged", str(merged_dir),
                            "--gguf-out", str(gguf_out)])
        if r != 0: return r
    else:
        print("(merge + export scripts not present — skipping GGUF export)")
        print(f"  saved adapter at: {adapter_dir}")
    return 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--persona", default="all", choices=["all"] + PERSONAS)
    ap.add_argument("--base", default="qikfox/starscream-throne-7b:latest",
                    help="HF model id or Ollama tag (will resolve via Ollama if local)")
    ap.add_argument("--epochs", type=int, default=2)
    ap.add_argument("--skip-export", action="store_true")
    args = ap.parse_args()

    personas = PERSONAS if args.persona == "all" else [args.persona]
    for p in personas:
        adapter = MODELS_DIR / f"{p}-adapter"
        gguf = MODELS_DIR / f"{p}.Q4_K_M.gguf"
        rc = train_one(p, args.base, adapter, epochs=args.epochs)
        if rc != 0:
            print(f"!! training failed for {p}")
            continue
        if not args.skip_export:
            merge_and_export(p, args.base, adapter, gguf)
    print("\nDONE.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
