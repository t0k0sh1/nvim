export function greet(name: string): string {
  if (name.length === 0) {
    return "Hello!";
  }

  return `Hello, ${name}!`;
}

export function farewell(name: string): string {
  return `Goodbye, ${name}!`;
}
