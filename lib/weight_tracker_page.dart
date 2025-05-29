import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WeightTrackerPage extends StatefulWidget {
  const WeightTrackerPage({Key? key}) : super(key: key);

  @override
  State<WeightTrackerPage> createState() => _WeightTrackerPageState();
}

class _WeightTrackerPageState extends State<WeightTrackerPage> {
  final TextEditingController _weightController = TextEditingController();
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _loadSavedData().then((_) {
      if (_results.length >= 1000) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('عندك أكثر من 1000 إدخال، يُنصح بحذف أو تصدير بعض البيانات.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        });
      }
    });
  }


  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedString = prefs.getString('weight_results');

    if (savedString != null) {
      List<dynamic> decoded = jsonDecode(savedString);

      _results = decoded.where((entry) {
        DateTime date = DateTime.parse(entry['date']);
        List<DateTime> datesToRemove = [
          DateTime(date.year, 5, 1),
          DateTime(date.year, 5, 10),
          DateTime(date.year, 5, 20),
        ];
        return !datesToRemove.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
      }).map((e) => Map<String, dynamic>.from(e)).toList();
    }

    setState(() {});
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('weight_results', jsonEncode(_results));
  }

  void _addWeightEntry() {
    if (_weightController.text.isEmpty) return;
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال وزن صحيح أقل من 300 كجم'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final today = DateTime.now();
    final alreadyAdded = _results.any((entry) {
      final entryDate = DateTime.parse(entry['date']);
      return entryDate.year == today.year &&
          entryDate.month == today.month &&
          entryDate.day == today.day;
    });

    if (alreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('غير مسموح إلا بقيمة واحدة فقط يوميًا'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _results.add({
        'weight': weight,
        'date': DateTime.now().toIso8601String(),
      });
      _weightController.clear();
    });
    _saveData();
  }


  List<FlSpot> getWeightSpots() {
    return List.generate(_results.length, (i) {
      final weight = _results[i]['weight'] as num;
      return FlSpot(i.toDouble(), weight.toDouble());
    });
  }

  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return "${date.day}/${date.month}";
  }
  // ✅ أضف دي هنا:
  void _clearAllEntries() {
    setState(() {
      _results.clear();
    });
    _saveData();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    int index = value.toInt();
    if (index < 0 || index >= _results.length || index % 2 != 0) {
      return const SizedBox.shrink();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 6,
      child: Text(
        formatDate(_results[index]['date']),
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toStringAsFixed(1),
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _results.isEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double minY = isEmpty
        ? 0
        : _results.map((e) => e['weight'] as num).reduce((a, b) => a < b ? a : b).toDouble() - 1;
    double maxY = isEmpty
        ? 10
        : _results.map((e) => e['weight'] as num).reduce((a, b) => a > b ? a : b).toDouble() + 1;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'متتبع الوزن',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!isEmpty)
            IconButton(
              tooltip: 'مسح السجل',
              icon: Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                    title: Text(
                      'تأكيد الحذف',
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    ),
                    content: Text(
                      'هل أنت متأكد من مسح كل بيانات الوزن؟',
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('إلغاء', style: TextStyle(color: isDark ? Colors.grey : Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _clearAllEntries();
                        },
                        child: const Text('مسح', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            )
        ],
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;

                return TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    labelText: 'أدخل وزنك الحالي (كجم)',
                    labelStyle: TextStyle(color: isDark ? Colors.white : Colors.deepPurple),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: isDark ? Colors.white : Colors.deepPurple, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(
                      Icons.monitor_weight_outlined,
                      color: isDark ? Colors.white : Colors.deepPurple,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    fillColor: isDark ? Colors.grey[900] : Colors.white,
                    filled: true,
                  ),
                  cursorColor: isDark ? Colors.white : Colors.deepPurple,
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addWeightEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
              child: const Text(
                'حفظ الوزن',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              flex: 2,
              child: isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monitor_weight_outlined,
                      size: 60,
                      color: Theme.of(context).primaryColor,

                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد بيانات متاحة',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.8)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => Colors.deepPurple.withOpacity(0.7),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.spotIndex;
                            final entry = _results[index];
                            final dateStr = formatDate(entry['date']);
                            return LineTooltipItem(
                              'الوزن: ${spot.y.toStringAsFixed(1)} كجم\nالتاريخ: $dateStr',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },

                      ),
                      handleBuiltInTouches: true,
                    ),

                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: isDark ? Colors.grey[700]! : Colors.black12,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,

                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: bottomTitleWidgets,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false, // إخفاء الأرقام على الجانب
                        ),
                      ),
                      rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                            color: isDark ? Colors.grey[700]! : Colors.black12,
                            width: 1),
                        left: BorderSide(
                            color: isDark ? Colors.grey[700]! : Colors.black12,
                            width: 1),
                        right: BorderSide(color: Colors.transparent),
                        top: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: getWeightSpots(),
                        isCurved: true,
                        color: Theme.of(context).primaryColor,

                        barWidth: 4,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.deepPurple.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final item = _results[index];
                  final date = DateTime.parse(item['date']);
                  final formattedDate = "${date.day}/${date.month}/${date.year}";
                  final weight = item['weight'].toStringAsFixed(1);

                  final isDark = Theme.of(context).brightness == Brightness.dark;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(
                        Icons.monitor_weight,
                        color: isDark ? Colors.white : Colors.deepPurple,
                      ),
                      title: Text(
                        "الوزن: $weight كجم",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text("التاريخ: $formattedDate"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.red),
                        tooltip: 'مسح هذا الإدخال',
                        onPressed: () {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                              title: Text(
                                'تأكيد الحذف',
                                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              ),
                              content: Text(
                                'هل أنت متأكد من حذف هذا الإدخال؟',
                                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: Text('إلغاء', style: TextStyle(color: isDark ? Colors.grey : Colors.grey)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _results.removeAt(index);
                                    });
                                    _saveData();
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text('مسح', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    ),
                  );

                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
