<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Jalankan perubahan.
     */
    public function up(): void
    {
        Schema::table('gurus', function (Blueprint $table) {
            // Ubah kolom mapel jadi nullable
            $table->string('mapel')->nullable()->change();
        });
    }

    /**
     * Rollback perubahan.
     */
    public function down(): void
    {
        Schema::table('gurus', function (Blueprint $table) {
            // Kembalikan mapel jadi NOT NULL
            $table->string('mapel')->nullable(false)->change();
        });
    }
};
