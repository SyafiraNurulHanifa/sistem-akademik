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

        // Sanctum untuk API token
        'api' => [
            'driver' => 'sanctum',
            'provider' => null,
        ],

        // (opsional) guard session khusus guru kalau suatu saat perlu
        'guru' => [
            'driver' => 'session',
            'provider' => 'gurus',
        ],
    ],

    'providers' => [
        'users' => [
            'driver' => 'eloquent',
            'model' => App\Models\User::class,
        ],
        'gurus' => [
            'driver' => 'eloquent',
            'model' => App\Models\Guru::class,
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
