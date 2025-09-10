<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AbsensiGuru extends Model
{
    use HasFactory;

    protected $fillable = [
        'guru_id',
        'check_in',
        'foto_check_in',
        'check_out',
        'foto_check_out',
    ];

    /**
     * Relasi ke model Guru
     */
    public function guru()
    {
        return $this->belongsTo(Guru::class);
    }

    /**
     * Eager load default (otomatis load guru tiap ambil absensi)
     */
    protected $with = ['guru'];

    /**
     * Cast otomatis supaya check_in dan check_out jadi instance Carbon
     */
    protected $casts = [
        'check_in'  => 'datetime',
        'check_out' => 'datetime',
    ];
}
