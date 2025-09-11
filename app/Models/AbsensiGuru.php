<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

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
     * Casting otomatis untuk jam (biar rapi di JSON)
     */
    protected $casts = [
        'check_in'  => 'datetime:H:i:s',
        'check_out' => 'datetime:H:i:s',
    ];

    /**
     * Accessor → format tanggal menjadi "11 September 2025"
     */
    public function getTanggalAttribute($value)
    {
        return $value ? Carbon::parse($value)->translatedFormat('d F Y') : null;
    }

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
