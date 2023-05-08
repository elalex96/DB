CREATE PROCEDURE AP_sp_ExtraeClavesTablero --10041,10128,14
	@idContrato INT,
	@idUsuario INT,
	@IdTablero INT
AS
BEGIN
	SELECT	
			T.Workbook,
			T.Sheet,
			T.Tabs,
			T.Site,
			CASE T.Site 
						WHEN ''
						THEN ''
						ELSE
						'/t/'+ T.Site
					END AS SiteT,
			T.DNS,
			T.HeightPX,
			ISNULL(REPLACE(T.Parametros COLLATE SQL_Latin1_General_CP1_CI_AS,'##Usuario##',U.Nombre),'') AS Parametros,
			CASE WHEN Isnull(T.MuestraToolbar,0) = 1 and ISNULL(T.UserTableau,'admin') <> 'admin'
							THEN 'si'
						ELSE 'no'
					END AS Toolbar,
			T.UserTableau
			FROM Petrovendor..AP_TablerosUsuario AS TU
		JOIN Petrovendor..AP_Tableros AS T ON TU.IdTablero = T.Id 
		JOIN Adinco..CO_Contrato AS C ON T.IdContrato = C.IdContrato
		JOIN Adinco..CO_AreaContractual	AC ON	C.IdAreaContractual	=	AC.IdAreaContractual
		JOIN Adinco..AP_Usuario as U ON TU.IdUsuario = U.UsuarioID
		WHERE 
		TU.IdUsuario = @idUsuario
		AND T.IdContrato = @idContrato
		AND T.Id = @IdTablero
		AND T.Activo = 1
		AND TU.Activo = 1
END
