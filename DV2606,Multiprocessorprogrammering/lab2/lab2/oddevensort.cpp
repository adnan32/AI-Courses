#include <vector>
#include <algorithm>
#include <iostream>
#include <chrono>



using namespace std;
// The odd-even sort algorithm
// Total number of odd phases + even phases = the number of elements to sort
void oddeven_sort(vector<int>& numbers)
{
    
    auto s = numbers.size();
    for (int i = 1; i <= s; i++) {

        for (int j = i % 2; j < s; j = j + 2) {
            if (numbers[j] > numbers[j + 1]) {
                swap(numbers[j], numbers[j + 1]);
            }
        }

    }
}

void print_sort_status(vector<int> numbers)
{
    cout << "The input is sorted?: " << (is_sorted(numbers.begin(), numbers.end()) == 0 ? "False" : "True") << endl;
}

int main()
{
    
    constexpr unsigned int size = 100000; // Number of elements in the input

    // Initialize a vector with integers of value 0
    vector<int> numbers(size);
    // Populate our vector with (pseudo)random numbers
    srand(time(0));
    generate(numbers.begin(), numbers.end(), rand);
    print_sort_status(numbers);
    auto start = chrono::steady_clock::now();
    oddeven_sort(numbers);
    auto end = chrono::steady_clock::now();
    print_sort_status(numbers);
    cout << "Elapsed time =  " << chrono::duration<double>(end - start).count() << " sec\n";
    
}