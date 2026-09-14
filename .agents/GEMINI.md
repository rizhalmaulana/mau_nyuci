# Workspace Context: MauNyuci Mobile (Flutter)

**CRITICAL RULE:** This workspace is strictly for the **MauNyuci Mobile (Flutter)** project.

As an agent operating in this workspace, you must adhere to the following constraints:
1. **Focus on Mobile Context:** Your responses, code generation, and analysis must focus exclusively on Flutter and Dart, specifically within the `maunyuci_core`, `maunyuci_customer`, `maunyuci_driver`, and `maunyuci_store` directories.
2. **Do Not Mix Backend Context:** Do not provide .NET, C#, or backend API implementations here. If the user asks about the MauNyuci API or backend project, politely remind them that they are currently in the Mobile workspace and should use the other Antigravity IDE instance dedicated to the backend.
3. **Workspace Isolation:** Assume all file paths, debugging, and architecture discussions are scoped to the mobile frontend.
4. **API Constants:** Jika ada penambahan modul dengan endpoint baru, maka tambahkan terlebih dahulu di `api_constants.dart` (di dalam `maunyuci_core`) dan gunakan konstanta tersebut di provider/repository. Jangan pernah melakukan hardcode string endpoint secara langsung.

This rule ensures that the mobile agent remains laser-focused on Flutter and prevents mixed context from the backend project.
