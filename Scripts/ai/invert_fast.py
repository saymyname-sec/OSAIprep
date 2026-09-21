import numpy as np, itertools, time
from chromadb.utils import embedding_functions as ef
emb = ef.DefaultEmbeddingFunction()
words = open("/home/kali/osai/current/loot/bio400.txt").read().split()
tgt = np.load("/home/kali/osai/current/loot/target_vec.npy").astype(np.float32); tgt/=np.linalg.norm(tgt)

def E(strs,bs=4000):
    out=[]
    for i in range(0,len(strs),bs):
        v=np.array(emb(strs[i:i+bs]),dtype=np.float32); v/=np.linalg.norm(v,axis=1,keepdims=True); out.append(v)
    return np.vstack(out)

t0=time.time()
W=E(words)                       # 400 x 384 single-word vecs
# matching pursuit for 4 words (additive approx)
r=tgt.copy(); picks=[]
for _ in range(8):
    s=W@r
    for p in picks: s[p]=-9
    i=int(np.argmax(s)); picks.append(i)
    r=r-(W[i]@r)*W[i];
cand_idx=picks[:6]
print("greedy word candidates:", [words[i] for i in cand_idx], "t=%.0f"%(time.time()-t0))
# also add top single-word cosine picks as safety
top=list(np.argsort(-(W@tgt))[:8]);
pool=sorted(set(cand_idx+top))
poolw=[words[i] for i in pool]
print("pool:",poolw)
# exhaustive over ordered 4-tuples from pool, real hyphenated embedding
combos=[ "-".join(p) for p in itertools.permutations(poolw,4) ]
sc=E(combos)@tgt
o=np.argsort(-sc)
print("TOP:")
for i in o[:10]: print(f"  {sc[i]:.4f} {combos[i]}")
best=combos[o[0]]
if sc[o[0]]>=0.985:
    open("/home/kali/osai/current/loot/passphrase.txt","w").write(best+"\n")
    print("PASSPHRASE =>",best,"cos=%.4f"%sc[o[0]])
else:
    print("LOW CONFIDENCE best=%.4f -> beam still needed"%sc[o[0]])
