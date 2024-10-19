// MasterScreenHorizontal.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../../../../themes/app_colors.dart';
import 'UserDataController.dart';
import 'UserDialogs.dart';


class MasterScreenHorizontal extends StatefulWidget {
  @override
  _MasterScreenHorizontalState createState() => _MasterScreenHorizontalState();
}

class _MasterScreenHorizontalState extends State<MasterScreenHorizontal> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    Provider.of<UserDataController>(context, listen: false).initializeUser();
    _scrollController.addListener(() {
      setState(() {
        _isFabVisible = _scrollController.position.userScrollDirection == ScrollDirection.forward;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDataController = Provider.of<UserDataController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() => userDataController.searchQuery = value);
                    userDataController.applyFilters();
                  },
                  decoration: InputDecoration(
                    labelText: "Pesquisar usuários",
                    labelStyle: TextStyle(fontFamily: 'ProductSansMedium', color: AppColors.monteAlegreGreen),
                    prefixIcon: Icon(Icons.search, color: AppColors.monteAlegreGreen),
                    border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.monteAlegreGreen)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.monteAlegreGreen)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.monteAlegreGreen, width: 2.0)),
                  ),
                  cursorColor: AppColors.monteAlegreGreen,
                  style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.black),
                ),
                SizedBox(height: 10),
                if (!userDataController.isCoordination)
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: userDataController.selectedFilter,
                          isExpanded: true,
                          items: userDataController.filters.map((filter) {
                            return DropdownMenuItem<String>(
                              value: filter,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(filter, style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.black)),
                                  if (filter != "Todos")
                                    IconButton(
                                      icon: Icon(Icons.edit, color: AppColors.monteAlegreGreen),
                                      onPressed: () => UserDialogs.showEditUnitDialog(context, filter, userDataController),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              userDataController.selectedFilter = value!;
                              userDataController.applyFilters();
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: AppColors.monteAlegreGreen),
                        onPressed: () => UserDialogs.showAddUnitBottomSheet(context),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (userDataController.isLoading)
            Center(child: CircularProgressIndicator(color: AppColors.monteAlegreGreen))
          else
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                itemCount: userDataController.filteredUsers.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey[300], thickness: 1, height: 1),
                itemBuilder: (context, index) {
                  final user = userDataController.filteredUsers[index];
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.nome, style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.black)),
                        Text(user.email, style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.grey)),
                      ],
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(user.unidade, style: TextStyle(fontFamily: 'ProductSansMedium', color: Colors.grey)),
                        Text(
                          user.estado,
                          style: TextStyle(
                            fontFamily: 'ProductSansMedium',
                            color: user.estado.toLowerCase() == 'ativado' ? AppColors.monteAlegreGreen : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => UserDialogs.showUserDialog(context, user),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
        onPressed: () => UserDialogs.showCreateUserBottomSheet(context),
        backgroundColor: AppColors.monteAlegreGreen,
        child: Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}