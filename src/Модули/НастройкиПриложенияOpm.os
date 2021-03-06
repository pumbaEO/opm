
#Использовать json
#Использовать logos

Перем мНастройки;
Перем мПутьФайлаНастроек;
Перем Лог;

Процедура УстановитьФайлНастроек(Знач Путь) Экспорт

	мПутьФайлаНастроек = Путь;
	мНастройки = Неопределено;

КонецПроцедуры

Функция Получить() Экспорт

	Если мНастройки = Неопределено Тогда
		Попытка
			ПрочитатьФайлНастроек();
		Исключение
			Лог.Отладка("Чтение файла настроек:
				|" + ОписаниеОшибки());
			УстановитьНастройкиПоУмолчанию();
		КонецПопытки;
	КонецЕсли;

	Возврат мНастройки;

КонецФункции

Процедура ПрочитатьФайлНастроек()
	
	Если Не ЗначениеЗаполнено(мПутьФайлаНастроек) Тогда
		ВызватьИсключение "Не установлен файл настроек";
	КонецЕсли;

	Текст = ПрочитатьФайл(мПутьФайлаНастроек);

	Чтение = Новый ПарсерJSON;
	Настройки = Чтение.ПрочитатьJSON(Текст,,,Истина);

	// TODO сделать конвертацию терминов json в русские свойства настроек

	мНастройки = ЗаполнитьНесуществующиеНастройкиПоУмолчанию(Настройки);
	
	УстановитьЧисловоеЗначениеПортаСервера(мНастройки);
КонецПроцедуры

Функция ПрочитатьФайл(Знач Путь)

	Чтение = Новый ЧтениеТекста(Путь);
	Текст = Чтение.Прочитать();
	Чтение.Закрыть();

	Возврат Текст;

КонецФункции

Процедура СохранитьФайл(Знач Текст,Знач Путь)
 
 	Запись = Новый ЗаписьТекста(Путь);
 	Запись.ЗаписатьСтроку(Текст);
 	Запись.Закрыть();
 
 КонецПроцедуры

Процедура УстановитьНастройкиПоУмолчанию()
	мНастройки = НастройкиПоУмолчанию();
КонецПроцедуры

Функция ЗаполнитьНесуществующиеНастройкиПоУмолчанию(Знач Настройки, НовыеНастройки = Неопределено)
	Если НовыеНастройки = Неопределено Тогда
		НовыеНастройки = НастройкиПоУмолчанию();
	КонецЕсли;
	Для каждого Настройка Из Настройки Цикл
		Значение = Настройка.Значение;
		Если ТипЗнч(Значение) = Тип("Структура") Тогда
			Значение = ЗаполнитьНесуществующиеНастройкиПоУмолчанию(Значение, НовыеНастройки[Настройка.Ключ]);
		КонецЕсли;
		НовыеНастройки.Вставить(Настройка.Ключ, Значение);
	КонецЦикла;
	Возврат НовыеНастройки;
КонецФункции

Функция НастройкиПоУмолчанию()
	Рез = Новый Структура;
	НастройкиПроксиПоУмолчанию = НастройкиПроксиПроксиПоУмолчанию();
	Рез.Вставить("Прокси", НастройкиПроксиПоУмолчанию);
	Рез.Вставить("СоздаватьShСкриптЗапуска", Ложь);
	Возврат Рез;
КонецФункции

Функция НастройкиПроксиПроксиПоУмолчанию()

	СтруктураПрокси = Новый Структура();
	СтруктураПрокси.Вставить("ИспользоватьПрокси", Ложь);
	СтруктураПрокси.Вставить("ПроксиПоУмолчанию", Истина);
	СтруктураПрокси.Вставить("Сервер");
	СтруктураПрокси.Вставить("Порт", 0);
	СтруктураПрокси.Вставить("Пользователь");
	СтруктураПрокси.Вставить("Пароль");
	СтруктураПрокси.Вставить("ИспользоватьАутентификациюОС",Ложь);

	Возврат СтруктураПрокси;
КонецФункции	

Процедура УстановитьЧисловоеЗначениеПортаСервера(Настройки)
	Для каждого Настройка Из Настройки Цикл
		Значение = Настройка.Значение;
		Если НРег(Настройка.Ключ) = "порт" Тогда
			Если Не ЗначениеЗаполнено(Значение) Тогда
				Значение = 0;
			Иначе
				Значение = Число(Значение);
			КонецЕсли;
		Иначе

			Если ТипЗнч(Значение) = Тип("Структура") Тогда
				УстановитьЧисловоеЗначениеПортаСервера(Значение);
			КонецЕсли;

		КонецЕсли;
			
		Настройки.Вставить(Настройка.Ключ, Значение);
	КонецЦикла;
КонецПроцедуры

Процедура СохранитьНастройки(Знач Параметры) Экспорт
	Получить();
	ЗаполнитьНастройкиИзПараметров(Параметры);
	Текст = СформироватьТекстНастроек(мНастройки);
	СохранитьФайл(Текст,мПутьФайлаНастроек);
КонецПроцедуры
  
Функция СформироватьТекстНастроек(Знач Настройки)
	ТекстНастроек = "";
	Json          =  Новый ПарсерJSON;
	ТекстНастроек = Json.ЗаписатьJSON(Настройки);

	Возврат ТекстНастроек;
КонецФункции

Процедура ЗаполнитьНастройкиИзПараметров(знач ЗначенияПараметров)
	
	мНастройки.Прокси.ПроксиПоУмолчанию = НЕ ЗначенияПараметров["-proxyusedefault"] = Неопределено;
	мНастройки.Прокси.Сервер            = ?(ЗначенияПараметров["-proxyserver"]      = Неопределено,	мНастройки.Прокси.Сервер,       ЗначенияПараметров["-proxyserver"]);
	мНастройки.Прокси.Порт              = ?(ЗначенияПараметров["-proxyport"]        = Неопределено,	мНастройки.Прокси.Порт,         ЗначенияПараметров["-proxyport"]);
	мНастройки.Прокси.Пользователь      = ?(ЗначенияПараметров["-proxyuser"]        = Неопределено,	мНастройки.Прокси.Пользователь, ЗначенияПараметров["-proxyuser"]);
	мНастройки.Прокси.Пароль            = ?(ЗначенияПараметров["-proxypass"]        = Неопределено,	мНастройки.Прокси.Пароль,       ЗначенияПараметров["-proxypass"]);
	
	Если мНастройки.Прокси.ПроксиПоУмолчанию Тогда
			мНастройки.Прокси.Сервер       = "";
			мНастройки.Прокси.Порт         = 0;
			мНастройки.Прокси.Пользователь = "";
			мНастройки.Прокси.Пароль       = "";
	КонецЕсли;	

	мНастройки.Прокси.ИспользоватьПрокси =  мНастройки.Прокси.ПроксиПоУмолчанию ИЛИ ЗначениеЗаполнено(мНастройки.Прокси.Сервер);

	мНастройки.СоздаватьShСкриптЗапуска = ?(
		ЗначенияПараметров["-winCreateBashLauncher"] = Неопределено,
		мНастройки.СоздаватьShСкриптЗапуска,
		Булево(ЗначенияПараметров["-winCreateBashLauncher"])
	);
	
КонецПроцедуры
//------------

Лог = Логирование.ПолучитьЛог("oscript.app.opm");