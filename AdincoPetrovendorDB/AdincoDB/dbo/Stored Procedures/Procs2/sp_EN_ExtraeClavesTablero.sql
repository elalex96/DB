CREATE PROCEDURE [dbo].[sp_EN_ExtraeClavesTablero]--3,10061,1,0
    @idContrato INT,
	@idUsuario INT,
    @IdRol INT,
	@IdTableroContrato INT
AS
BEGIN
    SET NOCOUNT ON;

IF(@IdTableroContrato = 0)
BEGIN
	IF ((SELECT COUNT(1) FROM dbo.EN_TableroContrato 

WHERE IdContrato =@idContrato AND Activo=1)>1)
	BEGIN
		IF 1 <= (SELECT COUNT(1) FROM dbo.EN_TableroContrato WHERE IdContrato = @idContrato AND Activo=1 AND IdRol=@IdRol)
		BEGIN
			SELECT Workbook,
				Sheet,
				Tabs,
				Site,
				CASE Site 
					WHEN ''
				THEN ''
					ELSE
					'/t/'+ Site
				END AS SiteT,
				DNS,
				HeightPX,
				ISNULL(REPLACE(Parametros,'##Usuario##',U.Nombre),'') AS Parametros,
				CASE WHEN Isnull(MuestraToolbar,0) = 1 and ISNULL(UserTableau,'admin') <> 'admin'
						THEN 'si'
					ELSE 'no'
				END AS Toolbar,
				ISNULL(UserTableau,'admin') AS UserTableau
			FROM dbo.EN_TableroContrato --TC
			JOIN AP_Usuario U ON U.UsuarioID	=	@idUsuario
			WHERE IdContrato = @idContrato
			AND Activo=1 AND IdRol = @IdRol
		END
		ELSE
		BEGIN
			IF 1 <= (SELECT COUNT(1) FROM dbo.EN_TableroContrato WHERE IdContrato = @idContrato AND Activo=1 AND IdRol IS NULL)
			BEGIN
				SELECT TOP 1
					Workbook,
					Sheet,
					Tabs,
					Site,
					CASE Site 
						WHEN ''
						THEN ''
						ELSE
						'/t/'+ Site
					END AS SiteT,
					DNS,
					HeightPX,
					ISNULL(REPLACE(Parametros,'##Usuario##',U.Nombre),'') AS Parametros,
					CASE WHEN Isnull(MuestraToolbar,0) = 1 and ISNULL(UserTableau,'admin') <> 'admin'
							THEN 'si'
						ELSE 'no'
					END AS Toolbar,
					ISNULL(UserTableau,'admin') AS UserTableau
				FROM dbo.EN_TableroContrato
				JOIN AP_Usuario U 
					ON U.UsuarioID	=	@idUsuario
				WHERE IdContrato = @idContrato
				AND Activo=1 
				AND IdRol IS NULL
			END
			ELSE
			BEGIN
				SELECT TOP 1
					Workbook,
					Sheet,
					Tabs,
					Site,
					CASE Site 
						WHEN ''
						THEN ''
						ELSE
						'/t/'+ Site
					END AS SiteT,
					DNS,
					HeightPX,
					ISNULL(REPLACE(Parametros,'##Usuario##',U.Nombre),'') AS Parametros,
					CASE WHEN Isnull(MuestraToolbar,0) = 1 and ISNULL(UserTableau,'admin') <> 'admin'
							THEN 'si'
						ELSE 'no'
					END AS Toolbar,
					ISNULL(UserTableau,'admin') AS UserTableau
				FROM dbo.EN_TableroContrato
				JOIN AP_Usuario U 
					ON U.UsuarioID	=	@idUsuario
				WHERE IdContrato = @idContrato
				AND Activo=1 
			END
		END
	END
	ELSE
	BEGIN
		SELECT Workbook,
			Sheet,
			Tabs,
			Site,
			CASE Site 
				WHEN ''
				THEN ''
				ELSE
				'/t/'+ Site
			END AS SiteT,

			DNS,
			HeightPX,
			ISNULL(REPLACE(Parametros,'##Usuario##',U.Nombre),'') AS Parametros,
			CASE WHEN Isnull(MuestraToolbar,0) = 1 and ISNULL(UserTableau,'admin') <> 'admin'
					THEN 'si'
				ELSE 'no'
			END AS Toolbar,
			ISNULL(UserTableau,'admin') AS UserTableau
		FROM dbo.EN_TableroContrato
		JOIN AP_Usuario U ON U.UsuarioID	=	@idUsuario
		WHERE IdContrato = @idContrato
		AND Activo=1;
	END
END
ELSE
BEGIN
	SELECT Workbook,Sheet,Tabs,Site,
		CASE Site 
			WHEN ''
			THEN ''
			ELSE
			'/t/'+ Site

		END AS SiteT,
		DNS,
		HeightPX,
		ISNULL(REPLACE(Parametros,'##Usuario##',U.Nombre),'') AS Parametros,
		CASE WHEN Isnull(MuestraToolbar,0) = 1 and ISNULL(UserTableau,'admin') <> 'admin'
				THEN 'si'
			ELSE 'no'
		END AS Toolbar,
		ISNULL(UserTableau,'admin') AS UserTableau
	FROM dbo.EN_TableroContrato
	JOIN AP_Usuario U ON U.UsuarioID	=	@idUsuario
	WHERE	IdContrato	=	@idContrato 
		AND	IdTableroContrato	=	@IdTableroContrato
END
END;
