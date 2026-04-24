module.exports = {
  apps: [
    {
      name: 'plagiarism-detection',
      script: './server.js',
      instances: 'max',
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production'
      },
      max_restarts: 10,
      min_uptime: '10s',
      max_memory_restart: '500M',
      error_file: './logs/error.log',
      out_file: './logs/out.log',
      log_file: './logs/combined.log',
      time_format: 'YYYY-MM-DD HH:mm:ss Z',
      watch: false,
      ignore_watch: ['node_modules', 'uploads', 'logs'],
      merge_logs: true,
      env_development: {
        NODE_ENV: 'development'
      }
    }
  ],
  deploy: {
    production: {
      user: 'node',
      host: 'your-server-ip',
      key: '~/.ssh/id_rsa',
      ref: 'origin/main',
      repo: 'https://github.com/yourusername/plagiarism-detection.git',
      path: '/var/www/plagiarism-detection',
      'post-deploy': 'cd backend && npm install && npm start'
    }
  }
};
