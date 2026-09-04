pub fn greet(name: &str) -> String {
    if name.is_empty() {
        return "Hello!".to_owned();
    }

    format!("Hello, {name}!")
}

pub fn farewell(name: &str) -> String {
    format!("Goodbye, {name}!")
}

#[cfg(test)]
mod tests {
    use super::greet;

    #[test]
    fn greets_by_name() {
        assert_eq!(greet("Rust"), "Hello, Rust!");
    }
}
