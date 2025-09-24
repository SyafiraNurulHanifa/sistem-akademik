<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('absensi_gurus', function (Blueprint $table) {
            $table->id();
            $table->foreignId('guru_id')->constrained('gurus')->onDelete('cascade');

            // Kolom tanggal absensi
            $table->date('tanggal'); // default simpan tanggal hari absensi

            // Data check-in
            $table->dateTime('check_in')->nullable();
            $table->string('foto_check_in')->nullable();   
            $table->string('status_check_in')->default('Belum Check-in'); 
            // Masuk, Terlambat, Izin, Sakit, Belum Check-in

            // Data check-out
            $table->dateTime('check_out')->nullable();
            $table->string('foto_check_out')->nullable();  
            $table->string('status_check_out')->default('Belum Check-out'); 
            // Berhasil, Izin, Sakit, Belum Check-out

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('absensi_gurus');
    }
};
