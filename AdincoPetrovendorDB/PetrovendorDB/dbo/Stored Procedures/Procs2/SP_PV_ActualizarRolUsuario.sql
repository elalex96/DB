-- =============================================
-- Author: DANIEL AC
-- Create date: 31/08/2017
-- Description:	Actualizar Rol
-- Author: ABEL R
-- Create date: 07/08/2017
-- Description:	Actualizar Rol
-- Author: DANIEL AC
-- Create date: 08/09/2017
-- Description:	Actualizar Rol
-- =============================================
CREATE  PROCEDURE [dbo].[SP_PV_ActualizarRolUsuario]
@IdProveedor   INT,
@IdUsuario     INT,
@IdUsuarioAlta INT,
@DeleteRoles   NVARCHAR(MAX),
@Roles         NVARCHAR(MAX)

-- execute SP_PV_ActualizarRolUsuario 44,1177,2205,'',''
AS

BEGIN
DECLARE @RolesExistente INT
DECLARE   @CantidadRolesInsert INT
DECLARE @ExisteRegistro INT
DECLARE @IdRolTemp      INT
DECLARE @strCadena VARCHAR(255)
DECLARE  @newStrCadena VARCHAR(MAX)
DECLARE  @strRol int

DECLARE @strCadena2 VARCHAR(255)
DECLARE  @newStrCadena2 VARCHAR(MAX)
DECLARE  @strRol2 int

 --- CREATE TABLE #RolesTemp(Id INT,IdRol INT) -- ASOCIACIÓN ROL APROBACIÓN/USUARIO


  CREATE TABLE #RolesTemp -- TABLA TEMPORAL QUE ALMACENA LOS NUEVOS ROLES
	(
	Id INT IDENTITY(1,1) NOT NULL,
	IdRol INT
	)


	SET @strCadena = @Roles
	SET @newStrCadena = (@strCadena + ',')

	DECLARE @begin INT = 0, @count INT = 0, @max INT
	
	SELECT @max = LEN(@newStrCadena) - LEN(REPLACE(@newStrCadena,',',''))

	WHILE @count < @max
    BEGIN
	SET @strRol =( CAST( SUBSTRING(@newStrCadena,@begin,CHARINDEX(',',@newStrCadena,@begin + 1)- @begin) as INT)) -- OBTENER LOS ROLES

	SET @begin = (CHARINDEX(',',@newStrCadena,@begin+1) + 1)
	SET @count = @count + 1


		INSERT INTO #RolesTemp -- INSERTAR EL ROL DE LA CADENA
		(
		IdRol
		)
		VALUES(
		@strRol
		)
	END 
  --INSERT #RolesTemp(
  --Id,IdRol
  --)
  --EXEC SP_PV_ObtenerRolesDeCadena @Roles
  
  ----CREATE TABLE #DeleteRolesTemp(Id INT,IdRol INT) -- ASOCIACIÓN ROL APROBACIÓN/USUARIO A ELIMINAR


    CREATE TABLE #DeleteRolesTemp -- TABLA TEMPORAL QUE ALMACENA LOS NUEVOS ROLES
	(
	id INT IDENTITY(1,1) NOT NULL,
	IdRol INT
	)
	
	set @strCadena =''
	set  @newStrCadena =''
	set  @strRol =0

	SET @strCadena = @DeleteRoles
	SET @newStrCadena = (@strCadena + ',')

	set @begin  = 0
	set  @count  = 0
	set @max =0
	
	SELECT @max = LEN(@newStrCadena) - LEN(REPLACE(@newStrCadena,',',''))

	WHILE @count < @max
    BEGIN
	SET @strRol =( CAST( SUBSTRING(@newStrCadena,@begin,CHARINDEX(',',@newStrCadena,@begin + 1)- @begin) as INT)) -- OBTENER LOS ROLES

	SET @begin = (CHARINDEX(',',@newStrCadena,@begin+1) + 1)
	SET @count = @count + 1


		INSERT INTO #DeleteRolesTemp -- INSERTAR EL ROL DE LA CADENA
		(
		IdRol
		)
		VALUES(
		@strRol
		)
	END 





  --INSERT #DeleteRolesTemp(
  --Id,IdRol
  --)
  --EXEC SP_PV_ObtenerRolesDeCadena @DeleteRoles
  

  SET @RolesExistente = (SELECT COUNT(IdRol) FROM [dbo].[S_UsuarioRol] WHERE [IdUsuario]= @IdUsuario) --- CONSULTAR SI EXISTEN ROLES ASIGNADOS AL USUARIO

  IF (@RolesExistente > 0) -- YA EXISTE AL MENOS UN ROL DE APROBACIÓN PARA EL USUARIO
	BEGIN
		DECLARE @CantidadRolesAsociacion INT,
          @countRolAsociacion      INT

		SET @countRolAsociacion = 1
		SET @CantidadRolesAsociacion = (SELECT COUNT(Id) FROM #RolesTemp)
		  WHILE @countRolAsociacion <= @CantidadRolesAsociacion
			  BEGIN
			 
				
				SET @IdRolTemp = (SELECT IdRol FROM #RolesTemp WHERE Id = @countRolAsociacion) 

				SET @ExisteRegistro = (SELECT  COUNT(S_RolUsuario) FROM S_UsuarioRol WHERE IdRol = @IdRolTemp
								 AND Activo = 1 AND IdUsuario = @IdUsuario)

				IF (@ExisteRegistro = 0) --- CONSULTAR SI EL ROL AGREGADO ESTE ASOCIADO CON EL USUSARIO 
					BEGIN
						 DECLARE @RegistroInactivo INT
						 SET @RegistroInactivo = (SELECT  COUNT(S_RolUsuario) FROM S_UsuarioRol WHERE IdRol = @IdRolTemp
										   AND IdUsuario = @IdUsuario)

						IF (@RegistroInactivo > 0) --- EL REGISTRO EXISTIA PERO ESTABA INACTIVO 
								BEGIN
									  UPDATE S_UsuarioRol
									  SET Activo = 1,
									  EditadoEl = GETDATE(),
									  IdEditadoPor = @IdUsuarioAlta
									  WHERE IdRol = @IdRolTemp AND
									  IdUsuario = @IdUsuario
								 END --- FIN ACTUALIZAR ACTIVO = 1
   
						IF (@RegistroInactivo = 0 AND @IdRolTemp != 0) --- EL REGISTRO NO EXISTE => INSERTAR
								BEGIN
									  INSERT INTO S_UsuarioRol(
									   IdUsuario,
									   IdRol,
									   Activo,
									   IdCreadoPor,
									   CreadoEl
									  )
									  VALUES(
									  @IdUsuario,
									  @IdRolTemp,
									  1,
									  @IdUsuarioAlta,
									  GETDATE())
									END -- FIN EL REGISTRO NO EXISTE

				
					END --- FIN SI NO EXISTE EL REGISTRO POR QUE ESTA INACTIVO
				set @countRolAsociacion = @countRolAsociacion +1
			END --- FIN CICLO WILE

		

		  IF (@DeleteRoles != '')
			  BEGIN
				  DECLARE @CantidadRolDelete INT,
						  @countDelete       INT

					SET @countDelete = 1
					SET @CantidadRolDelete = (SELECT COUNT(Id) FROM #DeleteRolesTemp)
					  WHILE @countDelete <= @CantidadRolDelete
						BEGIN
							UPDATE S_UsuarioRol
							SET  Activo = 0
							WHERE IdRol = (SELECT IdRol FROM #DeleteRolesTemp WHERE Id = @countDelete) AND
							IdUsuario = @IdUsuario

							SET @countDelete = @countDelete + 1
						END --- CICLO WHILE
			 END --- ELIMINAR ASOCIACIÓN ROL/USUARIO

  END ----------------------------------------------------------------------

  ELSE -- NO EXISTEN ROLES ASIGNADOS AUN 
  BEGIN

	DECLARE @CantidadRoles INT
	---DECLARE @count         INT
	DECLARE @IdRol         INT

	SET @count = 1
	SET @CantidadRoles = (SELECT COUNT(IdRol) FROM #RolesTemp)

	 WHILE @count <= @CantidadRoles
		BEGIN
		SET @IdRol = (SELECT IdRol FROM #RolesTemp WHERE Id = @count)
		SET @ExisteRegistro = (SELECT  COUNT(S_RolUsuario) FROM S_UsuarioRol WHERE IdRol = @IdRol
								AND IdUsuario = @IdUsuario)


		IF @IdRol != 0 AND @ExisteRegistro  = 0
			BEGIN
				  INSERT S_UsuarioRol  -- INSERTAR LOS NUEVOS ROLES DE APROBACIÓN PARA EL USUARIO
				  (
				   IdUsuario,
				   IdRol,
				   Activo,
				   IdCreadoPor,
				   CreadoEl
				  )
				  VALUES(
				  @IdUsuario,
				  @IdRol,
				  1,
				  @IdUsuarioAlta,
				  GETDATE()
				  )
				
			END 
			set  @count=@count+1
	  END  --- FIN NO EXISTEN ROLES ASIGNADOS
  
  END



  SELECT 'SUCCESS'
 
END


