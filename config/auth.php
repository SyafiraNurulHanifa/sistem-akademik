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

        // ❌ HAPUS/COMMENT GUARD 'api' INI - INI PENYEBAB RECURSION
        // 'api' => [
        //     'driver' => 'sanctum',
        //     'provider' => 'admins',
        // ],

        // ✅ GUARD UNTUK ADMIN
        'admin' => [
            'driver' => 'sanctum',
            'provider' => 'admins',
        ],

        // ✅ GUARD UNTUK GURU
        'guru' => [
            'driver' => 'sanctum', 
            'provider' => 'gurus',
        ],

        // ✅ GUARD UNTUK SISWA (jika ada)
        'siswa' => [
            'driver' => 'sanctum',
            'provider' => 'siswas',
        ],
    ],

    'providers' => [
        // ✅ KEMBALIKAN 'users' PROVIDER (wajib untuk Laravel)
        'users' => [
            'driver' => 'eloquent',
            'model' => App\Models\User::class, // Biarkan meski tidak dipakai
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
            'model' => App\Models\Siswa::class,
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
];