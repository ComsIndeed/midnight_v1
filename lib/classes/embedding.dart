import 'dart:math'; // Import for sqrt function

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:midnight_v1/classes/app_prefs.dart';

class Embedding {
  static final model = GenerativeModel(
    model: "gemini-embedding-001",
    apiKey: AppPrefs.apiKey,
  );

  /// Calculates the cosine similarity between two embedding vectors.
  ///
  /// Takes two lists of doubles representing the embeddings.
  /// Returns a double between -1.0 (opposition) and 1.0 (similarity).
  /// A value of 0.0 indicates no correlation.
  static double compareEmbeddings(
    List<double> embedding1Values,
    List<double> embedding2Values,
  ) {
    if (embedding1Values.length != embedding2Values.length) {
      throw ArgumentError('Embedding vectors must have the same dimension.');
    }

    // Calculate Dot Product
    double dotProduct = 0.0;
    for (int i = 0; i < embedding1Values.length; i++) {
      dotProduct += embedding1Values[i] * embedding2Values[i];
    }

    // Calculate Magnitude (Norm) for embedding1
    double magnitude1 = 0.0;
    for (double value in embedding1Values) {
      magnitude1 += value * value;
    }
    magnitude1 = sqrt(magnitude1);

    // Calculate Magnitude (Norm) for embedding2
    double magnitude2 = 0.0;
    for (double value in embedding2Values) {
      magnitude2 += value * value;
    }
    magnitude2 = sqrt(magnitude2);

    // Cosine Similarity Calculation
    if (magnitude1 == 0 || magnitude2 == 0) {
      return 0.0; // Avoid division by zero if one of the vectors is a zero vector
    }

    return dotProduct / (magnitude1 * magnitude2);
  }

  /// Fetches embeddings for two contents and then calculates their cosine similarity.
  ///
  /// Returns a double between -1.0 (opposition) and 1.0 (similarity).
  static Future<double> compare(Content content1, Content content2) async {
    final embeddingsResponse = await model.batchEmbedContents([
      EmbedContentRequest(content1, taskType: TaskType.semanticSimilarity),
      EmbedContentRequest(content2, taskType: TaskType.semanticSimilarity),
    ]);

    // Ensure we received two embeddings
    if (embeddingsResponse.embeddings.length < 2) {
      throw Exception('Failed to get two embeddings for comparison.');
    }

    final List<double> embedding1Values =
        embeddingsResponse.embeddings[0].values;
    final List<double> embedding2Values =
        embeddingsResponse.embeddings[1].values;

    // Use the new _compareEmbeddings method to get the similarity
    return compareEmbeddings(embedding1Values, embedding2Values);
  }
}
