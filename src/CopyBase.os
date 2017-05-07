#Использовать cmdline
#Использовать logos
#Использовать v8runner
#Использовать ReadParams
#Использовать "."


Перем _ПараметрыРаботы;
Перем _Лог;
Перем _Замер;
Перем _Конфигуратор;

// Получить имя лога продукта
//
// Возвращаемое значение:
//  Строка   - имя лога продукта
//
Функция ИмяЛога() Экспорт
	Возврат "oscript.app.CopyBase";
КонецФункции

Процедура ВыполнитьБекап()
	
	Если Не _ПараметрыРаботы.Параметры["Source_SQL.UseBackup"] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	_Замер.НачатьЗамер( "Начат бекап " + _ПараметрыРаботы.Параметры["FileBackup"], "Бекап" );
	
	выполнениеБекапа = Новый РаботаСSQL();
	
	выполнениеБекапа.ИнициализироватьЛог( _Лог.Уровень(), _Замер.ПолучитьПотомка() );

	выполнениеБекапа.УстановитьСервер(       _ПараметрыРаботы.Параметры["Source_SQL.Server"] );
	выполнениеБекапа.УстановитьПользователя( _ПараметрыРаботы.Параметры["Source_SQL.User"] );
	выполнениеБекапа.УстановитьПароль(       _ПараметрыРаботы.Параметры["Source_SQL.Password"] );
	выполнениеБекапа.УстановитьИмяБазы(      _ПараметрыРаботы.Параметры["Source_SQL.Base"] );
	
	результат = выполнениеБекапа.ВыполнитьБекап( _ПараметрыРаботы.Параметры["FileBackup"] );
	
	Если Не результат Тогда
		ЗавершитьРаботу(1);
	КонецЕсли;
	
	_Замер.СообщитьЗамер( "Выполнен бекап " + _ПараметрыРаботы.Параметры["FileBackup"]);

КонецПроцедуры

Процедура ПроверитьСоединения()
	
	Если Не _ПараметрыРаботы.Параметры["SQL.UseRestore"] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	_Замер.НачатьЗамер( "Начало проверки количества соединений", "ПроверкаСоединения" );
	
	проверкаСоединения = Новый РаботаСSQL();
	
	проверкаСоединения.ИнициализироватьЛог( _Лог.Уровень(), _Замер.ПолучитьПотомка() );

	проверкаСоединения.УстановитьСервер(       _ПараметрыРаботы.Параметры["SQL.Server"] );
	проверкаСоединения.УстановитьПользователя( _ПараметрыРаботы.Параметры["SQL.User"] );
	проверкаСоединения.УстановитьПароль(       _ПараметрыРаботы.Параметры["SQL.Password"] );
	проверкаСоединения.УстановитьИмяБазы(      _ПараметрыРаботы.Параметры["SQL.Base"] );
	
	количествоСоединений = проверкаСоединения.ПолучитьКоличествоСоединений();
	
	_Лог.Отладка( "Количество соединений: " + количествоСоединений );

	Если количествоСоединений < 0 Тогда
		ЗавершитьРаботу(1);
	КонецЕсли;

	_Замер.СообщитьЗамер( "Проверены активные соединения. Соединений: " + количествоСоединений);
	
	Если количествоСоединений > 0 Тогда 
		
		_Лог.Ошибка( "Есть активные соединения. Выполнение скрипта прервано." );
		ЗавершитьРаботу(1);
		
	КонецЕсли;

КонецПроцедуры

Процедура ВыполнитьВосстановление()
	
	Если Не _ПараметрыРаботы.Параметры["SQL.UseRestore"] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	представлениеБазы =  _ПараметрыРаботы.Параметры["SQL.Server"] + "/" +  _ПараметрыРаботы.Параметры["SQL.Base"];

	_Замер.НачатьЗамер( "Начало восстановления в " + представлениеБазы, "Восстановление" );
	
	выполнениеВосстановления = Новый РаботаСSQL();
	
	выполнениеВосстановления.ИнициализироватьЛог( _Лог.Уровень(), _Замер.ПолучитьПотомка() );

	выполнениеВосстановления.УстановитьСервер(       _ПараметрыРаботы.Параметры["SQL.Server"] );
	выполнениеВосстановления.УстановитьПользователя( _ПараметрыРаботы.Параметры["SQL.User"] );
	выполнениеВосстановления.УстановитьПароль(       _ПараметрыРаботы.Параметры["SQL.Password"] );
	выполнениеВосстановления.УстановитьИмяБазы(      _ПараметрыРаботы.Параметры["SQL.Base"] );
	
	результат = выполнениеВосстановления.ВыполнитьСкрипт( _ПараметрыРаботы.Параметры["Script_Restore"] );
	
	Если Не результат Тогда
		ЗавершитьРаботу(1);
	КонецЕсли;
	
	_Замер.СообщитьЗамер( "Выполнено восстановление " + представлениеБазы);
	
КонецПроцедуры

Процедура УдалитьФайлБекапа()
	
	Если Не _ПараметрыРаботы.Параметры["SQL.UseRestore"] = Истина Тогда
		Возврат;
	КонецЕсли;

	Если Не _ПараметрыРаботы.Параметры["SQL.DelBackup"] = Истина Тогда
		Возврат;
	КонецЕсли;
	
	_Замер.НачатьЗамер( "Удаление файла бекапа " + _ПараметрыРаботы.Параметры["FileBackup"], "УдалениеБекапа" );
	
	Если ОбщегоНазначения.ФайлСуществует( _ПараметрыРаботы.Параметры["FileBackup"] ) Тогда
		
		УдалитьФайлы( _ПараметрыРаботы.Параметры["FileBackup"] );
		
	КонецЕсли;
	
	_Замер.СообщитьЗамер( "Удален бекап " + _ПараметрыРаботы.Параметры["FileBackup"] );
	
КонецПроцедуры

Процедура ПереподключитьХранилище()
	
	Если Не _ПараметрыРаботы.Параметры["Repo.Blind"] = Истина Тогда
		Возврат;
	КонецЕсли;
		
	представлениеБазы = _ПараметрыРаботы.ПредставлениеБазы();

	Конфигуратор = _ПараметрыРаботы.Конфигуратор;
	
	_Замер.НачатьЗамер( "Начало отключения от хранилища " + представлениеБазы, "ОтключениеОтХранилища" );
	
	Конфигуратор.ОтключитьсяОтХранилища();
	Текст = Конфигуратор.ВыводКоманды();
	Если Не ПустаяСтрока(Текст) Тогда
		_Лог.Информация(Текст);
	КонецЕсли;
	
	_Замер.СообщитьЗамер( "Отключено от хранилища " + представлениеБазы );
	
	_Замер.НачатьЗамер( "Подключение к хранилищу " + _ПараметрыРаботы.Параметры["Repo.Connect"] + " " + представлениеБазы, "ПодключениеКХранилищу" );
	
	Конфигуратор.ПодключитьсяКХранилищу(_ПараметрыРаботы.Параметры["Repo.Connect"], _ПараметрыРаботы.Параметры["Repo.User"], _ПараметрыРаботы.Параметры["Repo.Password"], Истина );
	Текст = Конфигуратор.ВыводКоманды();
	Если Не ПустаяСтрока(Текст) Тогда
		_Лог.Информация(Текст);
	КонецЕсли;
	
	_Замер.СообщитьЗамер( "Подключено к хранилищу " + _ПараметрыРаботы.Параметры["Repo.Connect"] + " " + представлениеБазы, "ПодключениеКХранилищу" );
	
	Если _ПараметрыРаботы.Параметры["UpdateCfg"] Тогда
		
		_Замер.НачатьЗамер( "Начало обновления конфигурации " + представлениеБазы, "ОбновлениеКонфигурации" );
		
		Конфигуратор.ОбновитьКонфигурациюБазыДанныхИзХранилища(_ПараметрыРаботы.Параметры["Repo.Connect"], _ПараметрыРаботы.Параметры["Repo.User"], _ПараметрыРаботы.Параметры["Repo.Password"] );
		Текст = Конфигуратор.ВыводКоманды();
		Если Не ПустаяСтрока(Текст) Тогда
			_Лог.Информация(Текст);
		КонецЕсли;
		
		_Замер.СообщитьЗамер( "Конфигурация обновлена " + представлениеБазы );
		
	КонецЕсли;
	
	ОбщегоНазначения.УдалитьФайлЕслиСуществует( _Конфигуратор.ФайлИнформации() );
	
КонецПроцедуры

Процедура СкопироватьБазуДанных()
	
	_ПараметрыРаботы.ТестПараметров();
	
	Если _ПараметрыРаботы.РежимТестированияПараметров Тогда
		_Замер.СообщитьЗавершение();
		Возврат;
	КонецЕсли;
	
	ВыполнитьБекап();
	
	ПроверитьСоединения();

	ВыполнитьВосстановление();
	
	УдалитьФайлБекапа();
	
	ПереподключитьХранилище();
	
	_Замер.СообщитьЗавершение();
	
КонецПроцедуры

_Лог = Логирование.ПолучитьЛог(ИмяЛога());

_ПараметрыРаботы = Новый ПараметрыРаботы();

_ПараметрыРаботы.Инициализация( АргументыКоманднойСтроки, _Лог );

_Замер = _ПараметрыРаботы.Замер;
_Конфигуратор = _ПараметрыРаботы.Конфигуратор;

СкопироватьБазуДанных();