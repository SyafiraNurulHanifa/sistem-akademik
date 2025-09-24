<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Teacher extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'nip',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function grades()
    {
        return $this->hasMany(Grade::class);
    }

    public function waliKelas()
    {
        return $this->hasOne(SchoolClass::class, 'wali_kelas_id');
    }

    public function subjects()
    {
        return $this->belongsToMany(Subject::class, 'class_subject_teacher', 'teacher_id', 'subject_id')
                    ->withPivot('class_id');
    }
}