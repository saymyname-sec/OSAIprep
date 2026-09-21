import numpy as np, time, sys
from chromadb.utils import embedding_functions as ef
emb = ef.DefaultEmbeddingFunction()
words = open("/home/kali/osai/current/loot/bio400.txt").read().split()
tgt = np.load("/home/kali/osai/current/loot/target_vec.npy").astype(np.float32)
tgt = tgt/np.linalg.norm(tgt)

def embed_all(strs, bs=4000):
    out=[]
    for i in range(0,len(strs),bs):
        v=np.array(emb(strs[i:i+bs]),dtype=np.float32)
        v/=np.linalg.norm(v,axis=1,keepdims=True)
        out.append(v)
    return np.vstack(out)

def score(strs):
    return embed_all(strs)@tgt

log=open("/home/kali/osai/current/scripts/invert.log","w")
def L(m):
    log.write(m+"\n"); log.flush(); print(m)

t0=time.time()
beams=[""]
BW=[250,150,150,1]
for pos in range(4):
    cand=[(b+("-" if b else "")+w) for b in beams for w in words]
    s=score(cand)
    order=np.argsort(-s)
    keep=BW[pos]
    beams=[cand[i] for i in order[:keep]]
    L(f"pos{pos+1}: cand={len(cand)} best='{cand[order[0]]}' cos={s[order[0]]:.4f} t={time.time()-t0:.0f}s")
L(f"\nTOP RESULTS:")
final=score(beams)
o=np.argsort(-final)
for i in o[:10]:
    L(f"  {final[i]:.4f}  {beams[i]}")
best=beams[o[0]]
open("/home/kali/osai/current/loot/passphrase.txt","w").write(best+"\n")
L(f"\nPASSPHRASE => {best}  (cos={final[o[0]]:.4f})")
