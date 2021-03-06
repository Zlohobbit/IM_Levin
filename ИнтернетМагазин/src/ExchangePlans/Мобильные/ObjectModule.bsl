Процедура ЗаписатьСообщениеСИзменениями(Каталог) Экспорт 
	
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = "-------Выгрузка в узел" + Строка(ЭтотОбъект) + "--------";
	Сообщение.Сообщить();
	
	//Сформируем имя временного файла
	ИмяФайла = Каталог + ?(Прав(Каталог,1) = "\","","\") + "Message" +
	СокрЛП(ПланыОбмена.Мобильные.ЭтотУзел().Код) + "_" + СокрЛП(Ссылка.Код) + ".xml";
	
	//Создать объект записи XML
	//***ЗаписьXML-документов
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.ОткрытьФайл(ИмяФайла);
	ЗаписьXML.ЗаписатьОбъявлениеXML();
	
	//***Инфраструктура сообщений
	ЗаписьСообщения = ПланыОбмена.СоздатьЗаписьСообщения();
	ЗаписьСообщения.НачатьЗапись(ЗаписьXML,Ссылка);
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = "Номер сообщения: " + ЗаписьСообщения.НомерСообщения;
	Сообщение.Сообщить();
	
	//Получить выборку измененнных данных
	//***Механизм регистрации мзменений
	ВыборкаИзменений = ПланыОбмена.ВыбратьИзменения(ЗаписьСообщения.Получатель,ЗаписьСообщения.НомерСообщения);
	Пока ВыборкаИзменений.Следующий() Цикл
		Данные = ВыборкаИзменений.Получить();
		
		//Записать данные в сообщение***XML-сериализация
		
		ЗаписатьXML(ЗаписьXML, Данные);
	КонецЦикла;  
	
	ЗаписьСообщения.ЗакончитьЗапись();
	ЗаписьXML.Закрыть();
	
	
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = "-------Конец выгрузки--------";
	Сообщение.Сообщить();
	
	
КонецПроцедуры

Процедура ПрочитатьСообщениеСИзминениями(Каталог) Экспорт
	
	//Сформировать имя файла
	ИмяФайла = Каталог + ?(Прав(Каталог,1) = "\","","\") + "Message" +
	СокрЛП(Ссылка.Код) + "_" + СокрЛП(ПланыОбмена.Мобильные.ЭтотУзел().Код) + ".xml";
	Файл = Новый Файл(ИмяФайла);
	Если Не Файл.Существует() Тогда
		Возврат;
	КонецЕсли;
	//***Чтение документа XML
	//Попытаться открыть файл
	ЧтениеXML = Новый ЧтениеXML;
	Попытка
		ЧтениеXML.ОткрытьФайл(ИмяФайла);
	Исключение
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "Невозможно открыть файл обмена данными";
		Сообщение.Сообщить();
		Возврат;
	КонецПопытки;  //
	
	Сообщение = Новый СообщениеПользователю();
	Сообщение.Текст = "-------Загрузка из " + Строка(ЭтотОбъект) + "--------";
	Сообщение.Сообщить();
		
	Сообщение = Новый СообщениеПользователю();
	Сообщение.Текст = " -Считывается файл " + ИмяФайла;
	Сообщение.Сообщить();
	
	//Загрузить из найденного файла
	//***Инфраструктура сообщений.
	ЧтениеСообщения = ПланыОбмена.СоздатьЧтениеСообщения();
	//Читать заголовок сообщения обмена данными - файла XML
	ЧтениеСообщения.НачатьЧтение(ЧтениеXML);
	//Сообщение предназначено для данного узла
	Если ЧтениеСообщения.Отправитель <> Ссылка Тогда
		ВызватьИсключение "Неверный узел";
	КонецЕсли;
	//Удаляем регистрацию измененеий для узла отправителя сообщения
	//***Служба регистрации изменений
	ПланыОбмена.УдалитьРегистрациюИзменений(ЧтениеСообщения.Отправитель, ЧтениеСообщения.НомерПринятого);
	//Читаем данные из сообщения *** XML-сериализация
	Пока ВозможностьЧтенияXML(ЧтениеXML) Цикл
		//Читаем очередное сообщение
		Данные = ПрочитатьXML(ЧтениеXML);
		//Записать полученные данные
		Данные.ОбменДанными.Отправитель = ЧтениеСообщения.Отправитель;
		Данные.ОбменДанными.Загрузка = Истина;
		Данные.Записать(); 
	КонецЦикла;
	ЧтениеСообщения.ЗакончитьЧтение();
	ЧтениеXML.Закрыть();
	УдалитьФайлы(ИмяФайла);
	Сообщение = Новый СообщениеПользователю();
	Сообщение.Текст = "-------Конец загрузки--------";
	Сообщение.Сообщить();
	
КонецПроцедуры