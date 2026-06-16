import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';

class SignalRClient {
  late HubConnection hubConnection;

  void initConnection() {
    hubConnection = HubConnectionBuilder()
        .withUrl(ApiConstants.signalRHubUrl)
        .build();

    hubConnection.onclose(({error}) {
      debugPrint("SignalR Connection Closed: $error");
    });
  }

  Future<void> startConnection() async {
    if (hubConnection.state == HubConnectionState.Disconnected) {
      try {
        await hubConnection.start();
        debugPrint("SignalR Connected!");
      } catch (e) {
        debugPrint("Error connecting to SignalR: $e");
      }
    }
  }

  // Fungsi untuk gabung ke grup order tertentu (dipanggil saat buka detail order)
  Future<void> joinOrderGroup(String orderId) async {
    if (hubConnection.state == HubConnectionState.Connected) {
      await hubConnection.invoke("JoinGroup", args: [orderId]);
    }
  }

  // Fungsi untuk keluar grup agar hemat baterai/memori
  Future<void> leaveOrderGroup(String orderId) async {
    if (hubConnection.state == HubConnectionState.Connected) {
      await hubConnection.invoke("LeaveGroup", args: [orderId]);
    }
  }
}