# Lecture 3. Iterators.

## 9.7 Complexity

Main containers

* vector (sequence containers)
	- deque
	- stack
	- queue
* list
	- forward_list
* map
	- set
* unordered_map

Complexity:

|               | find / operator[] | pop/push front/back | insert/erase   |
|---------------|-------------------|---------------------|----------------|
| vector        | O(1)              | O(1) amortized      | anywhere: O(n) |
| list          | O(n)              | O(1)                | anywhere: O(1) |
| map           | O(logn)           | -                   | O(logn)        |
| unordered_map | O(1) amortized    | -                   | O(1) amortized |

reserved method is used when size of input data is known.

# Unit 10. Iterators

## 10.1 Idea

Key idea is to put non-trivial logic of iterating through containers into a simple and universal proxy object.

Range-based for:
```cpp
for (T item: container) {

}
```

Defined as `vector<T>::iterator`. Always have methods:
- operator++
- operator*


## 10.2 Concepts of iterators
- Input iterators (as input stream)
- Output iterators (as output stream)
- Forward iterator
- Bidirectional iterator
- Random access iterator

| container     | concept 		|
|---------------|---------------|
| vector/deque  | random_access |
| list          | bidirectional |
| forward_list  | forward       |
| map/set       | bidirectional |
| unordered_map | forward       |

Iterators in map/set/umap return lvalue, no write access this way.

`*it` returns `T` or `pair<const Key, Value>` in map/umap. It's defivned as `value_type`

Only random-access iterators can be compared (<, >) and added with a constant.

```cpp
for(std::map<X, Y>::iterator it = m.begin(); it != m.end(); ++it) {
	...
}
```

Complexty of range-based loops in non-trivial containers:

In tree-based set/map iterators perform inorder traversal.
In hashmap-based uset, umap: values are stored in ForwardList,
where the following invariant is provided: items with the same hash
value are neighbours. Values in hashmap itself is stored as pointers to list nodes.
