<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Subject extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
    ];

    public function teachers()
    {
        return $this->belongsToMany(Teacher::class, 'class_subject_teacher', 'subject_id', 'teacher_id')
                    ->withPivot('class_id');
    }

    public function grades()
    {
        return $this->hasMany(Grade::class);
    }
}