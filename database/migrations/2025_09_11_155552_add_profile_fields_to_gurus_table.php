<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Jalankan migrasi: tambah kolom profil ke tabel gurus
     */
    public function up(): void
    {
        Schema::table('gurus', function (Blueprint $table) {
            $table->string('nip')->nullable()->after('telepon');          // NIP guru
            $table->string('jabatan')->nullable()->after('nip');          // jabatan (misal: Guru Matematika)
            $table->year('tahun_masuk')->nullable()->after('jabatan');    // tahun masuk
            $table->string('foto_profil')->nullable()->after('tahun_masuk'); // path foto profil
        });
    }

    /**
     * Rollback migrasi: hapus kolom profil
     */
    public function down(): void
    {
        Schema::table('gurus', function (Blueprint $table) {
            $table->dropColumn(['nip', 'jabatan', 'tahun_masuk', 'foto_profil']);
        });
    }
};
