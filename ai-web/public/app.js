(() => {
  const backendSelect = document.getElementById('backend');
  const promptInput = document.getElementById('prompt');
  const sendButton = document.getElementById('send');
  const voiceButton = document.getElementById('voice');
  const speakButton = document.getElementById('speak');
  const log = document.getElementById('log');

  let lastReply = '';
  let isSending = false;

  function appendLog(role, text) {
    const wrapper = document.createElement('div');
    wrapper.className = 'message';

    const label = document.createElement('strong');
    label.textContent = role === 'user' ? 'YOU' : 'AI';

    const body = document.createElement('div');
    body.textContent = text;

    wrapper.appendChild(label);
    wrapper.appendChild(body);
    log.appendChild(wrapper);
    log.scrollTop = log.scrollHeight;
  }

  async function sendMessage() {
    if (isSending) return;

    const backend = backendSelect.value;
    const prompt = promptInput.value.trim();
    if (!prompt) return;

    appendLog('user', prompt);
    isSending = true;
    sendButton.disabled = true;

    try {
      const res = await fetch('/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ backend, prompt }),
      });

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        const msg = data.error || `Request failed with status ${res.status}`;
        appendLog('ai', `Error: ${msg}`);
        return;
      }

      const data = await res.json();
      const reply = (data.reply || '').toString();
      lastReply = reply;
      appendLog('ai', reply || '[empty reply]');
    } catch (err) {
      appendLog('ai', `Network error: ${err}`);
    } finally {
      isSending = false;
      sendButton.disabled = false;
    }
  }

  // Basic Web Speech API integration for voice input (where available)
  function setupVoice() {
    const SpeechRecognition =
      window.SpeechRecognition || window.webkitSpeechRecognition || null;

    if (!SpeechRecognition) {
      voiceButton.addEventListener('click', () => {
        alert('Voice input not supported in this browser.');
      });
      return;
    }

    const recognition = new SpeechRecognition();
    recognition.lang = 'en-US';
    recognition.interimResults = false;
    recognition.maxAlternatives = 1;

    recognition.addEventListener('result', (event) => {
      const transcript = event.results[0][0].transcript;
      if (promptInput.value) {
        promptInput.value += '\n' + transcript;
      } else {
        promptInput.value = transcript;
      }
    });

    recognition.addEventListener('error', (event) => {
      console.error('Speech recognition error', event.error);
      alert('Voice input error: ' + event.error);
    });

    voiceButton.addEventListener('click', () => {
      try {
        recognition.start();
      } catch (err) {
        console.error('Failed to start recognition', err);
      }
    });
  }

  function setupSpeak() {
    if (!('speechSynthesis' in window)) {
      speakButton.addEventListener('click', () => {
        alert('Speech synthesis is not supported in this browser.');
      });
      return;
    }

    speakButton.addEventListener('click', () => {
      if (!lastReply) return;
      const utterance = new SpeechSynthesisUtterance(lastReply);
      window.speechSynthesis.cancel();
      window.speechSynthesis.speak(utterance);
    });
  }

  sendButton.addEventListener('click', sendMessage);
  promptInput.addEventListener('keydown', (event) => {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      sendMessage();
    }
  });

  setupVoice();
  setupSpeak();
})();
