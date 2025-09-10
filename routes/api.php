<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AbsensiGuruController;
use App\Http\Controllers\AuthGuruController;
use App\Http\Controllers\GuruController;

// Auth
Route::post('/guru/register', [GuruController::class, 'store']); // bebas akses
Route::post('/guru/login', [AuthGuruController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/guru/logout', [AuthGuruController::class, 'logout']);

    // Absensi
    Route::post('/guru/absensi/check-in', [AbsensiGuruController::class, 'checkIn']);
    Route::post('/guru/absensi/check-out', [AbsensiGuruController::class, 'checkOut']);
    Route::get('/guru/absensi/riwayat', [AbsensiGuruController::class, 'riwayat']);

    // CRUD Guru kecuali store
    Route::get('/guru', [GuruController::class, 'index']);
    Route::get('/guru/{id}', [GuruController::class, 'show']);
    Route::put('/guru/{id}', [GuruController::class, 'update']);
    Route::delete('/guru/{id}', [GuruController::class, 'destroy']);
});
