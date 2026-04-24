// Frontend runtime configuration.
// Replace the Railway URL below once your backend is deployed.
(function() {
  const RAILWAY_API_BASE = 'https://plagiarismdetection-production.up.railway.app/api';
  const isLocalHost = ['localhost', '127.0.0.1'].includes(window.location.hostname);

  window.APP_CONFIG = {
    API_BASE: isLocalHost ? '/api' : RAILWAY_API_BASE
  };

  window.getApiBase = function() {
    return window.APP_CONFIG.API_BASE.replace(/\/$/, '');
  };

  window.getApiUrl = function(path) {
    const normalizedPath = path.startsWith('/') ? path : `/${path}`;
    return `${window.getApiBase()}${normalizedPath}`;
  };
})();
