CREATE PROCEDURE dbo.sp_SCOC_ValidaPermisosCargaExcel
	@IdContrato INT,
	@IdUsuario  INT,
	@IdTipoExcel	INT
AS
BEGIN

	-- SE VALIDA SI EL TIPO DE EXCEL NO ES DE EDICION RESTRINGIDA
	IF 0 = (SELECT	ISNULL(EdicionRestringida,0)
			FROM	PC_TipoExcelPemex
			WHERE	IdTipoExcelPemex	= @IdTipoExcel
			)
	BEGIN
			SELECT 1	AS [Valido]
	END
	ELSE
	BEGIN
	-- SI ES RESTRINGIDA, SE VALIDAN LOS PERMISOS DEL USUARIO, QUE TENGA PERMISOS DE EDICION
		IF 1 = (SELECT	COUNT(1)
			FROM AP_PermisosUsuarios
			WHERE UsuarioID	=	@IdUsuario
			AND	IdPermiso	=	2	-- EDICION
			AND BitActivo	=	1
			)
		BEGIN
			SELECT 1	AS [Valido]
		END
		ELSE
		BEGIN
			SELECT 0	AS [Valido]
		END
	END
END