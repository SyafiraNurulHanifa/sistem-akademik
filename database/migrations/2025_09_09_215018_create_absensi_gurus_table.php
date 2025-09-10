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
            $table->dateTime('check_in')->nullable();
            $table->string('foto_check_in')->nullable();   // bukti foto check-in
            $table->dateTime('check_out')->nullable();
            $table->string('foto_check_out')->nullable();  // bukti foto check-out
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('absensi_gurus');
    }
};
