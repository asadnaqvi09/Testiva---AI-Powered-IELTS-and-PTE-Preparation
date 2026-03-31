function toggleEye() {
    const inp = document.getElementById('pwdInput');
    const show = document.getElementById('eyeShow');
    const hide = document.getElementById('eyeHide');
    if (inp.type === 'password') {
      inp.type = 'text';
      show.style.display = 'none';
      hide.style.display = 'block';
    } else {
      inp.type = 'password';
      show.style.display = 'block';
      hide.style.display = 'none';
    }
  }
 
  function handleLogin() {
    const email = document.getElementById('emailInput').value.trim();
    const pwd   = document.getElementById('pwdInput').value;
    const btn   = document.getElementById('submitBtn');
    const err   = document.getElementById('errMsg');
 
    err.classList.remove('show');
 
    if (!email || !pwd) {
      err.querySelector('svg + *') || null;
      err.lastChild.textContent = ' Please enter both email and password.';
      err.classList.add('show');
      return;
    }
 
    // Loading state
    btn.classList.add('loading');
 
    setTimeout(() => {
      btn.classList.remove('loading');
      // Show error (demo — no real auth)
      err.innerHTML = `<svg viewBox="0 0 24 24" style="width:15px;height:15px;stroke:currentColor;fill:none;stroke-width:2.5;flex-shrink:0"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg> Invalid credentials. Please check your email and password.`;
      err.classList.add('show');
    }, 1800);
  }
 
  // Enter key support
  document.addEventListener('keydown', e => {
    if (e.key === 'Enter') handleLogin();
  });