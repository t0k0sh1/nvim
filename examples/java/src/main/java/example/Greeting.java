package example;

public final class Greeting {
  private Greeting() {}

  public static String greet(String name) {
    if (name.isEmpty()) {
      return "Hello!";
    }

    return "Hello, " + name + "!";
  }

  public static String farewell(String name) {
    return "Goodbye, " + name + "!";
  }
}
