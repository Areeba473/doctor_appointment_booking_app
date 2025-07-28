String normalize(String input) =>
    input.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

String cleanDoctorName(String name) {
  return name.replaceFirst(RegExp(r'^Dr\.?\s*', caseSensitive: false), '').trim();
}

String getPatientIdFromEmail(String email) {
  return normalize(email.split('@').first);
}

String generateChatIdFromEmails(String patientEmail, String doctorEmail) {
  final patientId = getPatientIdFromEmail(patientEmail);
  final doctorId = getPatientIdFromEmail(doctorEmail);
  return '${normalize(patientId)}_doctor_${normalize(doctorId)}';
}
