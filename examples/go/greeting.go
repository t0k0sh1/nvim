package greeting

import "fmt"

func Greet(name string) string {
	if name == "" {
		return "Hello!"
	}
	return fmt.Sprintf("Hello, %s!", name)
}

func Farewell(name string) string {
	return fmt.Sprintf("Goodbye, %s!", name)
}
