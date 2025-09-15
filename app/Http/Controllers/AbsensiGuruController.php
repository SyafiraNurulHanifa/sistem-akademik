<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\AbsensiGuru;
use Carbon\Carbon;

class AbsensiGuruController extends Controller
{
    // Lokasi sekolah (hardcode, karena hanya 1 sekolah)
    private $schoolLat = -7.2575;  // ganti sesuai lokasi sekolah
    private $schoolLng = 112.7521; // ganti sesuai lokasi sekolah

    /**
     * Hitung jarak menggunakan rumus Haversine (dalam meter)
     */
    private function haversine($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371000; // meter

        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat / 2) * sin($dLat / 2) +
            cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
            sin($dLon / 2) * sin($dLon / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadius * $c;
    }

    /**
     * Guru Check-in
     */
    public function checkIn(Request $request)
    {
        $request->validate([
            'foto'      => 'required|image|mimes:jpg,jpeg,png|max:2048',
            'latitude'  => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $guru = $request->user();

        // Cek jarak dari sekolah
        $distance = $this->haversine(
            $this->schoolLat, $this->schoolLng,
            $request->latitude, $request->longitude
        );

        if ($distance > 500) {
            return response()->json([
                'message' => 'Anda berada di luar radius 500 meter dari sekolah. Check-in gagal.'
            ], 422);
        }

        // Cek apakah sudah check-in di tanggal hari ini
        $sudahCheckIn = AbsensiGuru::where('guru_id', $guru->id)
            ->where('tanggal', today())
            ->exists();

        if ($sudahCheckIn) {
            return response()->json(['message' => 'Anda sudah melakukan check-in hari ini'], 422);
        }

        // Simpan foto
        $path = $request->file('foto')->store('absensi/foto_check_in', 'public');

        // Tentukan status check-in (Masuk/Terlambat)
        $batasCheckin = Carbon::createFromTime(7, 30, 0); // 07:30
        $statusCheckin = now()->gt($batasCheckin) ? 'Terlambat' : 'Masuk';

        $absensi = AbsensiGuru::create([
            'guru_id'          => $guru->id,
            'tanggal'          => today(),
            'check_in'         => now(),
            'foto_check_in'    => $path,
            'status_check_in'  => $statusCheckin,
            'status_check_out' => 'Belum Check-out',
            'latitude'         => $request->latitude,
            'longitude'        => $request->longitude,
        ]);

        return response()->json([
            'message' => 'Check-in berhasil',
            'data' => $absensi
        ], 201);
    }

    /**
     * Guru Check-out
     */
    public function checkOut(Request $request)
    {
        $request->validate([
            'foto'      => 'required|image|mimes:jpg,jpeg,png|max:2048',
            'latitude'  => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $guru = $request->user();

        // Cek jarak dari sekolah
        $distance = $this->haversine(
            $this->schoolLat, $this->schoolLng,
            $request->latitude, $request->longitude
        );

        if ($distance > 500) {
            return response()->json([
                'message' => 'Anda berada di luar radius 500 meter dari sekolah. Check-out gagal.'
            ], 422);
        }

        // Cari absensi hari ini yang belum check-out
        $absensi = AbsensiGuru::where('guru_id', $guru->id)
            ->where('tanggal', today())
            ->whereNull('check_out')
            ->latest('check_in')
            ->first();

        if (!$absensi) {
            return response()->json(['message' => 'Tidak ada data check-in yang perlu check-out'], 422);
        }

        // Simpan foto
        $path = $request->file('foto')->store('absensi/foto_check_out', 'public');

        $absensi->update([
            'check_out'        => now(),
            'foto_check_out'   => $path,
            'status_check_out' => 'Berhasil',
            'latitude'         => $request->latitude,
            'longitude'        => $request->longitude,
        ]);

        return response()->json([
            'message' => 'Check-out berhasil',
            'data' => $absensi
        ]);
    }

    /**
     * Riwayat Absensi Guru (20 terakhir)
     */
    public function riwayat(Request $request)
    {
        $guru = $request->user();

        $riwayat = AbsensiGuru::where('guru_id', $guru->id)
            ->orderByDesc('tanggal')
            ->paginate(20);

        return response()->json($riwayat);
    }

    /**
     * Dashboard Attendance (summary + history)
     */
    public function dashboard(Request $request)
    {
        $guru = $request->user();
        $today = today();

        // Data hari ini
        $absensiHariIni = AbsensiGuru::where('guru_id', $guru->id)
            ->where('tanggal', $today)
            ->first();

        // Summary bulan ini
        $bulanIni = Carbon::now()->month;
        $tahunIni = Carbon::now()->year;

        $totalHadir = AbsensiGuru::where('guru_id', $guru->id)
            ->whereMonth('tanggal', $bulanIni)
            ->whereYear('tanggal', $tahunIni)
            ->count();

        $totalAbsence = now()->day - $totalHadir;

        // History (7 terakhir)
        $riwayat = AbsensiGuru::where('guru_id', $guru->id)
            ->orderByDesc('tanggal')
            ->take(7)
            ->get()
            ->map(function ($item) {
                $checkIn = $item->check_in ? Carbon::parse($item->check_in)->format('H:i') : null;
                $checkOut = $item->check_out ? Carbon::parse($item->check_out)->format('H:i') : null;

                $totalHours = null;
                if ($item->check_in && $item->check_out) {
                    $totalHours = Carbon::parse($item->check_in)->diff(Carbon::parse($item->check_out))->format('%H:%I');
                }

                return [
                    'tanggal' => Carbon::parse($item->tanggal)->format('d F Y'),
                    'hari' => Carbon::parse($item->tanggal)->translatedFormat('l'),
                    'check_in' => $checkIn,
                    'check_out' => $checkOut,
                    'total_hours' => $totalHours,
                    'lokasi' => 'Sekolah, Surabaya, Indonesia',
                ];
            });

        return response()->json([
            'date' => $today->translatedFormat('l, d F Y'),
            'location' => 'Surabaya, Indonesia',
            'today' => [
                'check_in' => $absensiHariIni?->check_in ? Carbon::parse($absensiHariIni->check_in)->format('H:i') : null,
                'check_out' => $absensiHariIni?->check_out ? Carbon::parse($absensiHariIni->check_out)->format('H:i') : null,
            ],
            'summary' => [
                'absence' => $totalAbsence,
                'total_attended' => $totalHadir,
            ],
            'history' => $riwayat,
        ]);
    }

    /**
     * List absensi semua guru berdasarkan tanggal (untuk admin)
     */
    public function listByDate($tanggal)
    {
        $absensi = AbsensiGuru::with('guru')
            ->where('tanggal', $tanggal)
            ->orderBy('check_in', 'asc')
            ->get();

        return response()->json([
            'tanggal' => $tanggal,
            'data' => $absensi
        ]);
    }
}
