#include <iostream>
#include <vector>
#include <sstream>
#include <string>
#include <algorithm>
#include <future>

using namespace std;
using namespace chrono;

constexpr size_t MIN_LEN = 1;
constexpr size_t MAX_LEN = 10;
constexpr size_t MAX_VALUE = 100;
int thread_count;

class Timer
{
private:
	steady_clock::time_point start_time;

public:
	Timer() : start_time(steady_clock::now()) {}

	~Timer()
	{
		duration<double> elapsed_seconds = steady_clock::now() - start_time;
		cout << "elapsed time: " << elapsed_seconds.count() << "sec\n";
	}
};

/// <summary>
/// Генерирует вектор строк
/// </summary>
/// <returns>вектор строк</returns>
vector<string> GenerateVector()
{
	vector<string> v;
	v.reserve(MIN_LEN + (rand() % (MAX_LEN - MIN_LEN)));
	for (size_t i = 0; i < v.capacity(); i++)
	{
		stringstream ss;
		ss << rand() % MAX_VALUE;
		v.push_back(ss.str());
	}
	return v;
}

vector<string> InputVector()
{
	vector<string> v;
	string str;
	getline(cin, str, '\n');
	stringstream ss(str);
	while (ss >> str)
	{
		v.push_back(str);
	}
	return v;
}

/// <summary>
/// Выводит вектор в поток
/// </summary>
/// <typeparam name="T"></typeparam>
/// <param name="os">выходной поток</param>
/// <param name="v">вектор</param>
/// <returns></returns>
template<typename T>
ostream& operator<<(ostream& os, const vector<T>& v)
{
	for (const auto& i : v)
	{
		os << "(" << i << ") ";
	}
	return os;
}

/// <summary>
/// вычисляет прямое произведение для части левого множества и полного правого
/// </summary>
/// <param name="chunk">часть левого множества</param>
/// <param name="src">второе множество</param>
/// <returns>прямое произведение</returns>
vector<string> startThread(const vector<string>& chunk, const vector<string>& src)
{
	vector<string> strs;
	for (const auto& item_chunk : chunk)
	{
		for (const auto& B_item : src)
		{
			stringstream ss;
			ss << item_chunk << ", " << B_item;
			strs.push_back(ss.str());
		}
	}
	return strs;
}

/// <summary>
/// параллельно вычисляет прямое произведение
/// </summary>
/// <param name="A">первое множество</param>
/// <param name="B">второе множество</param>
/// <returns>прямое произведение</returns>
vector<string> Multiply(const vector<string>& A, const vector<string>& B)
{
	vector<future<vector<string>>> threads; // вектор потоков
	vector<string> result;
	const int shift = A.size() / (thread_count - 1); // смещение (размер chunk)
	// start thread
	for (size_t i = 0; i < thread_count - 1; i++)
	{
		vector<string> A_chunk(A.begin() + min(i * shift, A.size()), A.begin() + min((i + 1) * shift, A.size()));
		threads.push_back(async(startThread, move(A_chunk), B));
	}
	// оставшийся не полный кусок
	vector<string> last_chunk(A.begin() + (thread_count - 1) * shift, A.end());
	threads.push_back(async(startThread, move(last_chunk), B));
	// join'им thread'ы 
	for (auto& thread : threads)
	{
		auto th = thread.get();
		// todo: оптимизировать
		for (auto& i : th)
		{
			result.push_back(i);
		}
	}
	return result;
}

int main()
{
	srand(time(NULL));
	cout << "Count of threads (>1): ";
	cin >> thread_count;
	// по усл. - многопоточное приложение 
	if (thread_count < 2)
	{
		cerr << "ERROR! thread_count < " << thread_count;
		exit(-1);
	}
	// генерируем массивы
	//vector<string> A(move(GenerateVector()));
	//vector<string> B(move(GenerateVector()));
	//vector<string> C(move(GenerateVector()));
	//vector<string> D(move(GenerateVector()));

	cout << "[A] = ";
	cin.ignore(256, '\n');
	vector<string> A = InputVector();
	cout << "[B] = ";
	vector<string> B = InputVector();
	cout << "[C] = ";
	vector<string> C = InputVector();
	cout << "[D] = ";
	vector<string> D = InputVector();

	// выполняем распараллеленное прямое произведение для каждого множества
	// можно было заморочиться и сделать цикл, но тут не много множеств, поэтому оставлю так :)
	auto ab = Multiply(A, B);
	cout << '\n' << "A * B =  " << '\n' << ab << '\n';

	auto abc = Multiply(ab, C);
	cout << '\n' << "(A*B)*C = " << '\n' << abc << '\n';

	auto abcd = Multiply(abc, D);
	cout << '\n' << "((A*B)*C)*D = " << '\n' << abcd << '\n';
}