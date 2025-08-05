Gemini CLI Task Instructions
Phase 1: Project Restructuring
Your first task is to reorganize the existing project files into a more scalable and feature-driven directory structure.

1. Create New Directories
Create the following new directories inside the lib/ folder:

lib/models/

lib/services/

lib/utils/

lib/repositories/

2. Move Existing Files
Move the following files to their new locations:

Move to lib/models/:

lib/models/generate_questions_response.dart

lib/models/generate_quiz_response.dart

lib/models/quiz.dart

lib/models/quiz_progress.dart

lib/models/source.dart

Move to lib/services/:

lib/services/app_prefs.dart

lib/services/embedding.dart

lib/services/inference.dart

Move to lib/utils/:

lib/utils/dialog_helpers.dart

lib/utils/file_helpers.dart

lib/utils/prompts.dart

lib/utils/trim_code_block.dart

Move to lib/repositories/:

lib/repositories/quiz_repository.dart

3. Update Import Statements
After moving all the files, traverse the entire lib/ directory and update all import statements to reflect the new file paths. Ensure the project still compiles without any import errors.

Phase 2: Chat History Feature Implementation
Next, implement the BLoC for managing chat histories.

1. Create Model Files
Create lib/models/chat_message.dart:

Define an enum MessageRole with two values: user and model.

Create an immutable class ChatMessage that extends Equatable.

It must have two final properties: role (of type MessageRole) and message (of type String).

Implement toMap and fromMap methods for JSON serialization.

Create lib/models/chat_history.dart:

Create an immutable class ChatHistory that extends Equatable.

It must have three final properties: id (String), title (String), and messages (a List<ChatMessage>).

Implement a copyWith method to create a new instance with updated values.

Implement toMap and fromMap methods for JSON serialization.

2. Create the Repository
Create lib/repositories/chat_history_repository.dart:

Create a class ChatHistoryRepository.

It should take SharedPreferences in its constructor.

Implement a loadChatHistories method that reads a map of chat histories from SharedPreferences and deserializes it into a Map<String, ChatHistory>.

Implement a saveChatHistories method that serializes a Map<String, ChatHistory> into a JSON string and saves it to SharedPreferences.

3. Create the BLoC
Create the directory lib/blocs/chat_history_bloc/.

Inside this new directory, create the following three files:

File 1: chat_history_event.dart

Define an abstract class ChatHistoryEvent that extends Equatable.

Create the following event classes that extend ChatHistoryEvent:

LoadChatHistories: No properties.

AddChatHistory: Takes a ChatHistory object.

UpdateChatHistory: Takes a ChatHistory object.

DeleteChatHistory: Takes a chatHistoryId string.

File 2: chat_history_state.dart

Define an abstract class ChatHistoryState that extends Equatable.

Create the following state classes that extend ChatHistoryState:

ChatHistoryInitial: Initial state.

ChatHistoryLoadInProgress: State for when data is being loaded.

ChatHistoryLoadSuccess: Holds a Map<String, ChatHistory> of the loaded chats.

ChatHistoryLoadFailure: Holds an error string.

File 3: chat_history_bloc.dart

Create a class ChatHistoryBloc that extends Bloc<ChatHistoryEvent, ChatHistoryState>.

It should take ChatHistoryRepository in its constructor.

Implement handlers for each event defined in chat_history_event.dart:

On LoadChatHistories, emit LoadInProgress, call the repository to get the data, and then emit LoadSuccess or LoadFailure.

On AddChatHistory, UpdateChatHistory, and DeleteChatHistory, get the current state, update the local map of chat histories immutably, emit a new LoadSuccess state with the updated map, and then call the repository to save the changes.