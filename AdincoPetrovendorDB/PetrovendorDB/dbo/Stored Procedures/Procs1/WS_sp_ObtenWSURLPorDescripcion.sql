USE Petrovendor
GO
DROP PROCEDURE IF EXISTS WS_sp_ObtenWSURLPorDescripcion
go
CREATE PROCEDURE WS_sp_ObtenWSURLPorDescripcion
@descripcion varchar(50)
as
BEGIN 
	SELECT * FROM WS_URLS 
	WHERE DESCRIPCION = @descripcion
END