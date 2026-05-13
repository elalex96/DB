---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Manuel Cruz
-- Modificador: Jose Roman
-- Create date: 20-01-17
-- Modificado:  17-08-17
-- Description:	SP que se encarga de agregar un nuevo Proveedor
-- Cambios:		Se agrega la opcion de actualizar los datos en el caso de encontrar datos preecargados
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegInsertarRegistroProveedor]
    @idnacionalidad INT,
    @rfc NVARCHAR(50),
    @idtiporegimen INT,
    @razonsocial NVARCHAR(200),
    @regimencapital NVARCHAR(100),
   -- @fechaconstitucion NVARCHAR(15),
   --- @fechaoperacion NVARCHAR(15),
   -- @situacion NVARCHAR(15),
   -- @fechacambio NVARCHAR(15),
    @alias NVARCHAR(200),
   -- @entidad NVARCHAR(50),
   -- @municipio NVARCHAR(50),
   -- @colonia NVARCHAR(50),
   -- @tipovialidad NVARCHAR(50),
   -- @nombrevialidad NVARCHAR(50),
   -- @numexterior NVARCHAR(8),
   -- @numinterior NVARCHAR(8),
   -- @codpostal NVARCHAR(10),
    @correo NVARCHAR(MAX),
    @contrasena NVARCHAR(50),
    @idtipousuario INT,
   -- @idPais INT,
    @telefono VARCHAR(50),
    @idtiporegimencap INT
AS
BEGIN

    DECLARE @idproveedor INT;
    DECLARE @registrado AS DATETIME = GETDATE();
    DECLARE @idusuario INT;
    DECLARE @idu INT;
    DECLARE @idp INT;
    DECLARE @ExisteProveedor INT;
    DECLARE @ExisteUsuario INT;

    SET NOCOUNT ON;
    /*Validar que el proveedor no este registrado en la base de datos */

    SET @ExisteProveedor =
    (
        SELECT COUNT(RFC) FROM S_Proveedor AS P WHERE RFC = @rfc
    );

    SET @ExisteUsuario =
    (
        SELECT COUNT(Correo) FROM S_Usuario AS U WHERE Correo = @correo
    );

    /*CUANDO NO EXISTE EL PROVEEDOR Y NO EXISTE EL USUARIO.- 
	1.- Se inserta el proveedor y se recupera el id
	2.- Se inserta el usuario y se recupera el id  
	3.- Se inserta en usuarioproveedor
	4.- Se registra un nuevo domicilio*/
    IF (@ExisteProveedor = 0 AND @ExisteUsuario = 0)
    BEGIN

        INSERT INTO dbo.S_Proveedor
        (
            IdNacionalidad,
            RFC,
            IdTipoRegimen,
            RazonSocial,
            RegimenCapital,
           -- FechaConstitucion,
           -- FechaOperacion,
           -- SituacionContribuyente,
           -- FechaCambioSituacion,
            Alias,
           -- Entidad,
           -- Municipio,
           -- Colonia,
           -- TipoVialidad,
           -- NombreVialidad,
           -- NumExterior,
           -- NumInterior,
           -- CodigoPostal,
            IsEliminado,
            Activo,
           --IdPais,
            IdRegimenCapital,
            Telefono
        )
        VALUES
        (@idnacionalidad, @rfc, @idtiporegimen, @razonsocial, @regimencapital, @alias, 0, 0,  @idtiporegimencap, @telefono);

        SET @idproveedor =
        (
            SELECT @@IDENTITY
        );

        INSERT INTO dbo.S_Usuario
        (
            Nombre,
            Correo,
            Contrasena,
            Activo,
            IdTipoUsuario,
            FechaRegistro,
            IsEliminado,
            Telefono
        )
        VALUES
         (ISNULL(@razonsocial,''), @correo,  ISNULL(@contrasena, ''), 0, ISNULL(@idtipousuario, 3), ISNULL(@registrado, GETDATE()), 0, ISNULL(@telefono, ''));

        SET @idusuario =
        (
            SELECT @@IDENTITY
        );

        SET @idu = @idusuario;
        SET @idp = @idproveedor;

        INSERT INTO dbo.S_UsuarioProveedor
        (
            IdUsuario,
            IdProveedor
        )
        VALUES
        (@idu, @idp);

        INSERT INTO DG_Domicilio
        (
            IdPais,
            Estado,
            Municipio,
            Colonia,
            TipoViabilidad,
            NombreViabilidad,
            NoExterior,
            NoInterior,
            CodigoPostal,
            IdProveedor,
            IdCreadoPor,
            FechaAlta,
            Activo,
            IdTipoDomicilio
        )
        VALUES
        (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, @idproveedor, @idusuario, GETDATE(), 1, 1);

    END;

	ELSE 
	BEGIN
    /*CUANDO NO EXISTE EL USUARIO, PERO SI EXISTE EL PROVEEDOR
	1.-Inserta el usuario y recupera el id
	2.-Extrae el idproveedor del registro ya hecho
	3.-Actualiza el estatus del proveedor a Activo 
	4.- Se crea la relacion usuarioproveedor
	5.-Verifica que no tenga ningun domicilio fiscal activo 
	5.1 .- Si tiene se actualiza a activo = 0 
	5.1 .- Si no tiene Se agrega un domicilio*/
    IF (@ExisteProveedor > 0 AND @ExisteUsuario = 0)
    BEGIN

        SET @idproveedor =
        (
            SELECT IdProveedor FROM dbo.S_Proveedor WHERE RFC = @rfc
        );

		UPDATE dbo.S_Proveedor SET Activo = 1 WHERE IdProveedor = @idproveedor;
		
		DECLARE @TieneDomicilio int = (SELECT TOP 1 IdDomicilio FROM dbo.DG_Domicilio WHERE Activo = 1 AND IdTipoDomicilio = 1) 
		IF(@TieneDomicilio > 0 )
		BEGIN	 
			UPDATE dbo.DG_Domicilio SET	 Activo = 0 WHERE IdDomicilio =	@TieneDomicilio 
		END
		ELSE
        BEGIN	
		  ---- Agregar Domicilio Fiscal En Tabla DG_Domicilio   -----
        --- Se agrega por default Domicilio Fiscal  IdDomicilioFiscal = 1  -----
          INSERT INTO DG_Domicilio
        (
            IdPais,
            Estado,
            Municipio,
            Colonia,
            TipoViabilidad,
            NombreViabilidad,
            NoExterior,
            NoInterior,
            CodigoPostal,
            IdProveedor,
            IdCreadoPor,
            FechaAlta,
            Activo,
            IdTipoDomicilio
        )
        VALUES
        (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, @idproveedor, @idusuario, GETDATE(), 1, 1);
		END
        
        INSERT INTO dbo.S_Usuario
        (
            Nombre,
            Correo,
            Contrasena,
            Activo,
            IdTipoUsuario,
            FechaRegistro,
            IsEliminado,
            Telefono
        )
        VALUES
        (ISNULL(@razonsocial,''), @correo,  ISNULL(@contrasena, ''), 0, ISNULL(@idtipousuario, 3), ISNULL(@registrado, GETDATE()), 0, ISNULL(@telefono, ''));

        SET @idusuario =
        (
            SELECT @@IDENTITY
        );

        SET @idu = @idusuario;
        SET @idp = @idproveedor;

        INSERT INTO dbo.S_UsuarioProveedor
        (
            IdUsuario,
            IdProveedor,
            IsAdmin
        )
        VALUES
        (@idu, @idp, 1);
      
    END;
    ELSE
    BEGIN
        /*Cuando ya existe el usuario y no existe el proveedor
			1.- Verificar si el usuario existente esta activo
			2 .- Si esta activo, regresar respuesta de "Existe usuario" 
			3.0 .- Si NO esta activo, 
			3.1 .- actualizamos el correo ( posiblemente con un -)
			3.2 .- Se registra el proveedor y se recupera el ID del proveedor
			3.3 .- Se registra el usuario y se recupera el ID del usuario 
			3.4 .- Se crea la relacion en S_UsuarioProveedor
			 */
        IF (@ExisteProveedor = 0 AND @ExisteUsuario > 0)
        BEGIN

            DECLARE @IDEXISTEUSUARIO INT = (
                                               SELECT IdUsuario
                                               FROM S_Usuario AS U
                                               WHERE Correo = @correo
                                                     AND U.Activo = 0
                                           );

            IF (@IDEXISTEUSUARIO > 0)
            BEGIN
                /**Modifico el correo para que no cause conflicto o duplicidad*/
                UPDATE dbo.S_Usuario
                SET Correo = CONCAT(@correo, '-')
                WHERE IdUsuario = @IDEXISTEUSUARIO;

                /**Registro al usuario y proveedor como si fuera uno nuevo*/
              INSERT INTO dbo.S_Proveedor
        (
            IdNacionalidad,
            RFC,
            IdTipoRegimen,
            RazonSocial,
            RegimenCapital,
           -- FechaConstitucion,
           -- FechaOperacion,
           -- SituacionContribuyente,
           -- FechaCambioSituacion,
            Alias,
           -- Entidad,
           -- Municipio,
           -- Colonia,
           -- TipoVialidad,
           -- NombreVialidad,
           -- NumExterior,
           -- NumInterior,
           -- CodigoPostal,
            IsEliminado,
            Activo,
           --IdPais,
            IdRegimenCapital,
            Telefono
        )
        VALUES
        (@idnacionalidad, @rfc, @idtiporegimen, @razonsocial, @regimencapital, @alias, 0, 0,  @idtiporegimencap, @telefono);

                SET @idproveedor =
                (
                    SELECT @@IDENTITY
                );

                INSERT INTO dbo.S_Usuario
                (
                    Nombre,
                    Correo,
                    Contrasena,
                    Activo,
                    IdTipoUsuario,
                    FechaRegistro,
                    IsEliminado,
                    Telefono
                )
                VALUES
                (ISNULL(@razonsocial,''), @correo,  ISNULL(@contrasena, ''), 0, ISNULL(@idtipousuario, 3), ISNULL(@registrado, GETDATE()), 0, ISNULL(@telefono, ''));

                SET @idusuario =
                (
                    SELECT @@IDENTITY
                );

                SET @idu = @idusuario;
                SET @idp = @idproveedor;

                INSERT INTO dbo.S_UsuarioProveedor
                (
                    IdUsuario,
                    IdProveedor
                )
                VALUES
                (@idu, @idp);

               INSERT INTO DG_Domicilio
        (
            IdPais,
            Estado,
            Municipio,
            Colonia,
            TipoViabilidad,
            NombreViabilidad,
            NoExterior,
            NoInterior,
            CodigoPostal,
            IdProveedor,
            IdCreadoPor,
            FechaAlta,
            Activo,
            IdTipoDomicilio
        )
        VALUES
        (NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, @idproveedor, @idusuario, GETDATE(), 1, 1);


            END;
            ELSE
            BEGIN


                /* 'El usuario activo ya existe';*/
                SET @idusuario = -1;
                SET @idproveedor = -1;

            END;
        END;
    END;
	END;
    
    SELECT @idusuario AS usuario,
           @idproveedor AS proveedor;
END;


