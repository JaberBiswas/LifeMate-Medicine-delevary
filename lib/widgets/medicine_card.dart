import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/medicine_model.dart';
import '../utils/theme.dart';

class MedicineCard extends StatelessWidget {
  final MedicineModel medicine;
  final VoidCallback onTap;

  const MedicineCard({
    super.key,
    required this.medicine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: medicine.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: AppTheme.lightGray,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: AppTheme.lightGray,
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medicine.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.gray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₹${medicine.finalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        if (medicine.discountPrice != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '₹${medicine.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              color: AppTheme.gray,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
