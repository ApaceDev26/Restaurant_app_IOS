import 'package:flutter/material.dart';

class BottomNavItemWidget extends StatelessWidget {
  final IconData iconData;
  final String label;
  final Function? onTap;
  final bool isSelected;
  final int? size;
  const BottomNavItemWidget(
      {super.key,
      required this.iconData,
      required this.label,
      this.onTap,
      this.isSelected = false,
      this.size});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap as void Function()?,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconData,
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.grey,
                size: size != null ? size!.toDouble() : 25,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
