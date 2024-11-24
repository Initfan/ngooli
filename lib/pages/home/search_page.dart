// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ngooli/components/card_worker.dart';
import 'package:ngooli/components/rating.dart';
import 'package:ngooli/pages/home/worker_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  int selected = 0;
  RangeValues _currentRange = RangeValues(100, 200);

  void addHistorySearch(String search) async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList('search');
    if (!recent!.contains(_searchController.text)) {
      prefs.setStringList('search', [...recent, search]);
    }
  }

  void _showFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        minWidth: double.maxFinite,
        minHeight: MediaQuery.sizeOf(context).height * 0.4,
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Filter',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    height: 3,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    itemCount: 6 + 1,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(
                            left: index == 0 ? 10 : 0, right: 15),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              selected == index ? Colors.blueAccent : null,
                            ),
                          ),
                          onPressed: () => setState(() => selected = index),
                          child: Text(index == 0 ? 'All' : 'Cleaning'),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Price',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SizedBox(height: 30),
                RangeSlider(
                  min: 0,
                  max: 1000,
                  values: _currentRange,
                  labels: RangeLabels(
                    _currentRange.start.toStringAsFixed(0),
                    _currentRange.end.toStringAsFixed(0),
                  ),
                  onChanged: (RangeValues value) {
                    setState(() => _currentRange = value);
                  },
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Rating',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SizedBox(height: 10),
                Rating(),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    height: 3,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: null,
                          child: Text('Reset'),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: null,
                          child: Text('Filter'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void recentTap(String recent) {
    setState(() {
      _searchController.text = recent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    focusNode: focusNode,
                    onEditingComplete: () {
                      addHistorySearch(_searchController.text);
                      focusNode.unfocus();
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      fillColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.grey[100]
                              : Colors.grey[800],
                      filled: true,
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () => _showFilter(context),
                              child: Icon(Icons.filter_list_rounded),
                            )
                          : null,
                      hintText: 'Search',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            if (_searchController.text.isEmpty)
              RecentSearch(
                recentTap: recentTap,
              ),
            if (_searchController.text.isNotEmpty)
              SearchResult(
                search: _searchController.text,
              ),
          ],
        ),
      ),
    );
  }
}

class SearchResult extends StatefulWidget {
  const SearchResult({super.key, required this.search});

  final String search;

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  int found = 0;

  Future<QuerySnapshot> searchWorker() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('worker')
        .where('service', isEqualTo: widget.search)
        .get();
    setState(() => found = snapshot.docs.length);
    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                text: 'Results for ',
                children: [
                  TextSpan(
                    text: '"${widget.search}"',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ],
              ),
            ),
            Text('$found found'),
          ],
        ),
        FutureBuilder<QuerySnapshot>(
          future: searchWorker(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('loading...');
            }
            if (snapshot.data!.docs.isEmpty) {
              return _notFound();
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkerDetail(worker: data),
                    ),
                  ),
                  child: CardWorker(data: data),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _notFound() {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Text(
              'Not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Sorry, the keyword you entered cannot be found. please check again or search with another keyword',
              textAlign: TextAlign.center,
            )
          ],
        ),
      );
    });
  }
}

class RecentSearch extends StatefulWidget {
  const RecentSearch({super.key, this.recentTap});

  final void Function(String recent)? recentTap;

  @override
  State<RecentSearch> createState() => _RecentSearchState();
}

class _RecentSearchState extends State<RecentSearch> {
  List<String> recents = [];

  @override
  void initState() {
    super.initState();
    recentSearch();
  }

  Future<void> recentSearch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recents = prefs.getStringList('search')!;
    });
  }

  void removeRecent(String recent) async {
    final prefs = await SharedPreferences.getInstance();
    final items =
        prefs.getStringList('search')!.where((x) => x != recent).toList();
    await prefs.setStringList('search', items);
    setState(() {
      recents = items;
    });
  }

  void removeAllRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search', []);
    setState(() {
      recents = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (recents.isEmpty) {
      return Text('Search for service');
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent'),
            GestureDetector(
              onTap: removeAllRecent,
              child: Text('Clear All'),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: recents.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => widget.recentTap!(recents[index]),
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(recents[index]),
                    GestureDetector(
                      onTap: () => removeRecent(recents[index]),
                      child: Icon(Icons.cancel_presentation),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
