<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AbsensiGuruController;
use App\Http\Controllers\AuthGuruController;
use App\Http\Controllers\GuruController;
use App\Http\Controllers\ProfilGuruController; // <-- pakai nama file kamu

// ========== AUTH ==========
Route::post('/guru/register', [GuruController::class, 'store']); // bebas akses
Route::post('/guru/login', [AuthGuruController::class, 'login']);

// ========== ROUTES YANG PERLU LOGIN ==========
Route::middleware('auth:sanctum')->group(function () {

    // ----- AUTH -----
    Route::post('/guru/logout', [AuthGuruController::class, 'logout']);

    // ----- PROFIL GURU -----
    Route::prefix('guru')->group(function () {
        Route::get('/profile', [ProfilGuruController::class, 'show']);
        Route::post('/profile', [ProfilGuruController::class, 'update']);
    });

    // ----- ABSENSI GURU -----
    Route::prefix('guru/absensi')->group(function () {
        Route::post('/check-in', [AbsensiGuruController::class, 'checkIn']);
        Route::post('/check-out', [AbsensiGuruController::class, 'checkOut']);
        Route::get('/riwayat', [AbsensiGuruController::class, 'riwayat']);
    });

    // ----- ABSENSI ADMIN -----
    Route::prefix('admin/absensi')->group(function () {
        Route::post('/', [AbsensiGuruController::class, 'adminStore']); 
        Route::get('/{tanggal}', [AbsensiGuruController::class, 'listByDate']); 
    });

    // ----- CRUD GURU (ADMIN) -----
    Route::prefix('guru')->group(function () {
        Route::get('/', [GuruController::class, 'index']);
        Route::get('/{id}', [GuruController::class, 'show']);
        Route::put('/{id}', [GuruController::class, 'update']);
        Route::delete('/{id}', [GuruController::class, 'destroy']);
    });
});
