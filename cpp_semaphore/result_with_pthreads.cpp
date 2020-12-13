#include <iostream>
#include <string>
#define HAVE_STRUCT_TIMESPEC
#include <pthread.h>
#include <thread> // для this_thread::sleep_for
#include <semaphore.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

enum class Components
{
	tobacco,
	paper,
	matches
};

class Smoker
{
private:
	Components _comp;
	std::string _name;
public:
	Smoker(const Components& component, const std::string& name)
	{
		_comp = component;
		_name = name;
	}
	~Smoker() {}

	Components GetComponent() const
	{
		return _comp;
	}

	void Smoke() const
	{
		std::cout << _name << " курильщик - пых пых" << '\n';
	}
};

sem_t  empty;
sem_t  full;
pthread_mutex_t mutexW; //мютекс для операции записи
pthread_mutex_t mutexR; //мютекс для операции чтения
Components not_exist = static_cast<Components>(rand() % 3);

void* Producer(void* param)
{
	while (true)
	{
		std::this_thread::sleep_for(std::chrono::milliseconds(2000));
		//защита на запись
		pthread_mutex_lock(&mutexW);
		sem_wait(&empty);
		std::cout << "\nproduce\n";
		// отсутствующий компонент, который есть у потребителя
		not_exist = static_cast<Components>(rand() % 3);
		//количество возможных потребителей = 3
		sem_post(&full);
		sem_post(&full);
		sem_post(&full);
		pthread_mutex_unlock(&mutexW);
	}
	return nullptr;
}

void* Consumer(void* param)
{
	// засыпаем сначала, чтоб производитель заработал
	std::this_thread::sleep_for(std::chrono::milliseconds(500));
	Smoker& smoker = *((Smoker*)param);
	while (true)
	{
		// защита на чтение
		pthread_mutex_lock(&mutexR);
		sem_wait(&full);
		std::cout << "consume ";
		if (smoker.GetComponent() == not_exist)
		{
			std::cout << '\n';
			smoker.Smoke();
			// обновляем продукцию
			sem_post(&empty);
		}
		pthread_mutex_unlock(&mutexR);
		std::this_thread::sleep_for(std::chrono::milliseconds(1000));
	}
}

int main()
{
	srand(time(NULL));
	setlocale(LC_ALL, "Russian");
	pthread_mutex_init(&mutexW, nullptr);
	pthread_mutex_init(&mutexR, nullptr);
	sem_init(&empty, 0, 1); //количество свободных ячеек = 1
	sem_init(&full, 0, 0); //количество занятых ячеек = 0
	// создаем и запускаем производителя
	pthread_t thread_producer;
	pthread_create(&thread_producer, nullptr, Producer, nullptr);
	// создаем и запускаем потребителей
	pthread_t threads[3];
	Smoker* smoker_1 = new Smoker(Components::tobacco, "1");
	Smoker* smoker_2 = new Smoker(Components::paper, "2");
	Smoker* smoker_3 = new Smoker(Components::matches, "3");
	pthread_create(&threads[0], nullptr, Consumer, (void*)(smoker_1));
	pthread_create(&threads[1], nullptr, Consumer, (void*)(smoker_2));
	pthread_create(&threads[2], nullptr, Consumer, (void*)(smoker_3));
	// зацикливаем главный поток, дожидаясь производителя
	pthread_join(thread_producer, nullptr);
}