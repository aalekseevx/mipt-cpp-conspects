# Lecture 7. Smart pointers.

## 11.10 Reference qualifiers

`&` and `&&` are similar to `const` qualifier, they require this to be (l/r)value.

```cpp

class BigInteger {
public:
	int f() && {
		return 1;
	}

	int f() & {
		return 1;
	}

	// Correct implementation
	BigInteger& operator=(const BigInteger* x) & {

	}
}

struct S {
	std::vector<int> data;
	std::vector<int> getData() & {
		return data;
	}

	std::vector<int> getData() && {
		return std::move(data);
	}
}
```

## Unit 12. Smart pointers

## 12.1 Motivation, auto_ptr

```cpp
void f() {
	int* p = new int;

	// if exception is thrown here, memory will leak
	g();


	delete p;
}
```

Fix, but with new problems. Created under c++03, with no
move semantics copy works like move.

```cpp
void f() {
	//int* p = new int;
	std::auto_ptr<int> p(new int);

	// if exception is thrown here, memory will leak
	g();


	delete p;
}
```

Resource Acquisition Is Initialization or RAII - idiom of smart pointers. Memory frees by destructor of the object.

## 12.2 unique_ptr

Copy constructor is deleted, so ownership can be only transfered.

## 12.3 shared_ptr

Keeps track of number of shared_ptr, linking to object.
When last shared_ptr is destroyed, memory is deallocated

```cpp
template<typename T>
struct Counter
{
	T* ptr;
	size_t count;
};

template<typename T>
struct shared_ptr
{
	Counter<T>* counter;

	shared_ptr(T* ptr) {
		counter = new Counter(ptr, 1);
	}
	shared_ptr(const shared_ptr<T>&) = delete;
	shared_ptr<T>& operator=(const shared_ptr<T>&) = delete;

	shared_ptr(shared_ptr<T>&& other) : ptr(other.ptr) {
		other.ptr = nullptr;
	}

	shared_ptr<T>& operator=(shared_ptr<T>&&) {
		// ...
	}

	~shared_ptr() {
		if (counter->count > 1) {
			--counter->count;
		} else {
			delete counter->ptr;
			delete counter;
		}
	}
};
```

## 12.4 `make_shared`

No extra new/delete for `shared_ptr`, counter is created with an object, using special `make_shared` proxy.
```cpp
shared_ptr<S> ptr = make_shared<S>(5, 'a', 'abcd');
```

Basic implementation
```cpp
template<typename T, typename... Args>
shared_ptr<T> make_shared(...) {
	void* p = ::operator new(sizeof(T) + sizeof(Counter<T>));
	new(p) T(std::forward<Args>(args)...);
	return shared_ptr<T>(p, (char*)p + sizeof(T));
}
```

## 12.5 ``make_unique``

Problem: call `g(std::unique_ptr(new int), h())`. arguments can be computed in following way:

- x = new int
- h() 
- std::unique_ptr(x)

If h throws exception, it leads to memory leaks.

Fix, `make_unique`
Implementation:
```cpp
template<typename T, typename... Args>
unique_ptr<T> make_unique(Args&&... args) {
	return unique_ptr<T>(new T(std::forward<Args>(args)...));
}
```

In usual code, `new` itself is not used.
