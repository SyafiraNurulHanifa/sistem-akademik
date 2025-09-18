📚 Sistem Informasi Sekolah




Aplikasi mobile berbasis Flutter untuk siswa dan guru.

✨ Fitur Utama

🚀 Splash Screen

👥 Pilihan login (Student / Teacher)

📊 Dashboard untuk siswa & guru

📌 Menu navigasi (Profile, Attendance, Record, dll.)

📝 Edit Profile guru

🎨 Desain UI simpel & responsive

🗂️ Struktur Project
📁 lib/

main.dart → Titik masuk aplikasi

📁 screens/ (semua halaman)

splash_screen.dart → Splash Screen

choose_option_screen.dart → Pilih login (Student/Teacher)

teacher_login_screen.dart → Login Guru

teacher_dashboard.dart → Dashboard Guru

nav_menu.dart → Menu Navigasi

teacher_attendance.dart → Absensi Guru

record_screen.dart → Record (CheckIn - CheckOut)

teacher_profile.dart → Profile Guru

edit_teacher_profile.dart → Edit Profile Guru

student_login_screen.dart → Login Siswa

student_dashboard.dart → Dashboard Siswa

📁 widgets/ (widget kecil reusable)

custom_button.dart

custom_card.dart

custom_navbar.dart

📁 models/ (opsional, kalau pakai API/db)

user.dart

attendance.dart

📁 services/ (opsional, API / local storage)
🚀 Cara Menjalankan

Clone repository dari GitHub

Buka project di VS Code / Android Studio

Jalankan flutter pub get untuk install dependency

Run aplikasi di emulator atau device

📸 Screenshot

![alt text](image-1.png)
![alt text](image-2.png)