const mongoose = require('mongoose');
require('dotenv').config();

console.log('Creating Test Therapists...\n');

mongoose.connect(process.env.MONGODB_URI, {
  dbName: process.env.DB_NAME,
})
.then(() => {
  console.log('✅ MongoDB Connected!\n');
  
  const User = require('./models/User');
  
  // Create sample therapists
  const therapists = [
    {
      userId: 'therapist_001',
      email: `sarah.wilson@therapist.com`,
      role: 'therapist',
      displayName: 'Dr. Sarah Wilson',
      specialization: 'Clinical Psychologist',
      bio: 'Experienced psychologist specializing in anxiety, depression, and PTSD treatment.',
      photoUrl: 'https://placehold.co/200x200/6A5AE0/white?text=Dr.+Sarah',
    },
    {
      userId: 'therapist_002',
      email: `michael.chen@therapist.com`,
      role: 'therapist',
      displayName: 'Dr. Michael Chen',
      specialization: 'Licensed Therapist',
      bio: 'Helping individuals and couples build stronger relationships.',
      photoUrl: 'https://placehold.co/200x200/9087E5/white?text=Dr.+Michael',
    },
    {
      userId: 'therapist_003',
      email: `emma.rodriguez@therapist.com`,
      role: 'therapist',
      displayName: 'Dr. Emma Rodriguez',
      specialization: 'Counseling Psychologist',
      bio: 'Specialized in trauma recovery, grief counseling, and life transitions.',
      photoUrl: 'https://placehold.co/200x200/10B981/white?text=Dr.+Emma',
    },
  ];
  
  return Promise.all(
    therapists.map(therapist => 
      User.findOneAndUpdate(
        { email: therapist.email },
        therapist,
        { upsert: true, new: true }
      )
    )
  );
})
.then((createdTherapists) => {
  console.log('✅ Created Test Therapists:\n');
  createdTherapists.forEach((t, i) => {
    console.log(`${i + 1}. ${t.displayName} - ${t.specialization}`);
    console.log(`   Email: ${t.email}`);
    console.log(`   Role: ${t.role}\n`);
  });
  
  console.log('🎉 Test therapists created successfully!\n');
  process.exit(0);
})
.catch((err) => {
  console.error('\n❌ Error:', err.message);
  process.exit(1);
});
