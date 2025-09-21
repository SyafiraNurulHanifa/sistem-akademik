<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Role extends Model
{
    use HasFactory;

    protected $table = 'roles'; // pastikan sama dengan nama tabel di DB
    protected $fillable = ['id_guru', 'id_admin', 'id_siswa', 'role'];

    // Relasi contoh:
    public function guru()
    {
        return $this->belongsTo(Guru::class, 'id_guru');
    }

    public function admin()
    {
        return $this->belongsTo(Admin::class, 'id_admin');
    }

    public function siswa()
    {
        return $this->belongsTo(Siswa::class, 'id_siswa');
    }
}
