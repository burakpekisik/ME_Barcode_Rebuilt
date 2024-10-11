import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final List<Color> colors;
  final String title;
  final String? subtitle;
  final String value;
  final String status;
  final String? price;
  final double? percent;

  const CustomCard({
    super.key,
    required this.colors,
    required this.title,
    this.subtitle,
    required this.value,
    required this.status,
    this.price,
    this.percent,
  });

  // Function to make the text bold after ':' if present
  Widget _buildRichText(String text) {
    if (text.contains(':')) {
      final parts = text.split(':');
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${parts[0]}:',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: parts.length > 1 ? ' ${parts[1]}' : '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    } else {
      return Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Colors.black,
        ),
      );
    }
  }

  // Function to build the percent widget
  Widget _buildPercentWidget(double percent) {
    // If percent is positive, show upward arrow with green color
    if (percent > 0) {
      return Row(
        children: [
          const Icon(Icons.arrow_upward, color: Colors.green, size: 16),
          Text(
            '%${percent.toStringAsFixed(2)}', // Adding % sign and formatting the value
            style: const TextStyle(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      );
    }
    // If percent is negative, show downward arrow with red color
    else if (percent < 0) {
      return Row(
        children: [
          const Icon(Icons.arrow_downward, color: Colors.red, size: 16),
          Text(
            '-%${percent.abs().toStringAsFixed(2)}', // Adding -% sign and taking the absolute value
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      );
    }
    // If percent is 0 or null, return an empty container
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 4), // Shadow position
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          if (subtitle != null) _buildRichText(subtitle!),
          _buildRichText(value),
          _buildRichText(status),
          if (price != null)
            Text(
              "${price!} TL",
              style: const TextStyle(
                fontSize: 24,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          if (percent != null) _buildPercentWidget(percent!), // Conditionally render percent
        ],
      ),
    );
  }
}
