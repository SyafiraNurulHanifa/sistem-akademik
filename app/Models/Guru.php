<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Guru extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * Kolom yang boleh diisi mass-assignment
     */
    protected $fillable = [
        'nama',
        'email',
        'password',
        'mapel',          // masih dipakai di sistem absensi
        'telepon',
        'nip',            // tambahan untuk profil
        'jabatan',        // tambahan untuk profil
        'tahun_masuk',    // tambahan untuk profil
        'foto_profil',    // path file di storage
    ];

    /**
     * Kolom yang tidak boleh tampil di response JSON
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Casting otomatis untuk kolom tertentu
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password'          => 'hashed', // otomatis hash saat create/update
            'tahun_masuk'       => 'integer', // supaya saat return jadi angka
        ];
    }

    /**
     * Relasi ke AbsensiGuru
     * (1 guru bisa punya banyak absensi)
     */
    public function absensis()
    {
        return $this->hasMany(AbsensiGuru::class, 'guru_id');
    }
}
