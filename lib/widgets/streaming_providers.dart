import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StreamingProviders extends StatelessWidget {
  final Map<String, dynamic> providers;

  const StreamingProviders({
    Key? key,
    required this.providers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (providers['flatrate'] != null)
          _buildProvidersList('Streaming On', providers['flatrate']),
        if (providers['rent'] != null)
          _buildProvidersList('Rent', providers['rent']),
        if (providers['buy'] != null)
          _buildProvidersList('Buy', providers['buy']),
      ],
    );
  }

  Widget _buildProviderImage(String? logoPath, String providerName) {
    if (logoPath == null) return const SizedBox.shrink();

    if (logoPath.startsWith('assets/')) {
      // Local asset
      return Image.asset(
        logoPath,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    } else {
      // TMDB image
      return CachedNetworkImage(
        imageUrl: 'https://image.tmdb.org/t/p/original$logoPath',
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildProvidersList(String title, List<dynamic> providersList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: providersList.length,
            itemBuilder: (context, index) {
              final provider = providersList[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Tooltip(
                  message: provider['provider_name'] ?? '',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: _buildProviderImage(
                      provider['logo_path'],
                      provider['provider_name'] ?? '',
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
