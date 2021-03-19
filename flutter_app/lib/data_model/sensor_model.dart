class SensorModel {
  int accX, gyroX;
  int accY, gyroY;
  int accZ, gyroZ;
  String timestamp;
  int packetId;

  SensorModel({
    this.accX,
    this.accY,
    this.accZ,
    this.gyroX,
    this.gyroY,
    this.gyroZ,
    this.timestamp,
    this.packetId,
  });

  Map<String, dynamic> toMap() {
    return {
      'acc_x': accX,
      'acc_y': accY,
      'acc_z': accZ,
      'gyro_x': gyroX,
      'gyro_y': gyroY,
      'gyro_z': gyroZ,
      'timestamp': timestamp,
      'packetId': packetId,
    };
  }

  factory SensorModel.fromMap(Map<String, dynamic> json) => new SensorModel(
        accX: json["acc_x"],
        accY: json["acc_y"],
        accZ: json["acc_z"],
        gyroX: json["gyro_x"],
        gyroY: json["gyro_y"],
        gyroZ: json["gyro_z"],
        timestamp: json["timestamp"],
        packetId: json["packetId"],
      );

  @override
  String toString() {
    return 'timestamp: $timestamp, packetId: $packetId \n '
        'Accelerometer{x: $accX, y: $accY, z: $accZ,}\n'
        'Gyroscope{x: $gyroX, y: $gyroY, z: $gyroZ,}';
  }
}
