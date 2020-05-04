# Lecture 2. Allocators.

## 8.5 Allocators

```cpp
template<class T>
struct allocator
{
	using value_type = T;

	T* allocate(size_t n) {
		// only memory, no constructors
		::operator new(n * sizeof(T));
	}

	void deallocate(T* p, size_t) {
		::operator delete(p);
	}

	// Optional,
	// deprecated in C++ 17, moved to allocator_traits

	// Works similar, using move semantics
	template<typename... Args>
	void construct(T* p, const Args&... args) {
		new(p) T(args...);
	}

	void destroy(T* p) {
		p->~T();
	}
};
```

## 8.6 Allocator traits

```cpp
template<typename Alloc>
struct allocator_traits {
	// allocate, deallocate calls same allocator methods
	static Alloc::value_type* allocate(Alloc& alloc, size_t n) {
		return alloc.allocate(n);
	}

	// construct, destroy calls corresponding
	// allocator methods, if they're declared,
	// defaulted to placement new, p->~T() before cpp20,
	// std::destroy_at(p) since cpp20

	// using SFINAE
}
```

## 8.7 Example of push_back inside `std::vector`:

```cpp
Alloc alloc;
size_t size;
size_t capacity;
T* arr;

void push_back(const T& x) {
	using traits = std::allocator_traits<Alloc>;
	if (sz == cp) {
		T* new_arr = traits::allocate(alloc, p <<= 1);

		for (size_t i = 0; i < sz; ++i) {
			// slow, requires copy constructor
			traits::construct(alloc, new_arr + i, arr[i]);
			// real implementation uses move semantics if noexcept
			traits::construct(alloc, new_arr + i, std::move(arr[i]));
			// memcpy can't be used, references may be
			// invalidated.
		}
		// traits::destroy(alloc, arr, sz);
		traits::deallocate(alloc, arr, sz);
		arr = new_arr;
	}

	traits::construct(alloc, arr + sz++, x);
}
```

## 8.8 select_on_container_copy_construction

Inside containers, copy works like

```cpp
alloc(allocator_traits<Alloc>::select_on_container_copy_construction(alloc))
```

It can define how alloc is copied, when container copy is
created.

## 8.9 Allocator rebind

```cpp
template<typename T>
class allocator {
	// ...
	template<typename U>
	struct rebind
	{
		using other = allocator<U>;
	};
}
```

Used for creating private inner nodes inside containers with a given allocator.