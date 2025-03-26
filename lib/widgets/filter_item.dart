import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/image_filter.dart';
import '../services/image_processing.dart';

class FilterItem extends StatelessWidget {
  final ImageFilter filter;
  final bool isSelected;
  final Uint8List imageBytes;
  final VoidCallback onTap;

  const FilterItem({
    required this.filter,
    required this.isSelected,
    required this.imageBytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: FutureBuilder<Uint8List>(
                future: applyFilterPreview(imageBytes , filter),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return InkWell(
                      onTap: onTap,
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                    );
                  }
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey, // Placeholder color
                    ),
                  );
                  //return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            filter.name.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}