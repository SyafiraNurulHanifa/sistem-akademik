<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('roles', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('id_guru')->nullable();
            $table->unsignedBigInteger('id_admin')->nullable();
            $table->unsignedBigInteger('id_siswa')->nullable();
            $table->string('role');
            $table->timestamps();

            // Relasi foreign key
            $table->foreign('id_guru')->references('id')->on('gurus')->onDelete('cascade');
            $table->foreign('id_admin')->references('id')->on('admins')->onDelete('cascade');
            $table->foreign('id_siswa')->references('id')->on('siswas')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('roles');
    }
};
