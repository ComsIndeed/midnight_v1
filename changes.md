# Changes Made to Midnight v1

This document outlines the significant structural and functional improvements implemented in the `midnight_v1` Flutter application.

## 1. Codebase Restructuring and Organization

*   **Refined Directory Structure:**
    *   The generic `lib/classes` directory has been deprecated. Its contents have been logically reorganized into:
        *   `lib/models/`: Now houses all plain data classes (`quiz.dart`, `source.dart`, `generate_quiz_response.dart`, `generate_questions_response.dart`).
        *   `lib/services/`: Dedicated to classes handling business logic and external API interactions (`inference.dart`, `embedding.dart`, `app_prefs.dart`).
        *   `lib/utils/`: Contains general utility functions and helpers (`trim_code_block.dart`, `file_helpers.dart`, `dialog_helpers.dart`, `prompts.dart`).
    *   The `QuizProgress` class, previously embedded in `lib/pages/quiz_page/quiz_page.dart`, has been extracted into its own model file: `lib/models/quiz_progress.dart`.
*   **Updated Import Paths:** All relevant import statements across the entire project have been meticulously updated to reflect the new file locations, ensuring code integrity and maintainability.

## 2. Architectural Enhancements

*   **`AppPrefs` Singleton Implementation:**
    *   The `AppPrefs` class has been refactored to adhere to a proper singleton pattern. This ensures a single, globally accessible instance for managing application preferences, improving consistency and preventing potential issues with multiple instances.
    *   Access to `AppPrefs` properties now uses `AppPrefs.instance.propertyName` instead of static access.
*   **Decoupled Repository Logic:**
    *   The `generateQuiz` method, which contained business logic, has been removed from `lib/repositories/quiz_repository.dart`. The `QuizRepository` now strictly adheres to its role of data persistence (loading and saving quizzes).
    *   Quiz generation logic is now handled directly by the `Inference` service within the `QuizzesBloc`.
*   **Optimized BLoC Event Handling:**
    *   The `_onDeleteQuiz`, `_onRenameQuiz`, and `_onClearAllQuizzes` handlers within `QuizzesBloc` have been optimized. Instead of triggering a full data reload from storage after an operation, they now directly update the BLoC's state and then asynchronously persist the changes to the repository. This significantly improves UI responsiveness and perceived performance.

## 3. Code Cleanliness and Maintainability

*   **Simplified Widget Logic:**
    *   **`QuizPage` (`lib/pages/quiz_page/quiz_page.dart`):** The complex `_showGenerateDialog` method, which previously contained significant business logic for generating new questions, has been refactored. This logic is now handled by a new `GenerateNewQuestions` event dispatched to the `QuizPageBloc`, making the widget more declarative and focused on UI presentation.
    *   **`QuizGenerationContainer` (`lib/pages/homepage/quiz_generation_container.dart`):** The redundant local `isGenerating` state has been removed. The widget now derives its generation status directly from the `QuizzesBloc`'s state (`QuizGenerationInProgress`), eliminating state synchronization issues and simplifying the widget's internal logic.
*   **Robust UUID Generation:**
    *   The custom, basic UUID generation logic in `lib/models/quiz.dart` has been replaced with the `uuid` package. This ensures the generation of universally unique identifiers, crucial for data integrity and preventing collisions.
*   **Extracted Utilities and Constants:**
    *   Common helper functions and hardcoded strings have been moved into dedicated utility files:
        *   `lib/utils/file_helpers.dart`: Contains logic for handling file bytes and MIME types, and building file preview widgets.
        *   `lib/utils/dialog_helpers.dart`: Encapsulates the `showQuizMenuOverlay` and `showRenameDialog` methods, promoting reusability and cleaner widget code.
        *   `lib/utils/prompts.dart`: Stores the hardcoded generative AI prompts, centralizing them for easier management and modification.
*   **Removed Obsolete Code:** The now-empty `lib/classes` directory has been removed, contributing to a cleaner and more focused codebase.

These changes collectively enhance the application's architecture, improve code readability and maintainability, and lay a stronger foundation for future development.
