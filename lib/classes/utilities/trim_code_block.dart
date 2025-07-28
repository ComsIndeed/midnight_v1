String trimCodeBlock(String input) {
  input = input.trim();
  if (input.startsWith('```json') && input.endsWith('```')) {
    return input.substring(7, input.length - 3).trim();
  }
  return input;
}
