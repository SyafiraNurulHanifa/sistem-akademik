<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Admin extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    // Nama tabel
    protected $table = 'admins';

    // Kolom yang bisa diisi massal
    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    // Kolom yang disembunyikan saat response JSON
    protected $hidden = [
        'password',
        'remember_token',
    ];
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
        ];
    }
}
