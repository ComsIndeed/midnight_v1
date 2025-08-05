# Chat History BLoC Report

## Overview

The `ChatHistoryBloc` is responsible for managing the state of the chat histories. It uses the `ChatHistoryRepository` to load and save chat histories from `SharedPreferences`.

## Events

- `LoadChatHistories`: Loads all chat histories from the repository.
- `AddChatHistory`: Adds a new chat history.
- `UpdateChatHistory`: Updates an existing chat history.
- `DeleteChatHistory`: Deletes a chat history.

## States

- `ChatHistoryInitial`: The initial state of the BLoC.
- `ChatHistoryLoadInProgress`: The state when the BLoC is loading chat histories.
- `ChatHistoryLoadSuccess`: The state when the BLoC has successfully loaded the chat histories.
- `ChatHistoryLoadFailure`: The state when the BLoC has failed to load the chat histories.

## How it Works

The `ChatHistoryBloc` listens for `ChatHistoryEvent`s and updates its state accordingly. When the BLoC receives a `LoadChatHistories` event, it loads the chat histories from the repository and emits a `ChatHistoryLoadSuccess` state. When the BLoC receives an `AddChatHistory`, `UpdateChatHistory`, or `DeleteChatHistory` event, it updates the local map of chat histories, emits a new `ChatHistoryLoadSuccess` state, and then saves the changes to the repository.
