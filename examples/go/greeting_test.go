package greeting

import "testing"

func TestGreet(t *testing.T) {
	got := Greet("Go")
	want := "Hello, Go!"
	if got != want {
		t.Fatalf("Greet() = %q, want %q", got, want)
	}
}
