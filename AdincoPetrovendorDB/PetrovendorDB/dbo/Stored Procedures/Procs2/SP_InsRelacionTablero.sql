-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <07/07/2020>
-- Description:	<Inserta las relaciones de los tableros con la configuracion>
-- =============================================
CREATE PROCEDURE SP_InsRelacionTablero
@IdUsuario INT,
@BoardRelations RelacionTablero READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @GroupRelations TABLE (
		Identificador INT IDENTITY(1,1),
		IdProveedor INT,
	    IdTipoUsuario INT,
	    IdRol INT,
	    IdTablero INT,
	    IdUsuario INT,
	    IdCreadoPor INT,
	    FechaRegistro DATETIME,
	    Activo BIT,
	    IdContrato INT
	)

	INSERT INTO @GroupRelations
	(
	    IdProveedor,
	    IdTipoUsuario,
	    IdRol,
	    IdTablero,
	    IdUsuario,
	    IdCreadoPor,
	    FechaRegistro,
	    Activo,
	    IdContrato
	)
	SELECT 
	BR.IdProveedor,
	BR.IdTipoUsuario,
	BR.IdRol,
	BR.IdTablero,
	@IdUsuario,
	0,
	GETDATE(),
	1,
	BR.IdContrato
	FROM @BoardRelations BR


	--verificar relaciones registradas anteriormente

	DECLARE @counter INT = 1
	DECLARE @toInsertRelacitions TABLE (
		IdentificadorRelacion INT
	)

	DECLARE @countRelations INT = (SELECT COUNT(1) FROM @GroupRelations)
	DECLARE @countRelationInserted INT = 0

	WHILE @counter <= @countRelations
	BEGIN
	    DECLARE @row TABLE (
			IdContrato INT NULL,
			IdTipoUsuario INT NULL,
			IdRol INT NULL,
			IdTablero INT NULL,
			IdProveedor INT NULL
		)

		INSERT INTO @row
		(
		    IdContrato,
		    IdTipoUsuario,
		    IdRol,
		    IdTablero,
		    IdProveedor
		)
		SELECT 
		GR.IdContrato,
		GR.IdTipoUsuario,
		GR.IdRol,
		GR.IdTablero,
		GR.IdProveedor
		FROM @GroupRelations GR 
		WHERE Identificador = @counter

		DECLARE @idProveedor INT,
				@idContrato INT,
				@idTipoUsuario INT,
				@idRol INT,
				@idTablero INT

		SELECT 
		@idProveedor = r.IdProveedor,
		@idContrato = r.IdContrato,
		@idTipoUsuario = r.IdTipoUsuario,
		@idRol = r.IdRol,
		@idTablero = r.IdTablero
		FROM 
		@row r

		--- checamos que no exista esta relacion

			DECLARE @ExistRelation INT = (
			SELECT COUNT(1) FROM dbo.Relacion_TableroRolTipo RT
			WHERE 
			RT.IdProveedor = @idProveedor
			AND RT.IdTipoUsuario = @idTipoUsuario
			AND RT.IdRol = @idRol
			AND RT.IdTablero = @idTablero
			AND RT.IdContrato = @idContrato
		)

		IF @ExistRelation >= 1
		BEGIN
			
			INSERT INTO @toInsertRelacitions
			(
			    IdentificadorRelacion
			)
			VALUES(@counter)

		    SET @countRelationInserted = @countRelationInserted + 1
		END


		
		SET @counter = @counter + 1
	END
	
	--- insertamos las relaciones si todas las relaciones son nuevas
	IF @countRelationInserted = 0 -- si es 0 indica que todas las relaciones son nuevas
	BEGIN
	    
		INSERT INTO dbo.Relacion_TableroRolTipo
		(
		    IdProveedor,
		    IdTipoUsuario,
		    IdRol,
		    IdTablero,
		    IdUsuario,
		    IdCreadoPor,
		    FechaRegistro,
		    Activo,
		    IdContrato
		)
		SELECT 
		_GR.IdProveedor,
		_GR.IdTipoUsuario,
		_GR.IdRol,
		_GR.IdTablero,
		_GR.IdUsuario,
		_GR.IdCreadoPor,
		_GR.FechaRegistro,
		_GR.Activo,
		_GR.IdContrato
		FROM 
		@GroupRelations _GR

		SELECT 'ok' AS response

	END
	ELSE
	BEGIN

		SELECT 'relaciones_existentes' AS response
	    -- consultamos las relaciones que ya fueron registradas para mostrarlas
		SELECT
		IdContrato,
		IdTipoUsuario,
		IdRol,
		IdTablero,
		IdProveedor
		FROM @GroupRelations 
		WHERE Identificador IN (SELECT IdentificadorRelacion FROM @toInsertRelacitions)
	END


END
