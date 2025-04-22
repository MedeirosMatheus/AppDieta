import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class Meal {
  String name;
  int calories;

  Meal({required this.name, required this.calories});

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
      };

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'],
      calories: json['calories'],
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Meal> meals = [];

  @override
  void initState() {
    super.initState();
    loadMeals();
  }

  void loadMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? saved = prefs.getStringList('meals');
    setState(() {
      meals = saved?.map((e) => Meal.fromJson(json.decode(e))).toList() ?? [];
    });
  }

  void saveMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> data = meals.map((e) => json.encode(e.toJson())).toList();
    prefs.setStringList('meals', data);
  }

  void addMeal(Meal meal) {
    setState(() {
      meals.add(meal);
    });
    saveMeals();
  }

  int get totalCalories => meals.fold(0, (sum, item) => sum + item.calories);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(meals: meals, totalCalories: totalCalories, onAddMeal: addMeal),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<Meal> meals;
  final int totalCalories;
  final Function(Meal) onAddMeal;

  HomeScreen({required this.meals, required this.totalCalories, required this.onAddMeal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Minhas Refeições')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return ListTile(
                  title: Text(meal.name),
                  trailing: Text('${meal.calories} cal'),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Total de Calorias: $totalCalories'),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newMeal = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddMealScreen()),
          );
          if (newMeal != null) {
            onAddMeal(newMeal);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddMealScreen extends StatefulWidget {
  @override
  _AddMealScreenState createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final nameController = TextEditingController();
  final caloriesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nova Refeição')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nome da Refeição'),
            ),
            TextField(
              controller: caloriesController,
              decoration: InputDecoration(labelText: 'Calorias'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final calories = int.tryParse(caloriesController.text) ?? 0;
                if (name.isNotEmpty && calories > 0) {
                  Navigator.pop(context, Meal(name: name, calories: calories));
                }
              },
              child: Text('Salvar'),
            )
          ],
        ),
      ),
    );
  }
}
