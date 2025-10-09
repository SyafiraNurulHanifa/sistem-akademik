<?php

return [
    'defaults' => [
        'guard' => 'web',
        'passwords' => 'users',
    ],

    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'users',
        ],

        // GUARD UNTUK SEMUA ROLE
        'admin' => [
            'driver' => 'sanctum',
            'provider' => 'admins',
        ],

        'guru' => [
            'driver' => 'sanctum',
            'provider' => 'gurus',
        ],

        'siswa' => [
            'driver' => 'sanctum',
            'provider' => 'siswas',
        ],
    ],

    'providers' => [
        'users' => [
            'driver' => 'eloquent',
            'model' => App\Models\User::class,
        ],
        
        'admins' => [
            'driver' => 'eloquent',
            'model' => App\Models\Admin::class,
        ],
        
        'gurus' => [
            'driver' => 'eloquent',
            'model' => App\Models\Guru::class,
        ],
        
        'siswas' => [
            'driver' => 'eloquent',
            'model' => App\Models\Siswa::class, // Buat model Siswa jika belum ada
        ],
    ],

    'passwords' => [
        'users' => [
            'provider' => 'users',
            'table' => 'password_reset_tokens',
            'expire' => 60,
            'throttle' => 60,
        ],
    ],

    'password_timeout' => 10800,
];