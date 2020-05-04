# Lecture 4. Iterators

## 10.3 Const and reverse iterators

Methods `begin()`, `end()` return `T::iterator`
Methods `rbegin()`, `rend()` return `T::reverse_iterator` aka `std::reverse_iterator<T::iterator>`.

`std::make_reverse_iterator` is similar to calling constructor, but shorter to code.

`std::vector::const_iterator` works the same,
but returns `const T&` / `const pair<Const key, value>`.

Helpers: `cbegin()`, `cend()`, `crbegin()`, `crend()`.

## 10.4 Iterator traits

`std::iterator` was a base of all iterators, but now depracated.

`typename std::iterator_traits<Iter>::value_type`

```cpp
void process_sequence(Iter begin, Iter end) {
	using Value = typename std::iterator_traits<Iter>::value_type;
	Value x = *begin();
}
```

`std::iterator_traits<Iter>::iterator_category`

returns fake types:

`struct input_iterator_tag {};`, and many other...

## 10.5 `std::advance`, `std::distance`

`std::distance` is a distance between first and right iterators. Works O(1) for RA iterators,
O(n) otherwise. Assumes that first is less than right.

`std::advance` moves the iterator n steps forward.

Implementation based on template speciailization.

## 10.6 `back_insert_iterator`

`std::copy` Defined in `<algorithms>`

```cpp
// Simple copy, doesn't perform any rehashes or memory allocations
std::copy(InputIter begin, InputIter end, OuputIter output) {}

// simulates iterator behaviout, but actually just pushes back to container
template<class Container>
struct back_insert_iterator {
	Container& cont;
	// constructor

	back_insert_iterator& operator*() {
		return *this;
	}

	back_insert_iterator& operator= (const typename Container::value_type& x) {
		cont.push_back(x);
		return *this;
	}
}

// Usage
std::copy(data.begin(), data.end(), back_insert_iterator<Container>::back_insert_iterator(c))
// or shorter
std::copy(data.begin(), data.end(), std::back_inserter(c));
// also
std::copy(data.begin(), data.end(), std::front_inserter(c));
std::copy(data.begin(), data.end(), std::inserter(c, c.begin())); // c.begin() is a position to insert
```

