
-- =============================================
-- Author:		<DANIEL AC>
-- Create date: <06/04/2018>
-- Description:	<Procedimiento para insertar un documento en especidico(INE, RCF, ACTA CONSTITUTIVA) en la tabla S_Documento_S3>
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <04/03/2019>
-- Description:	<Se agrega el campo de iddocumento al representante legal ya que ahora puede contener mas de un representante>
-- =============================================
-- ============================================= 
-- Author:        Daniel Cruz
-- Create date:	  26-07-21
-- Description:   Se agrega columna de Bucket
-- ============================================= 
-- ============================================= 
-- Author:        Alexander Gomez
-- Create date:	  09-03-2022
-- Description:   Se agrega el parametro para la fecha del documento repse
-- ============================================= 
ALTER PROCEDURE [dbo].[SP_DG_AgDocumentoActaConstitutiva_S3]

	-- Insertar Documento nuevo---
	@IdTipoDocumento INT, 
	@IdTipoValidacionDocumento INT, 
	@Activo BIT,
	@Documento NVARCHAR (MAX),
	@IdProveedor INT ,
	@IdUsuario INT ,
	@FechaVigenciaREPSE DATETIME = NULL,
	--- Insertar Acta constitutiva ---
	@NoActaConstitutiva NVARCHAR (150) = NULL, @Fecha DATE = NULL, @Nombre NVARCHAR (50) = NULL ,
	@NoNotario NVARCHAR (150) = NULL, @LugarNotarioPublico NVARCHAR (150) = NULL, @RPPC NVARCHAR (10) = NULL ,
	@ArchivoRPPC NVARCHAR (MAX) = NULL, @ActivoRPPC BIT = NULL, @NombreNotariaPublica NVARCHAR (360) = NULL ,
	@IdTipoDocumentoRPPC INT = NULL ,
	--@IdPerfil            INT = 0

	--Insertar Representante legal--
	@APaterno NVARCHAR (50) = NULL, @AMaterno NVARCHAR (50) = NULL, @NombreUs NVARCHAR (50) = NULL ,
	@DatosDocAcreditacion NVARCHAR (100) = NULL, @NoEscrituraPublica NVARCHAR (50) = NULL, @FechaRepLegal DATE = NULL ,
	@NombreNotarioRL NVARCHAR (50) = NULL, @NoNotarioRL NVARCHAR = NULL ,
	@DireccionNotarioPublicoRL NVARCHAR (150) = NULL, @CURPRL NVARCHAR (50) = NULL ,

	-- Nuevos parametros de entrada
	@NombreDocumento NVARCHAR (MAX), @Mime NVARCHAR (MAX), @Extension NVARCHAR (MAX), @Carpeta NVARCHAR (MAX) ,
	@IdentificadorS3 NVARCHAR (MAX) ,@Bucket NVARCHAR (MAX) = NULL,

	-- Nuevos parametros de entrada
	@NombreDocumentoRPPC NVARCHAR (MAX) = NULL, @MimeRPPC NVARCHAR (MAX) = NULL, @ExtensionRPPC NVARCHAR (MAX) = NULL ,
	@IdentificadorS3RPPC NVARCHAR (MAX) = NULL, @CarpetaRPPC NVARCHAR (MAX), @BucketRPPC NVARCHAR (MAX)
AS
	BEGIN
		DECLARE @IdDocumento INT,@NOMBRETIPODOCUMENTO VARCHAR(1000);

		IF @IdTipoDocumento = 1 --Insertar Documento Acta Constitutiva-
			BEGIN
				INSERT INTO [dbo].[DG_ActaConstitutiva]
					( [NoActaConstitutiva], [Fecha], [Nombre], [NoNotario], [LugarNotarioPublico], [IdProveedor] ,
					  [IsEliminado] , [IsActivo], [CreadoPor], [CreadoEn], [RPPC], [NombreNotarioPublico] )
				VALUES
					( @NoActaConstitutiva, @Fecha, @Nombre, @NoNotario, @LugarNotarioPublico, @IdProveedor, 0, 1 ,
					  @IdUsuario , GETDATE (), @RPPC, @NombreNotariaPublica ) ;

				--- INSERTAR Acta Constitutiva ----
				INSERT INTO S_Documento_S3
					( IdTipoDocumento, IdUsuario, IdProveedor, Activo, Documento, IdTipoValidacionDocumento, CreadoEl ,
					  NombreDocumento , Mime, Identificador, Extension, Carpeta )
				VALUES
					( @IdTipoDocumento, @IdUsuario, @IdProveedor, @Activo, @Documento, @IdTipoValidacionDocumento ,
					  GETDATE (), @NombreDocumento, @Mime, @IdentificadorS3, @Extension, @Carpeta )

				--- INSERTAR RPPC ----
				INSERT INTO S_Documento_S3
					( IdTipoDocumento, IdUsuario, IdTipoValidacionDocumento, IdProveedor, Activo, Documento, CreadoEl ,
					  NombreDocumento , Mime, Identificador, Extension, Carpeta , Bucket)
				VALUES
					( @IdTipoDocumentoRPPC, @IdUsuario, @IdTipoValidacionDocumento, @IdProveedor, @ActivoRPPC ,
					  @ArchivoRPPC , GETDATE (), @NombreDocumentoRPPC, @MimeRPPC, @IdentificadorS3RPPC, @ExtensionRPPC ,
					  @CarpetaRPPC ,@BucketRPPC)

				IF @@ERROR <> 0 SELECT 'false' AS  msj ;
				ELSE SELECT 'true' AS msj ;
			END
		ELSE IF @IdTipoDocumento = 13 ----Insertar Representante Legal
				 BEGIN
					 INSERT INTO	S_Documento_S3
						 ( IdTipoDocumento, IdUsuario, IdTipoValidacionDocumento, IdProveedor, Activo, Documento ,
						   CreadoEl , NombreDocumento, Mime, Identificador, Extension, Carpeta, Bucket )
					 VALUES
						 ( @IdTipoDocumento, @IdUsuario, @IdTipoValidacionDocumento, @IdProveedor, @Activo, @Documento ,
						   GETDATE (), @NombreDocumento, @Mime, @IdentificadorS3, @Extension, @Carpeta, ISNULL(@Bucket,'petrovendor-pr') ) ;

					 SELECT @IdDocumento = @@IDENTITY

					 INSERT INTO	DG_RepresentanteLegal
						 ( APaterno, AMaterno, Nombre, DatosDocumentoAcreditacion, NoEscrituraPublica, Fecha ,
						   NombreNotario , NoNotario, DireccionNotarioPublico, IdProveedor, IsEliminado, IsActivo ,
						   CreadoPor , CreadoEn, CURP, IdDocumento )
					 VALUES
						 ( @APaterno, @AMaterno, @NombreUs, @DatosDocAcreditacion, @NoEscrituraPublica, @FechaRepLegal ,
						   @NombreNotarioRL , @NoNotarioRL, @DireccionNotarioPublicoRL, @IdProveedor, 0, 1, @IdUsuario ,
						   GETDATE (), @CURPRL, @IdDocumento )

					 IF @@ERROR <> 0 SELECT 'false' AS msj ;
					 ELSE SELECT 'true'	   AS msj ;
				 END
		ELSE
				 ---Insertar documento
				 BEGIN
					
					SET @NOMBRETIPODOCUMENTO = (SELECT TOP 1 NombreTipoDocumento FROM S_TipoDocumento WHERE IdTipoDocumento = @IdTipoDocumento);
					--SE VALIDA SI EL DOCUMENTO ES DE REPSE
					IF (@NOMBRETIPODOCUMENTO = 'Certificado de aprobación de REPSE')
					BEGIN
						--SE ACTUALIZA LA FECHA DE VIGENCIA DEL REPSE
						UPDATE S_Proveedor
						SET FechaVigenciaREPSE = @FechaVigenciaREPSE
						WHERE IdProveedor = @IdProveedor;

					END

					INSERT INTO	S_Documento_S3
						 ( IdTipoDocumento, IdUsuario, IdTipoValidacionDocumento, IdProveedor, Activo, Documento ,
						   CreadoEl , NombreDocumento, Mime, Identificador, Extension, Carpeta, Bucket )
						 VALUES
							 ( @IdTipoDocumento, @IdUsuario, @IdTipoValidacionDocumento, @IdProveedor, @Activo, @Documento ,
							   GETDATE (), @NombreDocumento, @Mime, @IdentificadorS3, @Extension, @Carpeta, ISNULL(@Bucket,'petrovendor-pr'))

						 IF @@ERROR <> 0 SELECT 'false' AS msj ;
						 ELSE SELECT 'true'	   AS msj ;

					 
				 END
	END
