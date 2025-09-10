<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\AbsensiGuru;

class AbsensiGuruController extends Controller
{
    public function checkIn(Request $request)
    {
        $request->validate([
            'foto' => 'required|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        $guru = $request->user();

        // Cek apakah sudah check-in hari ini
        $sudahCheckIn = AbsensiGuru::where('guru_id', $guru->id)
            ->whereDate('check_in', now())
            ->exists();

        if ($sudahCheckIn) {
            return response()->json(['message' => 'Anda sudah melakukan check-in hari ini'], 422);
        }

        $path = $request->file('foto')->store('absensi/foto_check_in', 'public');

        $absensi = AbsensiGuru::create([
            'guru_id'       => $guru->id,
            'check_in'      => now(),
            'foto_check_in' => $path,
        ]);

        return response()->json(['message' => 'Check-in berhasil', 'data' => $absensi], 201);
    }

    public function checkOut(Request $request)
    {
        $request->validate([
            'foto' => 'required|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        $guru = $request->user();

        // Cari absensi terakhir yang belum di-checkout
        $absensi = AbsensiGuru::where('guru_id', $guru->id)
            ->whereNull('check_out')
            ->latest('check_in')
            ->first();

        if (!$absensi) {
            return response()->json(['message' => 'Tidak ada data check-in yang perlu check-out'], 422);
        }

        $path = $request->file('foto')->store('absensi/foto_check_out', 'public');

        $absensi->update([
            'check_out'       => now(),
            'foto_check_out'  => $path,
        ]);

        return response()->json(['message' => 'Check-out berhasil', 'data' => $absensi]);
    }

    public function riwayat(Request $request)
    {
        $guru = $request->user();

        $riwayat = AbsensiGuru::where('guru_id', $guru->id)
            ->orderByDesc('check_in')
            ->paginate(20);

        return response()->json($riwayat);
    }
}
