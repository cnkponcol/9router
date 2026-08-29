# Backup Scope

Repository ini adalah snapshot konfigurasi dan control layer 9Router yang aman.

Tidak disertakan: `data/`, OAuth/provider tokens, JWT secret, runtime database, logs, PID/run state, monitor state, `node_modules`, `.env`, serta arsip backup.

Untuk restore, clone repository, jalankan `npm install`, lalu pulihkan credential/provider state secara terpisah. Dependency utama 9Router mengikuti versi di `package-lock.json`.
