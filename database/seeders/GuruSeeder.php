<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Guru;

class GuruSeeder extends Seeder
{
    public function run(): void
    {
        $gurus = [
            [
                'nama'     => 'Guru Matematika',
                'email'    => 'matematika@example.com',
                'password' => 'password123',
                'mapel'    => 'Matematika',
                'telepon'  => '081111111111',
            ],
            [
                'nama'     => 'Guru Bahasa Indonesia',
                'email'    => 'bahasa@example.com',
                'password' => 'password123',
                'mapel'    => 'Bahasa Indonesia',
                'telepon'  => '082222222222',
            ],
            [
                'nama'     => 'Guru IPA',
                'email'    => 'ipa@example.com',
                'password' => 'password123',
                'mapel'    => 'IPA',
                'telepon'  => '083333333333',
            ],
        ];

        foreach ($gurus as $guru) {
            Guru::updateOrCreate(
                ['email' => $guru['email']], // cek kalau sudah ada berdasarkan email
                $guru   // data yang akan dibuat/diupdate
            );
        }
    }
}
