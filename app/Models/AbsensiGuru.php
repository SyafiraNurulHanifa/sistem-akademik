<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AbsensiGuru extends Model
{
    use HasFactory;

    protected $table = 'absensi_gurus';

    /**
     * Kolom yang bisa diisi mass-assignment
     */
    protected $fillable = [
        'guru_id',
        'tanggal',
        'check_in',
        'foto_check_in',
        'status_check_in',
        'check_out',
        'foto_check_out',
        'status_check_out',
    ];

    /**
     * Casting otomatis
     * Supaya check_in & check_out selalu jadi instance Carbon
     */
    protected $casts = [
        'tanggal'   => 'date',
        'check_in'  => 'datetime',
        'check_out' => 'datetime',
    ];

    /**
     * Relasi ke tabel guru
     */
    public function guru()
    {
        return $this->belongsTo(Guru::class, 'guru_id');
    }

    /**
     * Accessor → URL lengkap untuk foto check-in
     */
    public function getFotoCheckinUrlAttribute()
    {
        return $this->foto_check_in ? asset('storage/' . $this->foto_check_in) : null;
    }

    /**
     * Accessor → URL lengkap untuk foto check-out
     */
    public function getFotoCheckoutUrlAttribute()
    {
        return $this->foto_check_out ? asset('storage/' . $this->foto_check_out) : null;
    }

    /**
     * Accessor → Jam check-in (H:i:s) atau null
     */
    public function getJamMasukAttribute()
    {
        return $this->check_in ? $this->check_in->format('H:i:s') : null;
    }

    /**
     * Accessor → Jam check-out (H:i:s) atau null
     */
    public function getJamPulangAttribute()
    {
        return $this->check_out ? $this->check_out->format('H:i:s') : null;
    }
}
