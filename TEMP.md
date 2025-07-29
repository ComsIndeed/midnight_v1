# Context for QuizProgress Object

This document provides context regarding the `QuizProgress` object and its recent modifications.

## What is QuizProgress?
The `QuizProgress` class (defined in `lib/pages/quiz_page/quiz_page.dart`) is a data model responsible for storing a user's progress on a specific quiz. It contains:
- `userAnswers`: A map where the key is the question index (int) and the value is the user's answer (String).
- `correctness`: A map where the key is the question index (int) and the value is a boolean indicating if the user's answer was correct.

## Recent Modifications and Goal
During a recent refactoring to implement the BLoC (Business Logic Component) architecture, the application experienced UI freezing, particularly when answering questions in the quiz. This was traced back to the `toJson()` and `fromJson()` methods of the `QuizProgress` object, which perform JSON encoding and decoding. These operations, when executed on the main UI thread, can block the UI if the quiz data is substantial.

To address this performance issue, the `QuizPageBloc` (located in `lib/blocs/quiz_page_bloc/quiz_page_bloc.dart`) was modified to offload these JSON serialization and deserialization tasks to a **background isolate** using Flutter's `compute` function.

**The primary goal of this change was to ensure that:**
1.  The UI remains responsive and smooth, even when saving or loading large quiz progress data.
2.  The `QuizProgress` data is still correctly persisted using `shared_preferences`.
3.  The `QuizPageBloc` can interact with the `QuizProgress` data model efficiently without blocking the user interface.

Therefore, the `QuizProgress` object's core functionality remains the same, but the underlying mechanism for its persistence has been optimized for performance by utilizing background processing.

## Current State of `lib/pages/quiz_page/quiz_page.dart` (The "Mess")

Upon review, `lib/pages/quiz_page/quiz_page.dart` is in a highly broken state with numerous syntax and logical errors. It appears that during the refactoring, significant portions of code were misplaced, duplicated, or incorrectly modified, leading to a non-functional file. Key issues include:

-   **Duplicate `isMobile` declarations**: The `isMobile` variable is declared multiple times within the same scope.
-   **Incorrect `BlocBuilder` syntax**: The `builder` parameter of `BlocBuilder` is assigned using `=` instead of `:`.
-   **Misplaced `Scaffold`**: The `Scaffold` widget is incorrectly placed inside the `BlocBuilder`'s `builder` function, which should typically return only the content that reacts to state changes.
-   **Malformed `_showGenerateDialog` function**: This function, which was previously part of the `_QuizPageState` (a `StatefulWidget`), is now incorrectly defined within the `StatelessWidget` and has syntax errors.
-   **Missing Imports**: Several widgets and classes (`ResponsiveBreakpoints`, `AppbarTitle`, `MultipleChoiceQuizQuestionView`, `IdentificationQuizQuestionView`, `QuizPageLoadInProgress`, `QuizPageLoadSuccess`, `QuizPageLoadFailure`, `context.read`) are used without their necessary import statements.
-   **Incorrect `animate().fadeIn()` usage**: The `.animate().fadeIn()` chain is used on a `Padding` widget, suggesting a missing `flutter_animate` import or incorrect usage of the animation library.
-   **General Syntax Errors**: Numerous `expected_executable`, `missing_function_body`, `expected_token`, `missing_identifier`, `duplicate_definition`, `named_parameter_outside_group`, and `non_constant_default_value` errors indicate widespread syntax corruption and structural issues.
-   **Misplaced Code Blocks**: Large sections of code, particularly the `_showGenerateDialog` function and the mobile-specific `Positioned` widget, are found outside their correct structural context within the `build` method.

This file requires a thorough cleanup and re-structuring to align with the BLoC pattern and correct Flutter widget tree principles.