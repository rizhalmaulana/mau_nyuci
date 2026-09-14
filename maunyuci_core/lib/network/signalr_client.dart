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

  // Fungsi untuk gabung ke grup toko (dipanggil saat di dashboard kasir)
  Future<void> joinStoreGroup(String storeId) async {
    if (hubConnection.state == HubConnectionState.Connected) {
      await hubConnection.invoke("JoinStoreGroup", args: [storeId]);
      debugPrint("Joined Store Group: $storeId");
    }
  }

  // Fungsi untuk keluar grup toko
  Future<void> leaveStoreGroup(String storeId) async {
    if (hubConnection.state == HubConnectionState.Connected) {
      await hubConnection.invoke("LeaveStoreGroup", args: [storeId]);
      debugPrint("Left Store Group: $storeId");
    }
  }

  // Listen event DashboardUpdated
  void listenToDashboardUpdates(Function callback) {
    hubConnection.on("DashboardUpdated", (arguments) {
      debugPrint("SignalR Event Received: DashboardUpdated");
      callback();
    });
  }

  // Menghapus listener
  void stopListeningToDashboardUpdates() {
    hubConnection.off("DashboardUpdated");
  }

  // Listen event ReceiveNotification
  void listenToNotifications(Function(List<Object?>?) callback) {
    hubConnection.on("ReceiveNotification", (arguments) {
      debugPrint("SignalR Event Received: ReceiveNotification");
      callback(arguments);
    });
  }

  // Menghapus listener notifikasi
  void stopListeningToNotifications() {
    hubConnection.off("ReceiveNotification");
  }
}