package example;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class GreetingTest {
  @Test
  void greetsByName() {
    assertEquals("Hello, Java!", Greeting.greet("Java"));
  }
}
