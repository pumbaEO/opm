﻿#Использовать asserts
#Использовать fs
#Использовать tempfiles
//#Использовать "../src/Модули"

Перем юТест;
Перем мВременныеФайлы;

Функция ПолучитьСписокТестов(Знач Тестирование) Экспорт
	
	юТест = Тестирование;
	
	ИменаТестов = Новый Массив;
	
	ИменаТестов.Добавить("ТестДолжен_ПроверитьЧтоПакетСобранКорректно");
	ИменаТестов.Добавить("ТестДолжен_ОчиститьКаталогОтСтарыхСкриптовПриОбновленииПакета");
	
	Возврат ИменаТестов;

КонецФункции

Процедура ПослеЗапускаТеста() Экспорт
	мВременныеФайлы.Удалить();
	ПутьККаталогу = ОбъединитьПути(ТекущийКаталог(), "oscript_modules", "test");
	Если ФС.КаталогСуществует(ПутьККаталогу) Тогда
		УдалитьФайлы(ПутьККаталогу);
	КонецЕсли;
КонецПроцедуры

Процедура ТестДолжен_ПроверитьЧтоПакетСобранКорректно() Экспорт

	Сборщик = Новый СборщикПакета;
	
	КаталогСборки = юТест.ИмяВременногоФайла();
	СоздатьКаталог(КаталогСборки);
	Сборщик.СобратьПакет(ОбъединитьПути(ТекущийСценарий().Каталог, "testpackage", "testpackage-0.3.1"), Неопределено, КаталогСборки);
	
	ФайлПакета = Новый Файл(ОбъединитьПути(КаталогСборки, "test-0.3.1.ospx"));
	
	Утверждения.ПроверитьИстину(ФайлПакета.Существует(), "Файл пакета должен существовать");
	ЧтениеАрхива = Новый ЧтениеZipФайла(ФайлПакета.ПолноеИмя);
	
	ЭлементСодержимого = ЧтениеАрхива.Элементы.Найти("content.zip");
	ЭлементМанифеста   = ЧтениеАрхива.Элементы.Найти("opm-metadata.xml");
	
	Утверждения.ПроверитьНеравенство(Неопределено, ЭлементСодержимого);
	Утверждения.ПроверитьНеравенство(Неопределено, ЭлементМанифеста);
	
	КаталогПроверки = ПолучитьИмяВременногоФайла();//юТест.ИмяВременногоФайла();
	СоздатьКаталог(КаталогПроверки);
	
	ЧтениеАрхива.Извлечь(ЭлементСодержимого, КаталогПроверки);
	ЧтениеАрхива.Закрыть();
	
	ЧтениеАрхива = Новый ЧтениеZipФайла(ОбъединитьПути(КаталогПроверки, "content.zip"));
	ЧтениеАрхива.ИзвлечьВсе(КаталогПроверки);
	ЧтениеАрхива.Закрыть();
	ФайлИсходника = Новый Файл(ОбъединитьПути(КаталогПроверки, "folder/src.os"));
	Утверждения.ПроверитьИстину(ФайлИсходника.Существует(), "Существует файл в подкаталоге");
	
КонецПроцедуры

Процедура ТестДолжен_ОчиститьКаталогОтСтарыхСкриптовПриОбновленииПакета() Экспорт

	
	//устанавливаем новую версию пакета в которой есть test-new.os
	//
	//ожидаем что в каталоге пакета есть только test-new.os

	//подготовка двух версий пакета
	
	Сборщик = Новый СборщикПакета;
	
	КаталогСборкиПервойВерсии = мВременныеФайлы.СоздатьКаталог();

	Сборщик.СобратьПакет(
		ОбъединитьПути(ТекущийСценарий().Каталог, "testpackage", "testpackage-0.3.1"), 
		Неопределено, КаталогСборкиПервойВерсии);

	ФайлПакетаВерсии1 = Новый Файл(ОбъединитьПути(КаталогСборкиПервойВерсии, "test-0.3.1.ospx"));

	КаталогСборкиВторойВерсии = мВременныеФайлы.СоздатьКаталог();

	Сборщик.СобратьПакет(
		ОбъединитьПути(ТекущийСценарий().Каталог, "testpackage", "testpackage-0.3.2"), 
		Неопределено, КаталогСборкиВторойВерсии);

	ФайлПакетаВерсии2 = Новый Файл(ОбъединитьПути(КаталогСборкиВторойВерсии, "test-0.3.2.ospx"));
	
	Установщик = Новый УстановкаПакета;
	Установщик.УстановитьРежимУстановкиПакетов(РежимУстановкиПакетов.Локально);

	Установщик.УстановитьПакетИзАрхива(ФайлПакетаВерсии1.ПолноеИмя);

	ПутьКФайлуOsТестовогоПакета = ОбъединитьПути(
		КонстантыOpm.ЛокальныйКаталогУстановкиПакетов, "test","folder","src.os");
	ФайлOsИзСтарогоПакета = Новый Файл(ПутьКФайлуOsТестовогоПакета);

	ПутьКФайлуDllТестовогоПакета = ОбъединитьПути(
		КонстантыOpm.ЛокальныйКаталогУстановкиПакетов, "test","folder","src.dll");
	ФайлDllИзСтарогоПакета = Новый Файл(ПутьКФайлуDllТестовогоПакета);
	
	Ожидаем.Что(ФайлOsИзСтарогоПакета.Существует(), "Файл src.os должен существовать").ЭтоИстина();
	Ожидаем.Что(ФайлDllИзСтарогоПакета.Существует(), "Файл src.dll должен существовать").ЭтоИстина();

	Установщик.УстановитьПакетИзАрхива(ФайлПакетаВерсии2.ПолноеИмя);

	Ожидаем.Что(ФайлOsИзСтарогоПакета.Существует(), "Файл src.os не должен существовать, потому что мы установили новую версию").ЭтоЛожь();
	Ожидаем.Что(ФайлDllИзСтарогоПакета.Существует(), "Файл src.dll не должен существовать, потому что мы установили новую версию").ЭтоЛожь();


КонецПроцедуры

мВременныеФайлы = Новый МенеджерВременныхФайлов;
