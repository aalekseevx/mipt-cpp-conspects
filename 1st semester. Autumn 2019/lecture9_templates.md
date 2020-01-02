# Lecture 9. Templates.

## 5.11 Abstact classes. Pure virtual functions.

Pure virtual functions are used when general implementation can't be created, but each derived class must provide an implementation of the function.

Usage:

```cpp
struct S {
	virtual double area() = 0;
}
```

Abstract class contains at least one pure virtual function.

Abstract class objects are not allowed.

## 5.12 Problems with virtual functions.

### Problem of calling virtual function in constructors.

```cpp
struct Base {
	Base() {
		f();
	}
	virtual void f() {
		std::cout << 1;
	}

	// if function is pure virtual, it produces an runtime error:
	// "pure virtual function call"
	// virtual void f() = 0;
};

struct Derived: Base {
	Derived(): Base() {}
	void f() override {
		std::cout << 2;
	}
};

// Code prints "1", because when Base constructor is called
// Derived object is not even initialized: no point to call overriden function.
```

### Problem with default arguments in virtual functions.

```cpp
struct Base {
	Base() { }
	virtual void f(int x = 1) { }
};

struct Derived: Base {
	Derived(): Base() {}
	void f(int x = 2) override { }
};

int main() {
	Derived d;
	Base& b = d;
	b.f(); // This calls Derived function according to vtable
	// But arguments are taken from the Base class function at the compile time.
	// That was unpredictable
}
```

# Unit 6. Templates.

## 6.1 Idea.

Templates use typenames as metavariables. Implementation of one function/class/etc can be used for all suitable classes.

It helps not to duplicate code.

**Compiler does not cast types to fit into template args**.

- Function templates
```cpp
// preferable
template<typename T1, typename T2>
/// or (maybe used)
// template<class T1, class T2>
void f (T1 a, T2 b) {
	// Function f is called with a wrong template args.
	// if T1 or T2 doesn't have size method -- CE.
	a.size();
}
```
- Typedef templates (since cpp11). (Aliases)
```cpp
template<typename T>
using mi<T> = map<int, T>
```

- Variables templates
```cpp
template<class T>
constexpr T pi = T(3.1415926535897932385L);
```

Specification - template with given arguments.

Instantiation - generation of the particaular specification.

Static polymorphism - compile time using templates

Dynamic polymorphism - runtime using vtable

TODO: where is that: " Пример определения шаблонной функции-члена шаблонного класса вне тела класса (двойной шаблонный префикс).
"?

## 6.2 Template functions overloading

```cpp
void f(int, int) {
	cout << 1;
}

template <typename T>
void f(T, T) {
	cout << 2;
}

template <typename U, typename V>
void f(U, V) {
	cout << 3;
}

// f(5, 5) is f(int, int)
// f(0.1, 0.0) is f(T, T)
// f(5, 0.1) if f(U, V)

// if there is no third overload
// f(5, 0.1) is f(int, int). (casted)
```

Euristics:
- If it fits perfect - it is chosen. 
- More specialized (less template args) - the better.

Note: specialized arguments:
```cpp
template<typename T>
void f(const T&) {

}
```

Note: default template arguments.
```cpp
template<typename T=int>
```
Smart typename guess (since cpp17)
```cpp
vector v = {1, 2, 3}
```