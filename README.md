# Cloud Chat App (UAS Cloud Computing)

Aplikasi Realtime Chat sederhana yang dibangun menggunakan Flutter dan Firebase (Serverless Architecture). Proyek ini dibuat untuk memenuhi Tugas Besar mata kuliah Cloud Computing.

## 🚀 Fitur Utama

Aplikasi ini memiliki fitur komunikasi realtime dengan spesifikasi berikut:

* Authentication: Login dan Register menggunakan Email & Password (Firebase Auth).
* User Search: Mencari pengguna lain berdasarkan email untuk memulai obrolan.
* Realtime Messaging: Kirim dan terima pesan secara instan tanpa refresh (Cloud Firestore).
* Profile Management: Update nama dan foto profil (Firebase Storage).
* Cloud Architecture: Aplikasi berjalan sepenuhnya di cloud tanpa backend server konvensional.

## 💾 Struktur Database (Cloud Firestore)

Aplikasi ini menggunakan database NoSQL dengan struktur koleksi sebagai berikut:

### Collection: users
Menyimpan data profil pengguna.
* uid (Document ID): ID unik dari Firebase Auth
* email: Alamat email pengguna
* displayName: Nama tampilan
* photoUrl: Link gambar profil dari Storage
* createdAt: Timestamp pendaftaran

### Collection: chat_rooms
Menyimpan riwayat percakapan antar pengguna.
* chatRoomId (Document ID): Kombinasi UID pengirim dan penerima
* users: Array berisi email peserta chat
* lastMessage: Pesan terakhir yang dikirim
* lastTime: Waktu pesan terakhir

### Sub-collection: messages
Menyimpan detail pesan di dalam chat_rooms.
* senderId: UID pengirim
* text: Isi pesan text
* timestamp: Waktu server saat dikirim

## 🛠️ Teknologi yang Digunakan

* Frontend: Flutter (Dart)
* Backend (BaaS): Firebase (Auth, Firestore, Storage)
* State Management: Native SetState / StreamBuilder

## 📦 Cara Install

1.  Clone repository ini.
2.  Jalankan flutter pub get untuk mengunduh dependency.
3.  Pastikan file konfigurasi Firebase (google-services.json) sudah terpasang.
4.  Jalankan flutter run.

---
Kelompok: [Isi Nama Kamu/Kelompok Disini]