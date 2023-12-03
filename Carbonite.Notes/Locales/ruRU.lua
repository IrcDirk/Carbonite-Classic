if ( GetLocale() ~= "ruRU" ) then
	return;
end

local L = LibStub("AceLocale-3.0"):NewLocale("Carbonite.Notes", "ruRU")
if not L then return end

L["Note Options"] = "Настройки заметок"
L["Show Notes On Map"] = "Показывать заметки на карте"
L["Shows your notes on the carbonite map"] = "Показывать ваши заметки на карте carbonite"
L["Show Notes"] = "Показывать заметки"
L["-Notes-"] = "-Заметки-"
L["Add Note"] = "Добавить Заметку"
L["Notes Module"] = "Модуль Заметок"
L["Toggle Notes"] = "Вкл./Выкл. Заметки"
L["Record"] = "Запись"
L["Up"] = "Вверх"
L["Down"] = "Вниз"
L["Delete Item"] = "Удалить"
L["Name"] = "Имя"
L["Type"] = "Тип"
L["Value"] = "Значение"
L["Location"] = "Местоположение"
L["Select a favorite before recording"] = "Выберите избранную перед записью"
L["Add Folder"] = "Добавить папку"
L["Add Favorite"] = "Добавить в избранное"
L["Rename"] = "Переименовать"
L["Cut"] = "Вырезать"
L["Copy"] = "Копировать"
L["Paste"] = "Вставить"
L["Options"] = "Настройки"
L["Add Comment"] = "Добавить комментарий"
L["Set Icon"] = "Задать иконку"
L["Name"] = "Имя"
L["Nothing to paste"] = "Нечего вставить"
L["Can't paste that on the left side"] = "Не могу это вставить в левую часть"
L["Can't paste that on the right side"] = "Не могу это вставить в правую часть"
L["Note"] = true
L["Notes"] = "Заметки"
L["Note Addons"] = "Дополнения заметок"
L["My Notes"] = "Мои заметки"

L["Reset old notes data"] = "Сбросить старые заметки"
L["Display Handynotes On Map"] = "Показывать на карте отметки плагина HandyNotes"
L["If you have HandyNotes installed, allows them on the Carbonite map"] = "Если у вас установлен плагин HandyNotes, то включение этого параметра отобразит иконки HandyNotes на карте"
L["Handnotes Icon Size"] = "Размер иконки HandyNotes"

-- Keybinds
L["Carbonite Notes"] = "Carbonite Notes"
L["NxTOGGLEFAV"] = "show/hide Notes"
