# Lecture 8. Smart pointers 2

## 12.6 `allocate_shared`

Same as shared_ptr, but all allocation go through given allocator.

Implementation change in `shared_ptr`: allocator must be saved to
destroy the object. It is saved in a proxy Deleter object, described in `12.8`.

## 12.7 `std::weak_ptr`

Problem: in tree, there are ptrs to sons and parents, it means that if ptr to root is lost, tree will not be destroyed, we want links to parents to add 0 to counter. That's `std::weak_ptr`.

Problem: object under `std::weak_ptr` may be destroyed. To determine this, check method `expired`. `expired` checks that in counter object, there are 0 `std::shared_ptr` pointing. It means that in this moment Counter should be alive and that's why keeps counting `weak_count` and destroyed after this number hits zero. 

To get object by `std::weak_ptr`, use `lock` method. It returns valid `shared_ptr`. If it's expired, `std::bad_weak_ptr` is thrown.

## 12.8 Custom deleters

To destroy the object, special object called Deleter is passed to constructor. When objects needs to be destroyed and deallocated, `delete.operator(ptr)` is called.

## 12.9 `enable_shared_from_this`

```cpp
template<typename T>
struct enable_shared_from_this {
private:
	std::weak_ptr<T> wptr;
public:
	shared_ptr<T> shared_from_this() {
		return wptr.lock();
	}
	friend shared_ptr<T>;
	// shared_ptr constructor checks if object is base of 
	// enable_shared_from_this.
	// If true, it sets wptr.
}

struct MyStruct : public enable_shared_from_this<MyStruct> {
	shared_ptr<MyStruct> f() {
		// wrong
		return this; // if the object was created as `make_shared`,
		// then new family of shared_ptrs will be created

		//correct
		return shared_from_this();
	}
}
```