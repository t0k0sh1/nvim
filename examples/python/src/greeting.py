def greet(name: str) -> str:
    if not name:
        raise ValueError("name must not be empty")
    return f"Hello, {name}!"


def farewell(name: str) -> str:
    return f"Goodbye, {name}!"


if __name__ == "__main__":
    print(greet("Neovim"))
