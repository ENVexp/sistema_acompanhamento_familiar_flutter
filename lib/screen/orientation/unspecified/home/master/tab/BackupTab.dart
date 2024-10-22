import 'package:flutter/material.dart';
import '../../../../../../themes/app_colors.dart';

class BackupTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Gerenciar Backups",
            style: TextStyle(fontFamily: 'ProductSansMedium', fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 5, // Exemplo de lista de backups
            itemBuilder: (context, index) {
              final backupDate = "Backup ${index + 1} - 2023-10-${10 + index}";
              return ListTile(
                title: Text(
                  backupDate,
                  style: TextStyle(fontFamily: 'ProductSansMedium'),
                ),
                subtitle: Text("Clique para restaurar este backup"),
                trailing: Icon(Icons.restore, color: AppColors.monteAlegreGreen),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Restaurando $backupDate")),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
