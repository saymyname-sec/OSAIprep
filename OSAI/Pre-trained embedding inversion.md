**ALGEN with canary embeddings**
attacker@rag:~$ `wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh`

attacker@rag:~$ `bash /tmp/miniconda.sh -b -p ~/miniconda3`

attacker@rag:~$ `~/miniconda3/bin/conda init bash && source ~/.bashrc`

attacker@rag:~$ `conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main`

attacker@rag:~$ `conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r`

attacker@rag:~$ `conda create -n algen python=3.12 -y`

attacker@rag:~$ `conda activate algen`

(algen) attacker@rag:~$ `cd ALGEN`

(algen) attacker@rag:~/ALGEN$ `pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128`

(algen) attacker@rag:~/ALGEN$ `pip3 install -r requirements.txt`

(algen) attacker@rag:~/ALGEN$ `pip3 install sentence-transformers sacrebleu`

```
python generate_algen_training_data.py \
      --domain it_password,infrastructure_credentials,hr_employee,api_developer,cloud_aws,cloud_azure,network_vpn,ci_cd_devops,email_smtp,financial_banking,legal_confidential,medical_hipaa,customer_pii,internal_strategy,certificate_tls,encryption_keys,oauth_sso,database_connection,vendor_partner,saas_credentials \
      -o /tmp/canary_source \
      --count 50000 --val-size 500 --test-size 500
```

```
python insert_canaries.py \
      --source-dir /tmp/canary_source \
      --weaviate-url http://localhost:8080
```

`sudo systemctl stop vllm`

```
WANDB_MODE=disabled python src/exp.py \
      --model_name google/flan-t5-small \
      --output_dir outputs/flan-t5-small-canary-50k \
      --max_length 64 \
      --data_folder datasets/finetuning_decoder \
      --lang eng_canary \
      --train_samples 49000 \
      --val_samples 500 \
      --batch_size 32 \
      --learning_rate 1e-4 \
      --weight_decay 1e-4 \
      --num_epochs 50
```

```
python run_attack.py \
      --canary-embeddings export/canary_embeddings.npy \
      --embeddings export/embeddings.npy \
      --output algen_results.json
```

**Inference probing for template recovery**

```
python rag_probe_attack.py \
      --algen-output algen_results.json \
      --rag-url http://localhost:80 \
      --chunk 0 \
      -o probe_template.json
```

**Vec2Text**

*The training process will take several hours up to multiple days. As with ALGEN, checkpoints have been prepared that you can run the attack without waiting for the training process to complete. To do so, continue following the hands-on steps of this walkthrough at Listing 30.*

```
python prepare_data.py \
      --source hybrid \
      --max-samples 500000 \
      --output-dir data
```

```
python train_inverter.py \
      --data-dir data \
      --output-dir checkpoints/inverter \
      --batch-size 8 --grad-accum 16 --lr 1e-4 \
      --epochs 20 --eval-steps 2000 --no-wandb
```

```
python train_corrector.py \
      --data-dir data \
      --inverter-checkpoint checkpoints/inverter/best.pt \
      --output-dir checkpoints/corrector \
      --batch-size 8 --grad-accum 16 --lr 5e-5 \
      --epochs 5 --eval-steps 2000 --no-wandb
```

`python attack.py ../embeddings.npy        --wordlist passwords.txt       -o attack_results.json -v`