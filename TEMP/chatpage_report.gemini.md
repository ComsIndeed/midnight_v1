# Chat Page Report

## Overview

The chat page is a stateful widget that allows users to interact with a generative AI model. It supports text and media messages, and allows users to manage their chat histories.

## Features

- **Chat History Management:** Users can create, rename, and delete chat histories.
- **Message Display:** Messages are displayed in a `ListView`, with different styles for user and model messages.
- **Message Input:** Users can type messages in a text field and send them to the model.
- **Media Attachments:** Users can attach images and other media to their messages.
- **Model Switching:** A dropdown menu allows users to switch between different generative models (placeholder).

## File Structure

- `lib/pages/chats_page/chat_page.dart`: The main chat page widget.
- `lib/pages/chats_page/widgets/chat_drawer.dart`: The drawer that displays the list of chat histories.
- `lib/pages/chats_page/widgets/chat_message_widget.dart`: A widget that displays a single chat message.
- `lib/pages/chats_page/widgets/message_input_bar.dart`: The input bar for text and media.

## How it Works

The chat page uses the `ChatHistoryBloc` to manage the state of the chat histories. When the user sends a message, the page adds the message to the current chat history and updates the UI. The page also interacts with the `ChatHistoryBloc` to create, rename, and delete chat histories.

The `MessageInputBar` allows the user to select media files from their device. The selected files are displayed in a preview area before being sent. When the user sends the message, the files are uploaded to a server and the URLs are included in the message content (this part is not yet implemented).
