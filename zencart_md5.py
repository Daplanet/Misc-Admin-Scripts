p="SeCuR3PwD";import hashlib as h;s=h.md5(p).hexdigest()[:2];pw=h.md5(s+p).hexdigest();print pw+":"+s;

